select *
from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVacctionations
--order by 3,4

--select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at TotalCases vs  TotalDeaths
-- Shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as  DeathsPercentage
from PortfolioProject..CovidDeaths
where location like '%egypt%'
and continent is not null
order by 1,2

--Looking at Total Cases  vs Population
-- Shows what percentage of populaltion got Covid

select location,date, population, total_cases,(total_cases/population)*100 as PopulationInfectionPercentage
from PortfolioProject..CovidDeaths
where location like '%egypt%'
order by 1,2


-- Looking for Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PopulationInfectionPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PopulationInfectionPercentage desc

-- Showing Countries with Highest Death Count per Population

select location , MAX(cast(total_deaths as int )) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Showing Continents with Highest Death Count per Population
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is  null
group by location
order by TotalDeathCount desc

--Global Numbers
select  SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths , (SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2 

--======================	Join Tables		==================================

--select *
--from PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVacctionations vac
--on dea.location= vac.location 
--and dea.date = vac.date


-- Looking for Total Population vs Total Vaccinations
select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacctionations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not  null
order by 2,3

-- Use CTE 
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacctionations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not  null
)
select* , (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from PopvsVac

-- Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location ,dea.date, dea.population , vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacctionations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not  null

select* , (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated

-- Create Views to store data for later Visualization

Create View HighestDeathCount as
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is  null
group by location
--order by TotalDeathCount desc

select * from HighestDeathCount
order by TotalDeathCount desc
