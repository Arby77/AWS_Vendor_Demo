- Place .CSV files in C:\aws_demo
- Within AWS_Vendor_Load.py, replace the server, database, username, and password with SQL credentials of a login that has table creation/insert/rename/select rights
- Ensure pandas and sqlalchemy python libraries are installed as well as python, or create a virtual environment if libraries are already installed
- Either restore backup of aws_demo.bak for demo database
	- Or create a blank sql database
	- Ensure a user exists for the service
	- Perform a flat file import of the geo_data csv file into a table called geo_data
		- Right click database | tasks | Import flat file
		- Follow the walk through, may need to adjust some data types to match the following: 

		[Zip_Code] [int] NOT NULL,
		[Official_USPS_city_name] [nvarchar](50) NOT NULL,
		[Official_USPS_State_Code] [nvarchar](50) NOT NULL,
		[Official_State_Name] [nvarchar](50) NOT NULL,
		[ZCTA] [nvarchar](50) NOT NULL,
		[ZCTA_parent] [nvarchar](1) NULL,
		[Population] [float] NULL,
		[Density] [float] NULL,
		[Primary_Official_County_Code] [int] NOT NULL,
		[Primary_Official_County_Name] [nvarchar](50) NOT NULL,
		[County_Weights] [varchar](500) NOT NULL,
		[Official_County_Name] [varchar](500) NOT NULL,
		[Official_County_Code] [nvarchar](50) NOT NULL,
		[Imprecise] [nvarchar](50) NOT NULL,
		[Military] [nvarchar](50) NOT NULL,
		[Timezone] [nvarchar](50) NOT NULL,
		[Geo_Point] [nvarchar](50) NOT NULL

		- Run the four "vu_" files to create the views

- Run AWS_Vendor_Load.py
- If any errors the file will move to the errors directory with a text file produced of the error
- If successful the file will move to the processed directory


Tradeoffs, additional thoughts:
- Focused more heavily on the ingestion side originally trying to build in flexibility which caused me to run out of time while building the transformations so did not complete all columns.
- Started off with local csv's for ease of testing with plans to go back and replace with boto3 s3 connection but didn't have time, had some test function created to replicate the local path behavior in the s3 bucket.
- Add logic for new sources to auto generate dbt files, however I only had SQL and jupyter notebook on my personal machine so used SQL views as reference, I would further split out the transformation views into dbt base and stage layers.
- The ingestion script was built under the context in the pdf that vendor files would be cumluative and records a snapshot of each ingestion then takes the most recent for the main data set. If the files were delta only I would need to adjust the code to perform an upsert on phone/address.
- Possibly would add in last updated date to the data set for info on how recent the data was loaded.
- There were a few spots I ended up hardcoding for sake of time, I'd like to better handle these more dynamically where possible. 
- I envision this would be scheduled with airflow, additionally I would move the plain text credentials into the airflow secrets page.
- Due to time constraints used the entire Name field instead of splitting into first and last. 
- The python script will write out errors to the error directory but with more time would like to add logic to email or teams notifications of failures. 
- On the language field, thought about using English since they are all within the US, but decided against it since I am not certain based on the data.
- Skipped license number, renewed, name for now since I'm not certain enough which values they correspond to and would rather not display an incorrect value before verifying further.
- Would like to separate out the python functions so they aren't all in one large file.
- Ran out of time for some of the fields on the final transformation. 
- The script should allow for schema changes, maintaining snapshot records as well as previous table schemas. It should also be able to create a new source if it is a .csv file. 
- Some of the data cleaning and validation was done by hand through the views, may be ablet o automate some of these processes more.
- For data governance, may be able to use something like zoom info or smarty streets to validate address information.
- If I were to redo the exercise or had more time I would start with a more simple ingestion script and spend more time on the data transformations, validation, qa, etc.