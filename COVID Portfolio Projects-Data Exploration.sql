select *
from PortfolioProject..[covid deaths]
where continent is not null
order by 3,4

--select *
--from PortfolioProject..[covid vaccinations]
--order by 3,4

--select data that we are going to be using

select Location,date, total_cases, new_cases, total_deaths,population
from PortfolioProject..[covid deaths]
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelyhood  of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..[covid deaths]
where location like 'India'
and continent is not null
order by 1,2

--Looking at the Total Cases vs Population
--Shows What percentage of population got covid

Select location, date,Population, total_cases, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..[covid deaths]
--where location like 'India'
order by 1,2


--Looking at countries with highest infection rate compared to Population 

Select location, Population, max(total_cases) as HighestInfectionCount, 
max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, Population), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..[covid deaths]
--where location like 'India'
group by location, Population
order by PercentPopulationInfected desc



--Showing Countries with Higest Death Count per Population

Select location, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..[covid deaths]
--where location like 'India'
where continent is not null
group by location
order by TotalDeathCount desc



--LETS BREAK THINGS INTO CONTINENT



--Showing the continent with the Highest Death Count per Population

Select continent, max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..[covid deaths]
--where location like 'India'
where continent is not null
group by continent
order by TotalDeathCount desc




--GLOBAL MEMBERS

Select   sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/nullif(SUM(New_Cases),0) *100  AS  Deathpercentage
from PortfolioProject..[covid deaths]
--where location like 'India'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[covid deaths] dea
join PortfolioProject..[covid vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
	order by 2,3



--Use CTE
with PopvsVac (Continent,location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[covid deaths] dea
join PortfolioProject..[covid vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac



--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[covid deaths] dea
join PortfolioProject..[covid vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating View to store Data for later Visuvalisations

Drop View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..[covid deaths] dea
join PortfolioProject..[covid vaccinations] vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated 
