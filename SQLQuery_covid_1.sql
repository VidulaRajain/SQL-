Select *
From PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


--Select data that we are going to be using 

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at the Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you get infected 

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Percentage_of_Deaths
From PortfolioProject..CovidDeaths
where location ='India'
order by 1,2


--Looking at the total cases vs the population
--Shows what percentage of population got Infected 

Select location,date,total_cases,population,(total_cases/population)*100 as Percentage_of_Infections
From PortfolioProject..CovidDeaths
--where location ='India'
order by 1,2

-- Looking at countries with highest infection rate

Select location,population,MAX(total_cases) as Highest_Cases,MAX((total_cases/population))*100 as Max_Infection_Rate
From PortfolioProject..CovidDeaths
--where location ='India'
group by location,population
order by 4 desc



-- Countries with the highest death count

Select location,MAX(cast(total_deaths as int)) as Total_deaths
From PortfolioProject..CovidDeaths
where continent is not null 
group by location
order by 2 desc


-- ANALYSIS BY THE CONTINENT 

-- Total death count in each continent 


Select continent,MAX(cast(total_deaths as int)) as Total_deaths
From PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by 2 desc


select location as continent,MAX(cast(total_deaths as int)) as Total_deaths
From PortfolioProject..CovidDeaths
where continent is null 
group by location
order by 2 desc

--UPDATE PortfolioProject..CovidDeaths
--SET location='European Union'
--WHERE location='Europe';

Select continent,MAX(cast(total_deaths as int)) as Total_deaths
From PortfolioProject..CovidDeaths
where continent is not null 
group by continent
--order by 2 desc
UNION 
select location as continent,MAX(cast(total_deaths as int))  as Total_deaths
From PortfolioProject..CovidDeaths
where continent is null 
group by location
order by 2 desc;

--Fixing the NULL values in continent 
select location,count(location) as count_ 
From PortfolioProject..CovidDeaths
where continent is NULL 
group by location 
order by location

select continent,count(continent) as count_ 
From PortfolioProject..CovidDeaths
group by continent
order by continent

UPDATE PortfolioProject..CovidDeaths
SET continent='Europe'
WHERE location like '%European%'


UPDATE PortfolioProject..CovidDeaths
SET continent='Africa'
WHERE location like '%Africa%'

UPDATE PortfolioProject..CovidDeaths
SET continent='Asia'
WHERE location ='Asia'

UPDATE PortfolioProject..CovidDeaths
SET continent='North America'
WHERE location ='North America'

UPDATE PortfolioProject..CovidDeaths
SET continent='South America'
WHERE location ='South America'

--Now we will get the correct continent wise values

Select continent,MAX(cast(total_deaths as int)) as Total_deaths
From PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by 2 desc


--GLOBAL 

--DEATH PERCENTAGE

Select date,SUM(new_cases) as cases ,SUM(cast(new_deaths as int)) as deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Percentage_of_Deaths
From PortfolioProject..CovidDeaths
where new_cases is not null and new_cases!=0
group by date
order by 1

--Total cases worldwide till date:- 

Select SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Percentage_of_Deaths
From PortfolioProject..CovidDeaths
where new_cases is not null and new_cases!=0

--Around 2% mortality rate 


--VACCINATION TABLE

SELECT *
FROM PortfolioProject..CovidVaccinations

--Joining the two tables together 

SELECT *
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacc
ON death.location=vacc.location and death.date=vacc.date 

-- No. of people who have been vaccinated at least once 

--select continent,location,population, (MAX((cast(people_vaccinated as bigint)-cast(people_fully_vaccinated as bigint)))/population)*100 as Percentage_vaccinated_Once --, (MAX(cast(people_fully_vaccinated as bigint))/population)*100 as Percent_fully_vaccinated 
--from PortfolioProject..CovidDeaths
--where continent is not null 
--group by continent,location,population 
--order by 4 desc

SELECT *
FROM PortfolioProject..CovidDeaths


--select location,population,SUM(cast(new_vaccinations as bigint)) OVER (partition by location)/population
--from PortfolioProject..CovidDeaths
--group by location,population 
--order by 3 desc

--We will perform a rolling sum here to get the total number of people vaccinated each day per country  :- 
SELECT death.continent,death.location,death.date,death.population,vacc.new_vaccinations,SUM(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location,death.date) as rolling_count_vaccinations, 
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacc
ON death.location=vacc.location and death.date=vacc.date 
where death.continent is not null 
order by 2,3


--Getting the percent of population vaccinated country wise as each day passes by:- 

-- using CTE : Common Table Expression 


With PopVacc(continent,location,date,population,new_vaccinations,rolling_count_vaccinations)
as
(
SELECT death.continent,death.location,death.date,death.population,vacc.new_vaccinations,SUM(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location,death.date) as rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacc
ON death.location=vacc.location and death.date=vacc.date 
where death.continent is not null 
--order by 2,3, cannot use order by in CTE
)
select *,(rolling_count_vaccinations/population)*100 as Percent_Vaccinated 
from PopVacc


--Using a temp Table 

drop table if exists percent_pop_vacc
create table percent_pop_vacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling numeric
)

Insert into percent_pop_vacc
SELECT death.continent,death.location,death.date,death.population,vacc.new_vaccinations,SUM(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location,death.date) as rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacc
ON death.location=vacc.location and death.date=vacc.date 
--where death.continent is not null 
--order by 2,3, cannot use order by in CTE


select *,(rolling/population)*100 as Percent_Vaccinated 
from percent_pop_vacc


--CREATE A VIEW ( TO STORE DATA FOR LATER VIZUALISATIONS) 

CREATE VIEW percentvacc as
SELECT death.continent,death.location,death.date,death.population,vacc.new_vaccinations,SUM(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location,death.date) as rolling_count_vaccinations
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacc
ON death.location=vacc.location and death.date=vacc.date 
where death.continent is not null 
--order by 2,3

select * from percentvacc