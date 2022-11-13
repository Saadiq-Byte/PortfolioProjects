SELECT *
From potfolioProject..CovidDeaths
order by 3,4

--Select *
--From potfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PotfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases Vs Total Deaths
--shows likehood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PotfolioProject..CovidDeaths
where location like '%nigeria'
order by 1,2 

--Looking at the total cases Vs Population
--shows what percentage of population got covid

Select Location, date, population, total_cases,(total_cases/population)*1000 as PercentagePopulationInfected
from PotfolioProject..CovidDeaths
--where location like '%nigeria'
order by 1,2 

--Countries with Highest infection rate compare with population
 
 Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PotfolioProject..CovidDeaths
--where location like '%nigeria'
Group by  location, population
order by PercentagePopulationInfected desc

--Showing countries with Highest Death count to population

-- View Data by Location

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PotfolioProject..CovidDeaths
--where location like '%nigeria'
where continent is null
Group by  location  
order by TotalDeathCount desc

-- view Data by continent 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PotfolioProject..CovidDeaths
--where location like '%nigeria'
where continent is not null
Group by  continent  
order by TotalDeathCount desc


--Showing continent with the Highest death count per population 
 
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	from PotfolioProject..CovidDeaths
	--where location like '%nigeria'
	where continent is not null
	Group by location  
	order by TotalDeathCount desc


--Global Numbers

 Select SUM(New_Cases) as Total_Cases, SUM(cast(New_Deaths as int)) as Total_Death, SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	from PotfolioProject..CovidDeaths
	--where location like '%nigeria'
	where continent is not null
	--Group by Date
	order by 1,2 
 

Select date, SUM(New_Cases) as Total_Cases, SUM(cast(New_Deaths as int)) as Total_Death, SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	from PotfolioProject..CovidDeaths
	--where location like '%nigeria'
	where continent is not null
	Group by Date
	order by 1,2 


--Looking at Total population vs vacination

Select *
	from PotfolioProject..CovidDeaths dea
	join PotfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	from PotfolioProject..CovidDeaths dea
	join PotfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
	dea.date) as RollingPeopleVaccinated
	from PotfolioProject..CovidDeaths dea
	join PotfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3 

--USE CTE

with  PopulationsVSVacinnations  (continent, location, Date, population, New_vaccinations, RollingPeopleVaccinated)
	as  
	(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,
	dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
	from PotfolioProject..CovidDeaths dea
	join PotfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
  --order by 1,2,3
)

select *,(RollingPeopleVaccinated/population)*100
	from PopulationsVSVacinnations


--TEMP TABLE (How to create a temporary table in SQL)
--How to Update table/remove content simply add the drop table command.

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
 
Continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
	from PotfolioProject..CovidDeaths dea
	join PotfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
  --where dea.continent is not null
  --order by 1,2,3

  select *,(RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
	from #PercentPopulationVaccinated


	--Creating View to store data for later visualizations

	
	Create view PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
	from PotfolioProject..CovidDeaths dea
	join PotfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
    where dea.continent is not null
   --order by 1,2,3

   DROP VIEW PercentPopulationVaccinated
