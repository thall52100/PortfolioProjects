SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Selecting the data that will be used.

SELECT Location,date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Observing Total Cases vs Total Deaths
--Shows the likelihood of dying if covid is contracted in the United States
SELECT Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE total_deaths is NOT NULL AND Location like '%states%'
ORDER BY 1,2


--Observing Total Cases vs Population
--Shows what % of population contracted Covid
SELECT Location,date,total_cases, population, (total_cases/population)*100 AS PopulationContractionPercentage
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths is NOT NULL AND Location like '%states%'
ORDER BY 1,2

-- Observing Countries with Highest Infection Rates in Comparison to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationContractionPercentage
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths is NOT NULL AND Location like '%states%'
GROUP BY Location, population
ORDER BY PopulationContractionPercentage DESC




--Observing Countries with Highest Death Count Per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths is NOT NULL AND Location like '%states%'
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

----Break down By Continent
--Observing Continents with the Highest Death Count 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths is NOT NULL AND Location like '%states%'
WHERE Continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT date,SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths is NOT NULL AND Location like '%states%'
WHERE Continent is not null
GROUP by date
ORDER BY 1,2


SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths is NOT NULL AND Location like '%states%'
WHERE Continent is not null
--GROUP by date
ORDER BY 1,2

--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location	
		and dea.date = vac.date
		WHERE dea.continent is NOT NULL
		ORDER BY 2, 3

--USE CTE; Number of Columns has to match in CTE AND first query 
--With PopvsVac  (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
--as
--(

--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location,dea.date) AS RollingPeopleVaccinated
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vac 
--	ON dea.location = vac.location	
--		and dea.date = vac.date
--		WHERE dea.continent is NOT NULL
--		--ORDER BY 2, 3
--		)

--SELECT *, (RollingPeopleVaccinated/population)*100
--FROM PopvsVac

--TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea	
	JOIN PortfolioProject..CovidVaccinations vac 
		ON dea.location = vac.location	
			and dea.date = vac.date
		WHERE dea.continent is NOT NULL
--ORDER BY 2, 3
        

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




--Creating View To Store Data For Later Visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea	
JOIN PortfolioProject..CovidVaccinations vac 
		ON dea.location = vac.location	
			and dea.date = vac.date
	WHERE dea.continent is NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated
















