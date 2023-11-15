-- this code is not original and I do not take credit for making it
Select *
From CovidDeaths
order by 3,4

--Select *
--from CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases,total_deaths, population
From CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
and location like '%Portugal%'
order by 1,2


-- Looking at Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as C19PopulationPercentage
From CovidDeaths
where continent is not null
and location like '%Portugal%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as C19PopulationPercentage
From CovidDeaths
where continent is not null
group by location, population
order by C19PopulationPercentage desc


-- Showing Countries with Higest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- where location like '%Portugal%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing the continet with the Hightest deathcount

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
-- where location like '%Portugal%'
where continent is null
group by location
order by TotalDeathCount desc


-- Global Numbers

Select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
--where location like '%Portugal%'
group by date
order by 1,2


-- Total deaths

Select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null
--where location like '%Portugal%'
order by 1,2


-- Looking at total population vs vaccionations


Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
sum(cast(Vac.new_vaccinations as bigint)) over (partition by Dea.location order by Dea.location,
Dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from CovidDeaths as Dea
Join CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac(continent, location, date, population, new_people_vaccinated_smoothed, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_people_vaccinated_smoothed,
sum(cast(Vac.new_people_vaccinated_smoothed as bigint)) over (partition by Dea.location order by Dea.location,
Dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from CovidDeaths as Dea
Join CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
)

Select*, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table

drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_people_vaccinated_smoothed numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_people_vaccinated_smoothed,
sum(cast(Vac.new_people_vaccinated_smoothed as bigint)) over (partition by Dea.location order by Dea.location,
Dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from CovidDeaths as Dea
Join CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null

Select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
order by 2,3


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_people_vaccinated_smoothed,
sum(cast(Vac.new_people_vaccinated_smoothed as bigint)) over (partition by Dea.location order by Dea.location,
Dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from CovidDeaths as Dea
Join CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3


Select*
from PercentPopulationVaccinated
