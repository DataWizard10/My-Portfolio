--EN ESTE PROYECTO SE DESCARGA UNA BASE DE DATOS SOBRE EL STATUS
--DE CONTAGIO DE COVID-19 A NIVEL GLOBAL DE LA PAGINA: https://ourworldindata.org/covid-deaths
--SE REALIZA UN ANALISIS PREELIMINAR DE LA BASE DE DATOS, SE CARGA EN SQL
--Y SE OBTIENEN DIVERSOS PORCENTAJES MEDIANTE EL USO DE CONSULTAS EN SQL
--QUE EXTRAEN INFORMACION RELEVANTE SOBRE EL CONTAGIO, VACUNACION CASOS NUEVOS Y DECESOS.

SELECT * FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$'] 
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM [PORTFOLLIO PROJECT 1]..['COVID VACCINATIONS$']
--ORDER BY 3,4

--SELECCIONA DE MANERA GENERAL LOS DATOS QUE SE UTILIZARÁN
SELECT Location, date, CAST(total_cases AS float), CAST(new_cases AS float), CAST(total_deaths AS float), population
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent is not null
order by 1,2

--MUESTRA EL PORCENTAJE DE CASOS TOTALES CONTRA LOS CASOS FATALES
--MUESTRA LA PROBABILIDAD DE FALLECER EN CASO DE CONTAGIO
--DE ACUERDO A CADA PAIS
SELECT Location, date, CAST(total_cases AS float), CAST(total_deaths AS float), (CAST(total_deaths AS float) / CAST(total_cases AS float)*100) AS DEATHPERCENTAGE
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent is not null --AND location = 'Mexico'
order by 1,2

--MUESTRA EL PORCENTAJE DE CASOS TOTALES CONTRA LA POBLACION TOTAL
--DESCRIBE EL PORCENTAJE DE LA POBLACION CONTAGIADA DE COVID-19 EN CADA PAIS
SELECT Location, date, CAST(total_cases AS float), population, (CAST(total_cases AS float) / CAST(population AS float)*100) AS PercentPopulationInfected
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent is not null --AND location = 'Mexico'
order by 1,2

--MUESTRA LOS PAISES CON MAYOR TASA DE CONTAGIO COMPARADO CON SU POBLACION
SELECT Location, Population, MAX(CAST(total_cases AS float)) AS HighestInfectionCount, (CAST(MAX(total_cases) AS float) / CAST(MAX(population) AS float)*100) AS MaxPercentPopulationInfected
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent is not null --AND location = 'Mexico'
GROUP BY location, population
order by MaxPercentPopulationInfected desc

--MUESTRA LOS PAISES CON MAYOR PORCENTAJE DE FALLECIMIENTOS
SELECT Location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount--, (MAX(CAST(total_deaths AS float)) / MAX(CAST(population AS float))*100) AS MaxPercentDeceasedPopulation
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount desc

--MUESTRA LOS CONTINENTES CON MAYOR PORCENTAJE DE FALLECIMIENTOS
SELECT continent, MAX(CAST(total_deaths AS float)) AS ContinentalTotalDeathCount--, (MAX(CAST(total_deaths AS float)) / MAX(CAST(population AS float))*100) AS MaxPercentDeceasedPopulation
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent IS not NULL
GROUP BY continent
order by ContinentalTotalDeathCount desc

--MUERTES, CASOS Y PORCENTAJE DE FALLECIMIENTO (A NIVEL GLOBAL)
SELECT date, SUM(CAST(new_cases AS float)) AS World_Total_Cases, SUM(CAST(new_deaths AS float)) AS World_Total_Deaths, (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 AS World_Death_Percentage
FROM [PORTFOLLIO PROJECT 1]..['COVID DEATHS$']
WHERE continent IS NOT NULL
GROUP BY date
order by 1, 2


--CONSULTAMOS EL PORCENTAJE DE LA POBLACION TOTAL QUE ESTA VACUNADA
--CREAMOS UNA TABLA TEMPORAL QUE SERA UTILIZADA INMEDIANTAMENTE PARA FACILITAR EL CALCULO

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

--CREAMOS UNA VISTA QUE SERA UTILIZADA EN UNA VISUALIZACION

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