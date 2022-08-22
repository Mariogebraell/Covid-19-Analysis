SELECT *
FROM Project..CovidDeath
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM Project..CovidVaccination$
--ORDER BY 3,4


-- Select Data That we are going to be using
SELECT location, continent, date, total_cases, new_cases, total_deaths, population
FROM Project..CovidDeath
WHERE continent is not null
ORDER BY 1,2



-- Looking at total cases VS Total Deaths
-- Shows Likelihood of dying if you contract covid in your country
SELECT location, continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Project..CovidDeath
WHERE location Like '%lebanon%' 
and continent is not null
ORDER BY 1,2



-- Looking at Total Cases vs population
-- Shows what percentage of population got Covid
SELECT location, continent, date, total_cases, population, (total_cases/population)*100 AS Percentage
FROM Project..CovidDeath
WHERE location Like '%lebanon%'
and continent is not null
ORDER BY 1,2


--- looking at countries with Highest Infection rate compared to population
SELECT location, continent, population, MAX(total_cases) AS highestinfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Project..CovidDeath
GROUP BY  population, continent, location
ORDER BY PercentPopulationInfected DESC



-- showing countries highest death count pre population
SELECT location, continent, MAX(Cast(total_deaths as int)) AS highestDeathCount
FROM Project..CovidDeath
WHERE continent is not null
GROUP BY continent, location
ORDER BY highestDeathCount DESC

-- Showing the continents with the highest death count per population
SELECT continent, MAX(Cast(total_deaths as int)) AS highestDeathCount
FROM Project..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY highestDeathCount DESC


--Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM Project..CovidDeath
WHERE continent is NOT null
--GROUP BY date
ORDER BY DeathPercentage DESC -- ORDER BY 1,2 this is how alex did it, WHY we can't order it by deathpercentage?


--looking at total population vs Vaccination

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (Partition by d.Location order by d.location, d.Date) as RollingPeopleVaccinated
FROM Project..CovidDeath AS d
 JOIN Project..CovidVaccination$ AS v
  ON d.location = v.location
  AND d.date = v.date
WHERE d.continent is NOT null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (Partition by d.Location order by d.location, d.Date) as RollingPeopleVaccinated
FROM Project..CovidDeath AS d
 JOIN Project..CovidVaccination$ AS v
  ON d.location = v.location
  AND d.date = v.date
WHERE d.continent is NOT null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationvaccinated
FROM PopvsVac





--Temp Table
-- DROP TABLE IF exists #PercentPopulationvaccinated
create table #PercentPopulationvaccinated
( 
 continent nvarchar(255),
 Location nvarchar(255), 
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

INSERT INTO #PercentPopulationvaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (Partition by d.Location order by d.location, d.Date) as RollingPeopleVaccinated
FROM Project..CovidDeath AS d
 JOIN Project..CovidVaccination$ AS v
  ON d.location = v.location
  AND d.date = v.date
--WHERE d.continent is NOT null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationvaccinated




--Creating View to store data for later Visualization
Create View PercentPopulationvaccinated as 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) OVER (Partition by d.Location order by d.location, d.Date) as RollingPeopleVaccinated
FROM Project..CovidDeath AS d
 JOIN Project..CovidVaccination$ AS v
  ON d.location = v.location
  AND d.date = v.date
WHERE d.continent is NOT null
--ORDER BY 2,3

SELECT *
from PercentPopulationvaccinated