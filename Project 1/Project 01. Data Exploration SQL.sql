													-- Project 01 --
									-- Data Exploration (Nashville Housing Dataset) --
											-- By: Carly Marshanda Arta MS -- 

select *
from Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4

--select *
--from Portfolio_Project..CovidVaccinations
--order by 3,4

-------------------------------------------------------------------------------------------------------------

-- select data that we're going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by 1,2

------------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths
where location like '%states%'
order by 1,2

------------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Population --
-- Shows what percentage of population got covid --

select Location, date, population, total_cases, (total_deaths/population)*100 as PercentPo
from Portfolio_Project..CovidDeaths
--where location like '%states%'
order by 1,2

------------------------------------------------------------------------------------------------------------

-- Looking at Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Percent_Population_Infected
from Portfolio_Project..CovidDeaths
--where location like '%states%'
group by location, population
order by Percent_Population_Infected desc

------------------------------------------------------------------------------------------------------------

-- showing countries with highest death count per population --

select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
from Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by Total_Death_Count desc

-----------------------------------------------------------------------------------------------------------

-- Lets Break things down by continent

select continent, MAX(CAST(total_deaths as int)) as Total_Death_Count
from Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by Total_Death_Count desc

-----------------------------------------------------------------------------------------------------------

-- Global Numbers --

select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2 

===========================================================================================================

-- looking at total population vs vaccination --

select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccin 
	on death.location = vaccin.location
	and death.date = vaccin.date
where death.continent is not null
order by 1,2,3
---------------------------------------------------------------------------------------------
select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccin 
	on death.location = vaccin.location
	and death.date = vaccin.date
where death.continent is not null
order by 2,3
---------------------------------------------------------------------------------------------
select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations, 
sum(convert(int, vaccin.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccin 
	on death.location = vaccin.location
	and death.date = vaccin.date
where death.continent is not null
order by 2,3

---------------------------------------------------------------------------------------------

-- use CTE --

with PopvsVac (Continent, location, date, population, New_Vaccinations, Rolling_People_Vaccinated) 
as
(
select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations, 
sum(convert(int, vaccin.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccin 
	on death.location = vaccin.location
	and death.date = vaccin.date
where death.continent is not null
--order by 2,3
)
select*, (Rolling_People_Vaccinated/population)*100
from PopvsVac

---------------------------------------------------------------------------------------------------------

-- Temp Table --

drop table if exists
create table #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
insert into
select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations, 
sum(convert(int, vaccin.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccin 
	on death.location = vaccin.location
	and death.date = vaccin.date
where death.continent is not null
--order by 2,3
)

select*, (Rolling_People_Vaccinated/population)*100
from #Percent_Population_Vaccinated

------------------------------------------------------------------------------------------------------

-- create view to store data for later visualizations

create view Percent_Population_Vaccinated as
select death.continent, death.location, death.date, death.population, vaccin.new_vaccinations, 
sum(convert(int, vaccin.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
from Portfolio_Project..CovidDeaths death
join Portfolio_Project..CovidVaccinations vaccin 
	on death.location = vaccin.location
	and death.date = vaccin.date
where death.continent is not null
--order by 2,3

select*
from Percent_Population_Vaccinated
