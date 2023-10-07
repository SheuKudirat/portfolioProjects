select *
from PortfolioProject..CovidDeaths$
where continent is not null

--select *
--from PortfolioProject..CovidVaccinations$

select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..CovidDeaths$
where continent is not null

--looking at total cases vs total deaths(showa the likelihood of dyng)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
and continent is not null

--looking at total cases vs populaton(shows what percentage got covid

select location, date, total_cases, population, (total_cases/population)*100 as CovidPopulationPercentage
from PortfolioProject..CovidDeaths$
where location like  '%Nigeria%'
and continent is not null

--looking at countries with highest population rate compared to population

select location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases)/population)*100 as CovidPopulationPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
group by location, population
order by CovidPopulationPercentage desc

--showing countries with highest death count per poulation

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by location 
order by  TotalDeathCount desc

--breaking DeathCount per population by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by continent
order by  TotalDeathCount desc

--looking at global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by date
order by 1,2

--joining coviddeaths and covidvaccinations tables

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by
dea.location order by dea.location, dea.date)  as ConsecutiveVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

--use CTE 

with PopVsVac (continent, location, date, population, new_vaccinations, ConsecutiveVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by
dea.location order by dea.location, dea.date)  as ConsecutiveVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (ConsecutiveVaccinations/population)*100
from PopVsVac

--create view to store data for visualization

use PortfolioProject
go
create view PopVsVac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by
dea.location order by dea.location, dea.date)  as ConsecutiveVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
 
