SELECT * 
FROM PortafolioProject..CovidDeaths
where continent is null
order by 3,4

--SELECT * 
--FROM PortafolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going

Select location, date, total_cases, new_cases, total_deaths, population
from PortafolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortafolioProject..CovidDeaths
where location like '%ecua%'
order by 1,2

--Looking at Total Cases vs  Population
--Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulatioInfected
from PortafolioProject..CovidDeaths
--where location like '%ecua%'
order by 1,2

-- Looking at countries with higthest rates compared to population 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulatioInfected
from PortafolioProject..CovidDeaths
--where location like '%ecua%'
group by location, population
order by PercentPopulatioInfected desc



--Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortafolioProject..CovidDeaths
where continent is not null
--where location like '%ecua%'
group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortafolioProject..CovidDeaths
where continent is not null
--where location like '%ecua%'
group by continent
order by TotalDeathCount desc

WITH MaxCasesLocation AS (
    SELECT continent, location, MAX(cast(total_deaths as int)) AS MaxTotalCases
    FROM PortafolioProject..CovidDeaths
	where continent is not null
    GROUP BY continent, location
)

SELECT m.continent, SUM(m.MaxTotalCases) AS TotalesDeathContinent
FROM MaxCasesLocation AS m
GROUP BY m.continent
order by TotalesDeathContinent desc



--Global Numbers

select sum(new_cases) as cases, sum(cast(new_deaths as int)) as deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortafolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2



-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3

 --use CTE

 with PopvsVac (Continent, Location, Data, Population, New_Vaccionations, RollingPeopleVaccinate)
  as(
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3
 ) 
 select *, (RollingPeopleVaccinate/Population)*100  
 from PopvsVac 


 --Tem table
 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Data datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric,
 )
 Insert into #PercentPopulationVaccinated

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select *, (RollingPeopleVaccinated/Population)*100  
 from #PercentPopulationVaccinated 


 --Creating View to store date for later visualizations

 Create View PercentPopulationVaccinated2 as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

 select * 
 from PortafolioProject..CovidDeaths dea