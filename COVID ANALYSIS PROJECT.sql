--In this project, a database is downloaded from the website https://ourworldindata.org/covid-deaths 
--containing information on the status of COVID-19 infections worldwide. A preliminary analysis of 
--the database is performed, it is loaded into SQL, and various percentages are obtained using SQL 
--queries that extract relevant information about infections, vaccinations, new cases, and deaths.


SELECT * FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$'] 
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM [PORTFOLLIO PROJECT 1]..['COVID VACCINATIONS$']
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING
SELECT Location, date, CAST(total_cases AS float), CAST(new_cases AS float), CAST(total_deaths AS float), population
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent is not null
order by 1,2

--looking at total cases vs total deaths
-- Shows the likelyhood of dying if you contract COVID in your country
SELECT Location, date, CAST(total_cases AS float), CAST(total_deaths AS float), (CAST(total_deaths AS float) / CAST(total_cases AS float)*100) AS DEATHPERCENTAGE
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent is not null --AND location = 'Mexico'
order by 1,2

--Looking at total cases vs population
--PERCENTAGE OF POPULATION DIAGNOSTED WITH COVID
SELECT Location, date, CAST(total_cases AS float), population, (CAST(total_cases AS float) / CAST(population AS float)*100) AS PercentPopulationInfected
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent is not null --AND location = 'Mexico'
order by 1,2

--LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location, Population, MAX(CAST(total_cases AS float)) AS HighestInfectionCount, (CAST(MAX(total_cases) AS float) / CAST(MAX(population) AS float)*100) AS MaxPercentPopulationInfected
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent is not null --AND location = 'Mexico'
GROUP BY location, population
order by MaxPercentPopulationInfected desc

--Showing countries with highest death count per population,
SELECT Location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount--, (MAX(CAST(total_deaths AS float)) / MAX(CAST(population AS float))*100) AS MaxPercentDeceasedPopulation
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount desc

--Showing CONTINENTS with highest death count per population,
SELECT continent, MAX(CAST(total_deaths AS float)) AS ContinentalTotalDeathCount--, (MAX(CAST(total_deaths AS float)) / MAX(CAST(population AS float))*100) AS MaxPercentDeceasedPopulation
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent IS not NULL
GROUP BY continent
order by ContinentalTotalDeathCount desc

--GLOBAL NUMBERS (deaths, cases and percentage deaths vs cases
SELECT date, SUM(CAST(new_cases AS float)) AS World_Total_Cases, SUM(CAST(new_deaths AS float)) AS World_Total_Deaths, (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 AS World_Death_Percentage
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent IS NOT NULL
GROUP BY date
order by 1, 2


--looking at total populations vs vaccinations
--USE CTE

WITH Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations) as 
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS float)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as CumulativeVaccinations
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$'] as DEA
JOIN [PORTFOLLIO PROJECT 1]..['COVID VACCINATIONS$'] AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = DEA.date
WHERE DEA.continent IS NOT NULL
)
SELECT *, (CumulativeVaccinations/Population)*100 FROM Pop_vs_Vac

--Creating a view to store data for later visualizations

--drop view viewcumulative if exists viewcumulative
create view visualCumulativeVaccinations as
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CAST(VAC.new_vaccinations AS float)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as CumulativeVaccinations
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$'] as DEA
JOIN [PORTFOLLIO PROJECT 1]..['COVID VACCINATIONS$'] AS VAC
	ON DEA.location = VAC.location
	AND DEA.date = DEA.date
WHERE DEA.continent IS NOT NULL

drop view visualCumulativeVaccinations

select * from visualCumulativeVaccinations