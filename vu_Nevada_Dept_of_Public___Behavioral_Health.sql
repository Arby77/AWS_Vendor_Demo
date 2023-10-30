USE [aws_demo]
GO

/****** Object:  View [dbo].[vu_Nevada_Dept_of_Public___Behavioral_Health]    Script Date: 10/29/2023 11:01:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

        CREATE VIEW [dbo].[vu_Nevada_Dept_of_Public___Behavioral_Health] AS
        SELECT 
        [Name] AS Name,
        [Credential Type] AS Credential_Type,
        [Credential Number] AS Credential_Number,
        [Status] AS Status,
        [Expiration Date] AS Expiration_Date,
        [Disciplinary Action] AS Disciplinary_Action,
        [Address] AS Address,
        [State] AS State,
        [County] AS County,
        [First Issue Date] AS First_Issue_Date,
        [Primary Contact Name] AS Primary_Contact_Name,
        [Primary Contact Role] AS Primary_Contact_Role,
        [Phone] AS Phone,
        [Address_full] AS Address_full,
		Case when phone in (select phone from Nevada_Dept_of_Public___Behavioral_Health where load_date = (SELECT MAX(load_date) FROM Nevada_Dept_of_Public___Behavioral_Health) group by phone having count(phone)>1) Then 'Multi' else 'Single' end as lead_type,
        [filename] AS filename,
        [load_date] AS load_date
        FROM Nevada_Dept_of_Public___Behavioral_Health
        WHERE load_date = (SELECT MAX(load_date) FROM Nevada_Dept_of_Public___Behavioral_Health)
        
GO


