-- Exploring the data 

SELECT TOP 10 * 
FROM CovidData..CovidDeaths
ORDER BY 3,4

SELECT TOP 100 Location, date, total_cases, new_cases, total_deaths, population
FROM CovidData..CovidDeaths
ORDER BY 1,2;


-- Convert datatypes

ALTER TABLE CovidData..CovidDeaths
ALTER COLUMN total_cases BIGINT;

ALTER TABLE CovidData..CovidDeaths
ALTER COLUMN total_deaths DECIMAL;


-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths * 100/total_cases) as Percentage_death
FROM CovidData..CovidDeaths
where location = 'Nigeria'
ORDER BY 1,2;

SELECT Location, date, total_cases, population, (total_cases * 100/population) as Population_Percentage_Infected
FROM CovidData..CovidDeaths
--where location = 'Nigeria'
ORDER BY 1,2;

SELECT Location, Population, MAX(total_cases) as HighestCovidCount, MAX((total_cases * 100/population)) as Population_Percentage_Infected
FROM CovidData..CovidDeaths
--where location = 'Nigeria'
GROUP BY Location, Population
--having MAX((total_cases * 100/population)) > 25
ORDER BY Population_Percentage_Infected DESC;


--Showing countries with the highest death count per population

SELECT Location, MAX(total_deaths) as HighestDeathCount
FROM CovidData..CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC


--Showing continents with the highest death count per population

SELECT Location as Continent, MAX(total_deaths) as Death_Count
FROM CovidData..CovidDeaths
WHERE CONTINENT IS NULL
GROUP BY Location
ORDER BY Death_Count DESC

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths * 100)/SUM(new_cases) as DeathPercentage
FROM CovidData..CovidDeaths
WHERE continent is not null
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths * 100)/CASE WHEN 
SUM(new_cases) = 0 THEN NULL 
ELSE SUM(new_cases) END as DeathPercentage 
FROM CovidData..CovidDeaths
WHERE continent is not null
group by date
order by 1,2 DESC


-- Showing how much people in a country got vaccinated

SELECT d.date, d.continent, d.location, population, 
v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
OVER (Partition by d.location Order By d.location, d.date) as RollingPeopleVaccinated
FROM CovidData..CovidDeaths as d 
JOIN CovidData..CovidVaccinations as v
ON  d.location = v.location 
AND d.date = v.date 
where d.continent is not null
order by 3,1


--CTE

WITH PopulationVsVaccination (Date, Continent, Location, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.date, d.continent, d.location, population, 
v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
OVER (Partition by d.location Order By d.location, d.date) as RollingPeopleVaccinated
FROM CovidData..CovidDeaths as d 
JOIN CovidData..CovidVaccinations as v
ON  d.location = v.location 
AND d.date = v.date 
where d.continent is not null
)
Select *, (RollingPeopleVaccinated *100 / Population) as PeopleVaccinatedPercentage
From PopulationVsVaccination
order by 3,1


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Date datetime,
Continent nvarchar (255),
Location nvarchar (255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT d.date, d.continent, d.location, population, 
v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
OVER (Partition by d.location Order By d.location, d.date) as RollingPeopleVaccinated
FROM CovidData..CovidDeaths as d 
JOIN CovidData..CovidVaccinations as v
ON  d.location = v.location 
AND d.date = v.date 
where d.continent is not null

Select *, (RollingPeopleVaccinated *100 / Population) as PeopleVaccinatedPercentage
From #PercentPopulationVaccinated
order by 3,1


--CREATE VIEW

--DROP TABLE IF EXISTS PercentPopulationVaccinated
Create View
PercentPopulationVaccinated AS
SELECT d.date, d.continent, d.location, population, 
v.new_vaccinations, SUM(CONVERT(bigint, v.new_vaccinations)) 
OVER (Partition by d.location Order By d.location, d.date) as RollingPeopleVaccinated
FROM CovidData..CovidDeaths as d 
JOIN CovidData..CovidVaccinations as v
ON  d.location = v.location 
AND d.date = v.date 
where d.continent is not null
--order by 3,1

Select *, (RollingPeopleVaccinated *100 / Population) as PeopleVaccinatedPercentage
From PercentPopulationVaccinated
order by 3,1