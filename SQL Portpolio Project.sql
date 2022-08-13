use covid;

select * from coviddeaths
where continent is not null
order by 3,4;

-- select * from covidvaccinations 
-- order by 3,4;

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2;

-- Looking at Total Cases vs. Total_Deaths
-- Shows likelihood of dying if you contract covid in Africa

Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from coviddeaths
where location like '%Africa%' and 
continent is not null
order by 1,2;

-- Looking at the Total Cases vs Population
-- Shows what percentage of polulation caught Covid

Select location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
from coviddeaths
where location like '%Africa%'
and continent is not null
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, max(total_cases) HighestInfectionCount, max((total_cases/population))*100 PercentPopulationInfected
from coviddeaths
where location like '%Africa%'
group by location, population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as signed)) TotalDeathCount
from coviddeaths
where location like '%Africa%'
and continent is not null
group by location
order by TotalDeathCount desc;

-- Let's break things down by continent

-- Showing Continents with the Highest Death Count per Population

Select continent, max(cast(total_deaths as signed)) TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- Global Numbers

Select sum(new_cases) total_cases, sum(cast(new_deaths as signed)) total_deaths, sum(new_deaths)/sum(new_cases)*100 DeathPercentage
from coviddeaths
where continent is not null
-- group by date
order by 1,2;

-- Looking at Total Populaton vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) OVER (partition by dea.location order by dea.location and 
dea.date) RunningTotalofVaccinations
-- RunningTotalofVaccinations/population*100
from coviddeaths dea
inner join Covidvaccinations vac
on dea.location = vac.location and 
dea.date = vac. date
where dea.continent is not null
order by 2,3;

-- Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RunningTotalofVaccinations)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, 
dea.date) RunningTotalofVaccinations
from coviddeaths dea
inner join Covidvaccinations vac
on dea.location = vac.location and 
dea.date = vac. date
where dea.continent is not null
-- order by 2,3
)
Select *, (RunningTotalofVaccinations/population)*100 from PopvsVac;

-- Temp Table

Create Table PercentPopulationVaccinated
(Continent varchar(255),
Location varchar(255),
Date Datetime,
Population Numeric, 
New_vaccinations numeric,
RunningTotalofVaccinations numeric
);

insert into PercentPopulationVaccinated
select dea.continent, dea.location, str_to_date(dea.date, '%M, %D, %Y'), cast(dea.population as signed) vac.new_vaccinations, 
       sum(cast(vac.new_vaccinations as signed)) 
           over(partition by dea.location 
                order by dea.location ROWS UNBOUNDED PRECEDING) RunningTotalVaccinations
From CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not null
    order by 2, 3;

Select *, (RunningTotalofVaccinations/population)*100 
from PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinatedView as
select dea.continent, dea.location, str_to_date(dea.date, '%Y-%m-%d'), dea.population, vac.new_vaccinations, 
       sum(cast(vac.new_vaccinations as signed)) 
           over(partition by dea.location 
                order by dea.location ROWS UNBOUNDED PRECEDING) RunningTotalVaccinations
From CovidDeaths dea
join CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is not null;
    
    Create view totalpopulationvsVSVaccinations as
    select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) OVER (partition by dea.location order by dea.location and 
dea.date) RunningTotalofVaccinations
-- RunningTotalofVaccinations/population*100
from coviddeaths dea
inner join Covidvaccinations vac
on dea.location = vac.location and 
dea.date = vac. date
where dea.continent is not null
order by 2,3;

Create view totalcasesvstotaldeaths as
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from coviddeaths
where location like '%Africa%' and 
continent is not null
order by 1,2;

Create view globalnumbers as
Select sum(new_cases) total_cases, sum(cast(new_deaths as signed)) total_deaths, sum(new_deaths)/sum(new_cases)*100 DeathPercentage
from coviddeaths
where continent is not null
-- group by date
order by 1,2;

Create view Highestdeathcountperpopulation as 
Select location, max(cast(total_deaths as signed)) TotalDeathCount
from coviddeaths
where location like '%Africa%'
and continent is not null
group by location
order by TotalDeathCount desc;



    
    



























