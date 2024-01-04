-- Data Exploration

SELECT TOP (1000) *
FROM [Projects].[dbo].[sba_public_data]

-- What is the summary of all approved PPP loans

SELECT
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data

-- Summary of Approved PPP Loans (Yearly)

SELECT
	YEAR (DateApproved) Year_Approved, 
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data
Where YEAR(DateApproved) = 2020
Group By YEAR(DateApproved)

UNION

SELECT
	YEAR (DateApproved) Year_Approved, 
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data
Where YEAR(DateApproved) = 2021
Group By YEAR(DateApproved)

-- Summary of Approved PPP Loans AND Distinct Originationg Lenders of the Loan (Yearly)

SELECT
	YEAR (DateApproved) Year_Approved, 
	COUNT(Distinct OriginatingLender) Distinct_Originating_Lender,
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data
Where YEAR(DateApproved) = 2020
Group By YEAR(DateApproved)

UNION

SELECT
	YEAR (DateApproved) Year_Approved, 
	COUNT(Distinct OriginatingLender) Distinct_Originating_Lender,
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data
Where YEAR(DateApproved) = 2021
Group By YEAR(DateApproved)

-- Top 15 Originating Lenders by loan count, total amount and average in Year 2020

SELECT Top 15
	OriginatingLender,
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data
Where YEAR(DateApproved) = 2020
Group By OriginatingLender
Order By Approved_Amount Desc

-- Top 15 Originating Lenders by loan count, total amount and average in Year 2021

SELECT Top 15
	OriginatingLender,
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data
Where YEAR(DateApproved) = 2021
Group By OriginatingLender
Order By Approved_Amount Desc

-- Top 20 Sectors that received PPP loans AND Percentage of Amount Received by a Sector in Year 2020

With CTE2020 as 
(
SELECT Top 20
	d.Sector,
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data p
Inner Join Projects..sba_naics_codes_description d
	On Left(p.NAICSCode, 2) = d.LookupCodes
Where YEAR(DateApproved) = 2020
Group By d.Sector
--Order By 3 Desc
)

Select Sector, Number_of_Approved, Approved_Amount, Average_loan_size, 
	(Approved_Amount / SUM (Approved_Amount) Over()) * 100 Percent_Amount
From CTE2020
Order By Approved_Amount Desc

-- Top 20 Sectors that received PPP loans AND Percentage of Amount Received by a Sector in Year 2021

With CTE2021 as 
(
SELECT Top 20
	d.Sector,
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data p
Inner Join Projects..sba_naics_codes_description d
	On Left(p.NAICSCode, 2) = d.LookupCodes
Where YEAR(DateApproved) = 2021
Group By d.Sector
--Order By 3 Desc
)

Select Sector, Number_of_Approved, Approved_Amount, Average_loan_size, 
	(Approved_Amount / SUM (Approved_Amount) Over()) * 100 Percent_Amount
From CTE2021
Order By Approved_Amount Desc

-- How much of a PPP Loan amount has been Fully Forgiven (Yearly)

SELECT
	YEAR(DateApproved),
	COUNT (LoanNumber) Number_of_Approved,
	SUM (CurrentApprovalAmount) Current_Approved_Amount,
	AVG (CurrentApprovalAmount) Current_Average_loan_size,
	SUM (ForgivenessAmount) Amount_Forgiven,
	(SUM (ForgivenessAmount) / SUM (CurrentApprovalAmount)) * 100 as Percent_Forgiven
FROM Projects..sba_public_data
Where YEAR(DateApproved) = 2020
Group By YEAR(DateApproved)

UNION

SELECT
	YEAR(DateApproved),
	COUNT (LoanNumber) Number_of_Approved,
	SUM (CurrentApprovalAmount) Current_Approved_Amount,
	AVG (CurrentApprovalAmount) Current_Average_loan_size,
	SUM (ForgivenessAmount) Amount_Forgiven,
	(SUM (ForgivenessAmount) / SUM (CurrentApprovalAmount)) * 100 as Percent_Forgiven
FROM Projects..sba_public_data
Where YEAR(DateApproved) = 2021
Group By YEAR(DateApproved)

-- Year and Month with highest PPP loans Approved

SELECT
	YEAR (DateApproved) Year_Approved,
	MONTH (DateApproved) Month_Approved,
	COUNT (LoanNumber) Number_of_Approved,
	SUM (InitialApprovalAmount) Total_Approved_Amount,
	AVG (InitialApprovalAmount) Average_loan_size
FROM Projects..sba_public_data
Group By YEAR(DateApproved), MONTH(DateApproved)
Order By Total_Approved_Amount Desc
