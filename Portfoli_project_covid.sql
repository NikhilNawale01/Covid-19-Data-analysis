/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Select Data that we are going to be starting with

select *
from Portfolio_project_covid..CovidDeaths



select *
from Portfolio_project_covid..CovidVaccinations



select * 
from Portfolio_project_covid..CovidDeaths
where continent is not null
order by 1,2



select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project_covid..CovidDeaths
order by 1,2





--looking at total cases vs total deaths
--Shows the likelihood of dying if you are infected by covid-19 virus across all continents

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from Portfolio_project_covid..CovidDeaths
order by 1,2





--Total cases vs Population
--Shows what percentage of population infected with Covid

select Location, date, population, total_cases, (total_cases/population)*100 as Death_percentage
from Portfolio_project_covid..CovidDeaths
order by 1,2




--Looking at country's with highest infection rate compared to population

select Location, population, MAX (total_cases) as HighestInfection,MAX ((total_cases/population))*100 as PercentofPopulationInfected
from Portfolio_project_covid..CovidDeaths
group by location, Population
order by PercentofPopulationInfected desc 




--Countries with Highest Death Count per Population

select Location, population, MAX (cast(total_deaths as int)) as HighestDeathCount
from Portfolio_project_covid..CovidDeaths
where continent is not null
group by location, Population
order by HighestDeathCount desc 




--BREAKING THINGS DOWN BY CONTINENTS and LOCATIONS

--Showing contintents with the highest death count per population



select continent, MAX (cast(total_deaths as int)) as TotalDeathCounts
from Portfolio_project_covid..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCounts desc 


select location, MAX (cast(total_deaths as int)) as TotalDeathCounts
from Portfolio_project_covid..CovidDeaths
where continent is null
group by location
order by TotalDeathCounts desc 




-- GLOBAL NUMBERS

--Comparing infected cases to death cases on global level


select sum(new_cases) as TotalCases, sum(cast (new_deaths as int)) as TotalDeaths , Sum(cast (new_deaths as int)) / SUM(new_cases)*100 as TotalDeathPercentage
from Portfolio_project_covid..CovidDeaths
where continent is not null




--Total Population vs Vaccinations
--looking for the total number of vacinations and populations 


select dea.continent, dea.location, dea.date, dea.population, vca.new_vaccinations, 
SUM(cast (vca.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVacinated
from Portfolio_project_covid..CovidDeaths dea
join Portfolio_project_covid..CovidVaccinations vca
	on dea.location = vca.location
	and dea.date = vca.date
where dea.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_project_covid..CovidDeaths dea
Join Portfolio_project_covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio_project_covid..CovidDeaths dea
Join Portfolio_project_covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated






--creating a view to store data for later visualization


Create View PercentPopulationVaccinated3 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_project_covid..CovidDeaths dea
Join Portfolio_project_covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




