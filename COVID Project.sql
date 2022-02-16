SELECT *
FROM PortfolioProject.dbo.['CovidDeaths']
Order by 3,4

SELECT *
FROM PortfolioProject.dbo.['CovidVaccinations']
Order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.['CovidDeaths']
Order by 1,2

--Total Cases vs Total Deaths
--Shows likelihood of death if Covid is contracted

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.['CovidDeaths']
Where location like '%canada%'
Order by 1,2

--Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.['CovidDeaths']
Where location like '%canada%'
Order by 1,2

--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.['CovidDeaths']
--Where location like '%canada%'
Group by location, population
Order by 4 DESC

--Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.['CovidDeaths']
--Where location like '%canada%'
Where continent is not null
Group by location
Order by 2 DESC

--Breakdown by Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.['CovidDeaths']
--Where location like '%canada%'
Where continent is not null
Group by continent
Order by 2 DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.['CovidDeaths']
--Where location like '%canada%'
Where continent is not null
Group by date
Order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.['CovidDeaths']
--Where location like '%canada%'
Where continent is not null
Order by 1,2

--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.['CovidDeaths'] dea
JOIN PortfolioProject.dbo.['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.['CovidDeaths'] dea
JOIN PortfolioProject.dbo.['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.['CovidDeaths'] dea
JOIN PortfolioProject.dbo.['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for Visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.['CovidDeaths'] dea
JOIN PortfolioProject.dbo.['CovidVaccinations'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated