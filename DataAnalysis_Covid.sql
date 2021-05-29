use PortfolioProject;

-- Looking at total cases vs total deaths
-- Shows loikelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 deathPercentage
from   dbo.covidDeaths
where  location like '%States%'
and    continent is not null
order by 1,2;

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 deathPercentage
from   dbo.covidDeaths
where  location like '%Mexico%'
and    continent is not null
and    total_cases != 0
order by 1,2;

-- Looking the total cases vs population 
-- Show what percentage of population got covid 
select location,date,population,total_cases, (total_cases/population)*100 deathPercentage
from   dbo.covidDeaths
where  location like '%States%'
and    continent is not null
order by 1,2;

select location,date,population,total_cases, (total_cases/population)*100 PercentofPopulationInfected
from   dbo.covidDeaths
where  location like '%Mexico%'
and    continent is not null
order by 1,2;

-- Looking at countries with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectionCount , max(total_cases/population)*100 PercentofPopulationInfected
from   dbo.covidDeaths
where  1=1 --location like '%States%'
and population != 0
and    continent is not null
group by location,population
order by PercentofPopulationInfected desc;

-- showing the countries with the highest Death count per Population
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from   dbo.covidDeaths
where  1=1 --location like '%States%'
and    continent is not null
group by location
order by 2 desc;

-- LET'S BREAK THINGS DOWN  BY CONTINENT


-- Showing the continents with the highest death count per population
select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from   dbo.covidDeaths
where  1=1 --location like '%States%'
and    continent is not null
group by continent
order by 2 desc;

-- Global numbers
-- deaths by day
select date,sum(new_cases) TotalCases, sum(new_deaths) TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as deathPercentage
from   dbo.covidDeaths
where  1=1
and    continent is not null
and    new_cases != 0
group by date
order by 1,2;

-- total Death percentages
select sum(new_cases) TotalCases, sum(new_deaths) TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as deathPercentage
from   dbo.covidDeaths
where  1=1
and    continent is not null
and    new_cases != 0
--group by date
order by 1,2;

-- Looking at total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated,
	   (RollingPeopleVaccinated/Population)
from   dbo.covidVaccinations  vac
join   dbo.covidDeaths dea
  on dea.location = vac.location
  and dea.date = vac.date
  and dea.continent is not null
order by 2,3;


-- use CTE
with PopvsVacc (continent,location, date, Population,new_vaccinations,RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from   dbo.covidVaccinations  vac
join   dbo.covidDeaths dea
  on dea.location = vac.location
  and dea.date = vac.date
  and dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from   PopvsVacc
where  Population != 0;

-- Temp table

--Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent varchar(255),
 Location  varchar(255),
 Date      datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated  numeric
  )
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from   dbo.covidVaccinations  vac
join   dbo.covidDeaths dea
  on dea.location = vac.location
  and dea.date = vac.date
  and dea.continent is not null;

select *, (RollingPeopleVaccinated/Population)*100
from   #PercentPopulationVaccinated
where  Population != 0;

--- Creating view to store data for later visualizations
Create View PercentPopulationVaccinatedview as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from   dbo.covidVaccinations  vac
join   dbo.covidDeaths dea
  on dea.location = vac.location
  and dea.date = vac.date
where  dea.continent is not null
--order by 2,3;

select *
from   PercentPopulationVaccinatedview;