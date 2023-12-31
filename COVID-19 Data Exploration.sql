--Data Exploration from Deaths Table

Select*
From [Covid-19]..Deaths
Where continent is not null
Order by 3,4

--Selecting Few Perticular Columns

Select location, date, total_cases, new_cases, total_deaths, population
From [Covid-19]..Deaths
Where continent is not null
Order by 1,2

--Mortality Rate Calculation (Total Cases VS Total Deaths in a perticuler country)

Select 
	location as Country, 
	date, 
	total_deaths, 
	total_cases, 
	(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercetage
From [Covid-19]..Deaths
Where continent is not null
and location like '%india%' -- Change the Country as needed.
order by 1,2

--Total cases VS Population in a Country

Select 
	location as Country, 
	date, 
	Population, 
	total_cases, 
	(cast(total_cases as float)/population)*100 as PercetagePopulationInfacted
From [Covid-19]..Deaths
Where continent is not null
and location like '%india%' -- Change the Country as needed.
order by 1,2

--Countries with Highest Infaction Rate VS Population

Select 
	Location as Country, 
	Population, 
	MAX(total_cases) as HighestInfectionCount, 
	Max((total_cases/population))*100 as PercetagePopulationInfacted
From [Covid-19]..Deaths
Where continent is not null
Group by Location, Population
order by PercetagePopulationInfacted desc

-- Percetage of Population Died because of Covid by Country

Select 
	location as Country, 
	population, 
	MAX(total_deaths) as TotalDeathCount, 
	MAX((total_deaths/population))*100 as PercentagePopulationDied
From [Covid-19]..Deaths
Where continent is not null
Group by location, population
Order by PercentagePopulationDied desc

---- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid-19]..Deaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Showing contintents with the highest death count per population
-- Showing total deaths all around the world

Select location as Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid-19]..Deaths
Where continent is null
Group by location
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select 
	MAX(cast(total_cases as int)) as total_cases, 
	MAX(cast(total_deaths as float)) as total_deaths, 
	MAX(cast(total_deaths as float))/MAX(cast(total_cases as int))*100 as DeathPercetage
From [Covid-19]..Deaths
Where location like '%world%'

--Total patients in Hospital VS Population

Select 
	location as Country, 
	population, 
	SUM(cast(hosp_patients as int)) as HospitalizedPeopleCount, 
	(SUM(cast(hosp_patients as int))/population)*100 as HospitalizedPeoplePercent
From [Covid-19]..Deaths
Where continent is not null
Group by location, population
Order by HospitalizedPeoplePercent desc

-- Calculate the hospitalization rate for each country

SELECT 
	location AS Country, 
	(SUM(CAST(hosp_patients AS FLOAT)) / SUM(CAST(total_cases AS FLOAT)))*100 AS HospitalizationRate
FROM [Covid-19]..Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HospitalizationRate DESC;

-- Identify countries where hospitals are overwhelmed

SELECT 
	location AS Country, 
	(SUM(CAST(hosp_patients AS FLOAT)) / population) * 100 AS HospitalizationPercentage
FROM [Covid-19]..Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING (SUM(CAST(hosp_patients AS FLOAT)) / population) * 100 > 5.0  -- Adjust the threshold as needed (e.g., 0.4%)
ORDER BY HospitalizationPercentage DESC;

--Total patients with Serious Health Condition VS Population

Select 
	location as Country, 
	population, 
	SUM(cast(icu_patients as int)) as IcuPeopleCount, 
	(SUM(cast(icu_patients as int))/population)*100 as IcuPatientPercent
From [Covid-19]..Deaths
Where continent is not null
Group by location, population
Order by IcuPatientPercent desc

-- Calculate the percentage of patients in ICU among hospitalized patients

Select 
	location as Country, 
	(SUM(CAST(hosp_patients AS int))) as TotalHospitalizedPatients,
	(SUM(CAST(icu_patients AS int))) as TotalIcuPatients,
	(SUM(cast(icu_patients as float))/SUM(CAST(hosp_patients AS float)))*100 as PercentageInIcu
From [Covid-19]..Deaths
Where continent is not null
Group by location
Order by PercentageInICU DESC

--Data Exploration from Vaccine Table

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

-- Using CTE to perform Calculation on Partition By in query

With PopVSVac (continent, location, date, population, new_vaccineations, RollingVaccination)
as (

Select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CONVERT(float, v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingVaccination
From [Covid-19]..Deaths d
Join [Covid-19]..Vaccine v
	On d.location = v.location
	and d.date = v.date
WHere d.continent is not null
	)

Select *, (RollingVaccination/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations, 
	SUM(CONVERT(float, v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingVaccination
From [Covid-19]..Deaths d
Join [Covid-19]..Vaccine v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 

Select *, (RollingVaccination/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Go
Create View VaccinationPercent as 
Select 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CONVERT(float, v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingVaccination
From [Covid-19]..Deaths d
Join [Covid-19]..Vaccine v
	On d.location = v.location
	and d.date = v.date
WHere d.continent is not null;
Go