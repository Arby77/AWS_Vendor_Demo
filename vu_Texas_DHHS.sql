USE [aws_demo]
GO

/****** Object:  View [dbo].[vu_Texas_DHHS]    Script Date: 10/29/2023 11:00:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

        CREATE VIEW [dbo].[vu_Texas_DHHS] AS
        SELECT 
        [Operation #] AS Operation_#,
        [Agency Number] AS Agency_Number,
        [Operation_Caregiver Name] AS Operation_Caregiver_Name,
		[Phone] as Phone,
        [Address] AS Address,
        [City] AS City,
        [State] AS State,
        [Zip] AS Zip,
        [County] AS County,
        [Type] AS Type,
        [Status] AS Status,
        [Issue Date] AS Issue_Date,
        [Capacity] AS Capacity,
        [Email Address] AS Email_Address,
        [Facility ID] AS Facility_ID,
        [Monitoring Frequency] AS Monitoring_Frequency,
        [Infant] AS Infant,
        [Toddler] AS Toddler,
        [Preschool] AS Preschool,
        [School] AS School,
		Case when phone in (select phone from Texas_DHHS where load_date = (SELECT MAX(load_date) FROM Texas_DHHS) group by phone having count(phone)>1) Then 'Multi' else 'Single' end as lead_type,
        [filename] AS filename,
        [load_date] AS load_date
        FROM Texas_DHHS
        WHERE load_date = (SELECT MAX(load_date) FROM Texas_DHHS)
GO


