USE [aws_demo]
GO

/****** Object:  View [dbo].[vu_AWS_Vendor_Transform]    Script Date: 10/29/2023 11:02:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view  [dbo].[vu_AWS_Vendor_Transform] as
select 
null as accepts_financial_aid,
null as ages_served,
null as capacity,
cast(expiration_date as date) as certificate_expiration_date,
UPPER((select top 1 official_usps_city_name from [geo_data] where zip_code = RIGHT(TRIM(address_full), 5))) as city,
address,
Case when lead_type = 'Multi' Then (select top 1 s1.address from [vu_Nevada_Dept_of_Public___Behavioral_Health] s1 where s1.address <> s.address and s1.phone = s.phone) end as address2,
name as company,
county,
credential_type as cirriculum_type,
null as email,
primary_contact_name as name,
null as language,
lead_type,
case when status = '' then 'inactive' else status end as license_status,
case when rtrim(ltrim(first_issue_date)) = '' then null else cast(first_issue_date as date) end as license_issued,
null as license_number,
null as license_renewed,
credential_type as license_type,
null as license_name,
state,
null as website_address,
RIGHT(TRIM(address_full), 5) as zip
from [vu_Nevada_Dept_of_Public___Behavioral_Health] s

union 

select 
null as accepts_financial_aid,
case when infant = 'Y' then 'Infants (0-11 months),' else '' end +
case when toddler = 'Y' then 'Toddlers (12-23 months; 1yr.),' else '' end + 
case when preschool = 'Y' then 'Preschool (24-48 months; 2-4 yrs.),' else '' end +
case when school = 'Y' then 'School-age (5 years-older)' else '' end
as ages_served,
Case when isnumeric(capacity) = 1 then cast(capacity as numeric) else null end as capacity,
null as certificate_expiration_date,
city,
address,
Case when lead_type = 'Multi' Then (select top 1 s1.address from [vu_Texas_DHHS] s1 where s1.address <> s.address and s1.phone = s.phone) end as address2,
operation_caregiver_name as company,
county,
null as cirriculum_type,
email_address as email,
null as name,
null as language,
lead_type,
case when status = '' then 'inactive' else status end as license_status,
case when rtrim(ltrim(issue_date)) = '' then null else cast(issue_date as date) end as license_issued,
null as license_number,
null as license_renewed,
type as license_type,
null as license_name,
state,
null as website_address,
zip
from [vu_Texas_DHHS] s

union 

select 
Accepts_Subsidy as accepts_financial_aid,
case when isnull(Ages_accepted_1,'') <> '' then Ages_Accepted_1 + ',' else '' end +
case when isnull(AA2,'') <> '' then AA2 + ',' else '' end +
case when isnull(AA3,'') <> '' then AA3 + ',' else '' end +
case when isnull(AA4,'') <> '' then AA4 else '' end
as ages_served,
total_cap as capacity,
null as certificate_expiration_date,
city,
address,
Case when lead_type = 'Multi' Then (select top 1 s1.address from [vu_Oklahoma_Human_Services] s1 where s1.address <> s.address and s1.phone = s.phone) end as address2,
Company,
(select top 1 primary_official_county_name from geo_data where zip_code = zip) as county,
star_level as cirriculum_type,
email,
replace(
		replace(primary_caregiver, 'Primary Caregiver', '')
		,'Director'
		,''
		) as name,
null as language,
lead_type,
case when isnull(type_license,'') <> '' then 'active' else 'inactive' end as license_status,
case when rtrim(ltrim(license_monitoring_since)) = '' then null else cast(license_monitoring_since as date) end as license_issued,
null as license_number,
null as license_renewed,
type_license as license_type,
null as license_name,
state,
null as website_address,
zip
from [vu_Oklahoma_Human_Services] s
GO


