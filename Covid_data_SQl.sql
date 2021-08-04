select * from [dbo].[covid_deaths]
order by 3,4 

--select * from [dbo].[Sheet1$]
--order by 3,4 

select 
location, date, total_cases, new_cases, total_deaths, population
from [dbo].[covid_deaths]
order by 1,2

--Total Cases VS Total Deaths

select 
location,date,total_cases,total_deaths, population, (total_deaths/total_cases)*100 as Death_Percentage 
from [dbo].[covid_deaths]
order by 1,2

--Total Cases VS Total Death in India 
select 
location,date,total_cases,total_deaths, population, (total_deaths/total_cases)*100 as Death_Percentage 
from [dbo].[covid_deaths]
where location = 'India'
order by 1,2

--Total cases Vs POpulation 

select 
location,date,total_cases, population, (total_cases/population)*100 as Percentage_of_TotalCases 
from [dbo].[covid_deaths]
where location = 'India'
order by 1,2

--Percentage of infection

select 
location, Max(total_cases), population, Max((total_cases/population))*100 as Percentage_of_infection
from [dbo].[covid_deaths]
--where location = 'India'
group by location, population

order by 4 desc

-- Showing countries with highest deeth count

select 
location, Max(total_deaths) as Max_deaths, population, Max((total_deaths/population))*100 as Percentage_of_Death
from [dbo].[covid_deaths]
--where location = 'India'
group by location, population

order by 4 desc

--County with highest death

select 
location, Max(cast( total_deaths as int)) as Max_deaths
from [dbo].[covid_deaths]
--where location = 'India'
where continent is not null
group by location

order by Max_deaths desc


--Break down by Continent and Total cases

select 
location, Max(cast( total_cases as int)) as total_cases_count
from [dbo].[covid_deaths]
--where location = 'India'
where continent is null
group by location

order by total_cases_count desc


--showing the continent with highest death count 

select 
location, Max(cast( total_deaths as int)) as total_deaths_count 
from [dbo].[covid_deaths]
--where location = 'India'
where continent is null
group by location

order by total_deaths_count desc



--Total death Vs Total cases in continents

select 
location, Max(cast( total_deaths as int)) as total_deaths_count, Max(cast( total_cases as int)) as total_cases_count
from [dbo].[covid_deaths]
--where location = 'India'
where continent is null
group by location

order by total_deaths_count desc

--Global Numbers

select sum(cast(new_cases as int)) as Total_globalnew_case, sum(cast(new_deaths as int)) as Total_globalnew_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Global_death_per

from [dbo].[covid_deaths]
where continent is not null
--group by date
order by 1,2


--- new table to work
-- join the two tables 
--Total poulation Vs vaccination

select 
cd.continent , cd.location , cd.date , cd.population,
cv.new_vaccinations

from covid_deaths cd 
join covid_vaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 1,2,3

--total vacination


select 
cd.continent , cd.location , cd.date , cd.population,
cv.new_vaccinations,
Sum(convert(int,new_vaccinations)) over (Partition by cd.location Order by cd.location, cd.date) as total_vac_given

from covid_deaths cd 
join covid_vaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
--and cd.location ='India '
order by 2,3


--percentage of people got vacinated

-- use CTE

with popvsVas(continent, location , date ,population , new_vaccinations, total_vac_given)
as
(
select 
cd.continent , cd.location , cd.date , cd.population,
cv.new_vaccinations,
Sum(convert(int,new_vaccinations)) over (Partition by cd.location Order by cd.location, cd.date) as total_vac_given

from covid_deaths cd 
join covid_vaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
--and cd.location ='India '
)
select *, (total_vac_given/population)*100 as Per_population_vaccinated
from popvsVas

--TEMP Table 

drop table if exists #percentage_poulation_vacc
create table #percentage_poulation_vacc
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
total_vac_given numeric
)

Insert into  #percentage_poulation_vacc
select 
cd.continent , cd.location , cd.date , cd.population,
cv.new_vaccinations,
Sum(convert(int,new_vaccinations)) over (Partition by cd.location Order by cd.location, cd.date) as total_vac_given

from covid_deaths cd 
join covid_vaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
--and cd.location ='India'

select *, (total_vac_given/population)*100 as Per_population_vaccinated
from #percentage_poulation_vacc



-- Create View to store data for viswalization 


create view Percentage_poulation_vacinated as 
select 
cd.continent , cd.location , cd.date , cd.population,
cv.new_vaccinations,
Sum(convert(int,new_vaccinations)) over (Partition by cd.location Order by cd.location, cd.date) as total_vac_given

from covid_deaths cd 
join covid_vaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
--and cd.location ='India'


select *
from Percentage_poulation_vacinated




















