-- Data Cleaning
-- Finding Null values

Select *
From Projects..sba_industry_standards
Where NAICS_Codes = ''

-- Substring, If Statement

Select NAICS_Industry_Description, 
	iif ( NAICS_Industry_Description like '%–%', SUBSTRING(NAICS_Industry_Description, 8, 2), '') LookupCodes
From Projects..sba_industry_standards
Where NAICS_Codes = ''

-- Selecting perticular output, Deselecting Null values

Select *
From (
	Select NAICS_Industry_Description, 
		iif ( NAICS_Industry_Description like '%–%', SUBSTRING(NAICS_Industry_Description, 8, 2), '') LookupCodes
	From Projects..sba_industry_standards
	Where NAICS_Codes = ''
) main
Where LookupCodes != ''

-- Extracting Sector Description

Select *
From (
	Select NAICS_Industry_Description, 
		iif ( NAICS_Industry_Description like '%–%', SUBSTRING(NAICS_Industry_Description, 8, 2), '') LookupCodes,
		iif ( NAICS_Industry_Description like '%–%', SUBSTRING(NAICS_Industry_Description, CHARINDEX ('–', NAICS_Industry_Description) + 2, LEN (NAICS_Industry_Description)), '') Sector
	From Projects..sba_industry_standards
	Where NAICS_Codes = ''
) main
Where LookupCodes != ''

-- Creating new table

Select *
Into sba_naics_codes_description
From (
	Select NAICS_Industry_Description, 
		iif ( NAICS_Industry_Description like '%–%', SUBSTRING(NAICS_Industry_Description, 8, 2), '') LookupCodes,
		iif ( NAICS_Industry_Description like '%–%', SUBSTRING(NAICS_Industry_Description, CHARINDEX ('–', NAICS_Industry_Description) + 2, LEN (NAICS_Industry_Description)), '') Sector
	From Projects..sba_industry_standards
	Where NAICS_Codes = ''
) main
Where LookupCodes != ''

-- Moving Codes from Sector

Select *
From Projects..sba_naics_codes_description
Order by LookupCodes
Insert Into Projects..sba_naics_codes_description
Values 
  ('Sector 31 – 33 – Manufacturing', 32, 'Manufacturing'), 
  ('Sector 31 – 33 – Manufacturing', 33, 'Manufacturing'), 
  ('Sector 44 - 45 – Retail Trade', 45, 'Retail Trade'),
  ('Sector 48 - 49 – Transportation and Warehousing', 49, 'Transportation and Warehousing')

Update Projects..sba_naics_codes_description
set Sector = 'Manufacturing'
where LookupCodes = 31
