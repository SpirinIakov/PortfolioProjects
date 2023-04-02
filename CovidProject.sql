---------------------------------------------------------------------------------------------------------------------------
-- CovidProject
---------------------------------------------------------------------------------------------------------------------------

-- Test
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


---------------------------------------------------------------------------------------------------------------------------
-- [1] Total cases VS Total Deaths 
---------------------------------------------------------------------------------------------------------------------------

-- Shows the likelihood of dying if you contract covid in your country (in this case, Belgium)
SELECT location, date, total_cases,total_deaths, (try_convert(float, total_deaths)/try_convert(float, total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Belgium%'
ORDER BY 1,2


---------------------------------------------------------------------------------------------------------------------------
-- [2] Total Cases VS population
---------------------------------------------------------------------------------------------------------------------------

-- Percentage of population that got Covid in the world / your country.
SELECT location, population, date, total_cases, (try_convert(float, total_cases)/try_convert(float, population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Belgium%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (try_convert(float, MAX(total_cases))/try_convert(float, population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Belgium%'
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Belgium%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Counts
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Belgium%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


---------------------------------------------------------------------------------------------------------------------------
-- [3] Global Numbers: percentage of death from COVID.
---------------------------------------------------------------------------------------------------------------------------

-- Total amount of people in the world that have died from COVID.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Belgium%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


---------------------------------------------------------------------------------------------------------------------------
-- [4] Total Population VS Vaccinations
---------------------------------------------------------------------------------------------------------------------------

-- Total amount of people in the world that have been vaccinated.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date ) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population) * 100 AS percentage_vaccinated_people
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated -- add this in case I would like to make any changes to my temp table.
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date ) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
-- WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/population) * 100 AS percentage_vaccinated_people
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations. 
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date ) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated
