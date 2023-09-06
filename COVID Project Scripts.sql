Select *
from CovidProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from CovidProject..CovidVaccinations
--order by 3,4

ALTER TABLE CovidProject..CovidDeaths 
ALTER COLUMN new_deaths NUMERIC NULL

SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM CovidProject..CovidDeaths
order by 1, 2

-- 1.
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidProject..CovidDeaths
where location like '%states%'
order by 1, 2


-- 2.
-- Looking at countries with highest infection rate compared to population by date
-- Shows what percentage of population got covid
SELECT Location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
FROM CovidProject..CovidDeaths
--where location like '%states%'
GROUP BY Location, population, date
ORDER BY PercentPopulationInfected DESC

-- 3.
-- Looking at countries with highest infection rate compared to population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- 4.
--Showing countries with highest death count per population
SELECT Location, MAX(total_deaths) as TotalDeathCount 
FROM CovidProject..CovidDeaths
where continent is not null
GROUP BY location
order by TotalDeathCount desc

-- 5.
-- Showing total death count for each continent
SELECT location, SUM(total_deaths) AS TotalDeathCount 
FROM CovidProject..CovidDeaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


-- Global numbers
-- 6. 
-- Shows global death percentage for each date
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage 
FROM CovidProject..CovidDeaths
where continent is not null
group by date
order by 1, 2
-- Shows total death percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage 
FROM CovidProject..CovidDeaths
where continent is not null
order by 1, 2


-- Looking at total population vs vaccinations
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--FROM CovidProject..CovidDeaths as dea
--JOIN CovidProject..CovidVaccinations as vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

-- 7.
-- Looking at total population vs vaccinations
-- USE CTE
With PopVsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, CAST(dea.population AS numeric), vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
	FROM CovidProject..CovidDeaths as dea
	JOIN CovidProject..CovidVaccinations as vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population) * 100
FROM PopVsVac


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, CAST(dea.population AS numeric) as population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
	FROM CovidProject..CovidDeaths as dea
	JOIN CovidProject..CovidVaccinations as vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated