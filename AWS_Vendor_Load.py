#!/usr/bin/env python
# coding: utf-8

# In[89]:


def format_phone_number(num_str):
    
    #Ensure the input is a string to handle blanks
    if not isinstance(num_str, str):
        return "" 

    #Remove non-numeric characters
    cleaned = ''.join(filter(str.isdigit, num_str))
    
    #Ensure cleaned string has at least 10 digits before formatting
    if len(cleaned) < 10:
        return num_str  #Return original string if not enough digits

    #Reformat to xx-xxx-xxxx
    return f"{cleaned[:3]}-{cleaned[3:6]}-{cleaned[6:]}"


def split_address(df):
    if 'Address' in df.columns:
        
        #Store original address value in Address_full
        df['Address_full'] = df['Address']
        
        #Split address before first comma to try and get only the address value
        df['Address'] = df['Address'].apply(lambda x: x.split(',', 1)[0].strip() if ',' in x else x)

    return df


def custom_csv_parser(file_path, delimiter=',', quotechar='"'):
    data = []
    headers = None
    
    #Read csv files, ensure encoding windows can understand
    with open(file_path, 'r', encoding='ISO-8859-1') as file:
        reader = csv.reader(file, delimiter=delimiter, quotechar=quotechar)
        for row in reader:
            try:
                #Check if the first row contains headers or not
                if headers is None:
                    headers = row
                    continue
                data.append(row)
            except Exception as e:
                print(f"Error parsing row: {row}. Error: {e}")

    #Create a dataframe from the file
    df = pd.DataFrame(data, columns=headers)
    
    #Drop completely empty columns
    df = df.dropna(axis=1, how='all')
    
    #Drop any columns that are unnamed (or blank after stripping whitespace)
    df = df.loc[:, [col.strip() != '' for col in df.columns]]
    
    #Check for columns containing the word 'phone'
    for col in df.columns:
        if 'phone' in col.lower():
            if col != 'Phone':  
                df['Phone'] = df[col].apply(format_phone_number) #Standardize phone number and rename field to Phone if necessary
                df.drop(col, axis=1, inplace=True)
            else:
                df[col] = df[col].apply(format_phone_number) #Format in place if the field is already called Phone

    return df


def get_table_columns(engine, table_name):
    inspector = inspect(engine)
    return [column['name'] for column in inspector.get_columns(table_name)]

def handle_schema_change(engine, table_name, df):
    #Detect schema changes, if so rename the current table with a datetime for historical purposes and create a new table

    inspector = inspect(engine)
    if table_name in inspector.get_table_names():
        
        #Fetch columns of the existing table
        table_columns = get_table_columns(engine, table_name)

        #Check if DataFrame columns and table columns are different
        if set(df.columns) != set(table_columns):
            metadata = MetaData()

            #Rename the existing table, add on a date time
            old_table = Table(table_name, metadata, autoload_with=engine)

            rename_to = table_name + "_" + datetime.now().strftime("%Y%m%d_%H%M%S")

            with engine.begin() as connection:
                connection.execute(f"EXEC sp_rename '{table_name}', '{rename_to}'")  

            print(f"Renamed table {table_name} to {rename_to} due to schema changes.")

def create_view_for_table(engine, table_name):
    #Automate the creation of a base layer view for each source
    
    #Get the columns of the table
    metadata = MetaData()
    table = Table(table_name, metadata, autoload_with=engine)
    
    #Create a list of columns and replace spaces with underscores
    columns = [f'[{col.name}] AS {col.name.replace(" ", "_")},' for col in table.columns]
    columns_str = '\n        '.join(columns)

    #Remove trailing comma
    if columns_str.endswith(','):
        columns_str = columns_str[:-1]
    
    view_name = "vu_" + table_name
    
    #Verify the view doesn't already exist
    check_sql = f"SELECT * FROM sys.views WHERE name = '{view_name}'"
    result = engine.execute(text(check_sql)).fetchone()
    
    if not result:
        sql = f"""
        CREATE VIEW {view_name} AS
        SELECT 
        {columns_str}
        FROM {table_name}
        WHERE load_date = (SELECT MAX(load_date) FROM {table_name})
        """
        with engine.begin() as connection:
            connection.execute(text(sql))
        print(f"View {view_name} created.")
        
import pandas as pd
from datetime import datetime
import csv
import os
import re
from sqlalchemy import inspect, MetaData, Table, create_engine, text
import shutil

server = 'localhost\SQLEXPRESS' # replace with your actual server name
database = 'aws_demo' # replace with your actual database name
username = 'API' # replace with your actual username
password = 'password' # replace with your actual password
engine = create_engine(f'mssql+pyodbc://{username}:{password}@{server}/{database}?driver=SQL+Server')

# Path to CSV Files
dir_path = "c:\\aws_demo"

#List all CSV files in the directory
csv_files = [f for f in os.listdir(dir_path) if f.endswith('.csv')]

#Create 'processed' and 'error' subdirectories if they don't exist
processed_dir = os.path.join(dir_path, 'processed')
error_dir = os.path.join(dir_path, 'error')

if not os.path.exists(processed_dir):
    os.makedirs(processed_dir)

if not os.path.exists(error_dir):
    os.makedirs(error_dir)

for file in os.listdir(dir_path):
    #Get files ending with .csv
    if file.endswith(".csv"):
        file_path = os.path.join(dir_path, file)
        
        try:

            #Create pandas dataframe using csv parser function
            df = custom_csv_parser(file_path)

            #Rename address1 to address to have consistent naming across all files
            #Hardcoded this for now, future goal to make this more dynamic
            if 'Address1' in df.columns:
                df.rename(columns={'Address1': 'Address'}, inplace=True)

            #If there seems to be a full address with a comma, try to split it out to another field
            if 'Address' in df.columns and df['Address'].str.contains(',').any():
                df = split_address(df)
                
            #Handle slashes in column names
            df.columns = [col.replace('/', '_') for col in df.columns]

            #Append filename and load date
            df['filename'] = file
            df['load_date'] = datetime.now()

            #Clean up the filename for table name
            clean_name = re.sub(r"^\d{2}-\d{2}-\d{4} ", "", file)  #Strip out leading date if exists
            clean_name = re.sub(r" ", "_", clean_name)              #Replace spaces with underscores
            clean_name = os.path.splitext(clean_name)[0]            #Remove file extension
            table_name = clean_name


            #Verify if the schema has been changed before inserting
            #If so, then rename table to add _datetime and create new table
            handle_schema_change(engine, table_name, df)

            df.to_sql(table_name, engine, if_exists='append', index=False)  # Changed 'replace' to 'append'
            
            #Move file to processed directory if successful
            shutil.move(file_path, os.path.join(processed_dir, file))
            print(f"Processed: {file}")
            
            try:
                create_view_for_table(engine, table_name)
            except: 
                print("Could not auto create view")
                continue

        except Exception as e:
            #If an error occurs, move the file to 'error'
            shutil.move(file_path, os.path.join(error_dir, file))
            
            #Write the error to a text file named after the CSV
            error_file = os.path.join(error_dir, os.path.splitext(file)[0] + '-Error.txt')
            with open(error_file, 'w') as f:
                f.write(str(e))
            
            print(f"Error processing {file}. Error details written to {error_file}.")
            continue  #Go to the next file


# In[ ]:




