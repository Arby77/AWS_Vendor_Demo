USE [aws_demo]
GO

/****** Object:  View [dbo].[vu_Oklahoma_Human_Services]    Script Date: 10/29/2023 11:01:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

        CREATE VIEW [dbo].[vu_Oklahoma_Human_Services] AS
        SELECT 
        [Type License] AS Type_License,
        [Company] AS Company,
        Case when ISNULL([Accepts Subsidy],'') = 'Accepts Subsidy' Then 'Y' else 'N' end AS Accepts_Subsidy,
		Case when ISNULL([Year Round],'') = 'Year Round' Then 'Y' else 'N' end AS Year_Round,
		Case when ISNULL([Daytime Hours],'') = 'Daytime Hours' Then 'Y' else 'N' end AS Daytime_Hours,
        [Star Level] AS Star_Level,
        [Mon] AS Mon,
        [Tues] AS Tues,
        [Wed] AS Wed,
        [Thurs] AS Thurs,
        [Friday] AS Friday,
        [Saturday] AS Saturday,
        [Sunday] AS Sunday,
        [Primary Caregiver] AS Primary_Caregiver,
		[Phone] as Phone,
        [Email] AS Email,
        [Address] AS Address,
        [Address2] AS Address2,
        [City] AS City,
        [State] AS State,
        [Zip] AS Zip,
        Replace([Subsidy Contract Number], 'Subsidy Contract Number: ', '') AS Subsidy_Contract_Number,
        [Total Cap] AS Total_Cap,
        [Ages Accepted 1] AS Ages_Accepted_1,
        [AA2] AS AA2,
        [AA3] AS AA3,
        [AA4] AS AA4,
        Replace([License Monitoring Since], 'Monitoring Since ', '') AS License_Monitoring_Since,
        Case when [School Year Only] = 'Year Round' then 'Year Round'
			 when [School Year Only] = 'School Year Only' then 'School Year Only'
		end as School_Year_Only,
        Case when ISNULL([Evening Hours],'') = 'Evening Hours' Then 'Y' else 'N' end AS Evening_Hours,
		Case when phone in (select phone from Oklahoma_Human_Services where load_date = (SELECT MAX(load_date) FROM Oklahoma_Human_Services) group by phone having count(phone)>1) Then 'Multi' else 'Single' end as lead_type,
        [filename] AS filename,
        [load_date] AS load_date
        FROM Oklahoma_Human_Services
        WHERE load_date = (SELECT MAX(load_date) FROM Oklahoma_Human_Services)
        
GO


