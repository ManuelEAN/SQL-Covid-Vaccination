-- Showcasing both tables
--Select *
--From [Covid Project]..CovidDeaths
--order by 3,4
--Select *
--From [Covid Project]..CovidVacc
--order by 3,4

-- Select the data to be used
Select location,date,total_cases,new_cases,total_deaths,population
From [Covid Project]..CovidDeaths
Where continent is not null
order by 1,2

-- Total cases vs Total Deaths

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Project]..CovidDeaths
Where location like '%Venezuela%' 
order by 1,2

-- Total cases vs Population
Select location,date,total_cases,population, (total_cases/population)*100 as CasePercentageByPoplation
From [Covid Project]..CovidDeaths
Where location like '%Venezuela%'
order by 1,2

-- Contries with highest infection rate compare to Population

Select location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population)*100) as CasePercentageByPoplation
From [Covid Project]..CovidDeaths
Where continent is not null
Group by population, location
order by CasePercentageByPoplation desc

-- Contries with highest death count compare to Population

Select location, MAX(cast(total_deaths as int)) as highestdeaths
From [Covid Project]..CovidDeaths
Where continent is not null
Group by location
order by highestdeaths desc

-- Deaths by continents 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid Project]..CovidDeaths
where continent is not null 



------------------------------(JOINED) Total population vs Total vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to Calculate on Partition By of previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfPeopleVaccinated
From PopvsVac



-- Creating View to store data for later visualizations

Create View PopulationPercentageVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVacc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
