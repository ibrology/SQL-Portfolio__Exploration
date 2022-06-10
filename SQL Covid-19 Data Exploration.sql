
SELECT * 
From PortfolioProject..CovidDeaths$
Order by 3,4

SELECT * 
From PortfolioProject..CovidVaccinations$
Order by 3,4

--Filter out Location and population with respect to Highest Covid-19 Cases from Covid deaths table.
--PS: The where statement can be used to find any country.

Select Distinct location, population, MAX(total_cases) As HighestCovidCases
From PortfolioProject..CovidDeaths$
Where continent is not null-- and location Like '%Nigeria%'
Group by Location, population
order by 3 desc


--Filter out Location and Date with respect to Highest Covid-19 Cases from Covid Vaccination table.
--PS: The where statement can be used to find any country.

Select Distinct location, Max(date) As Date, MAX(Cast(total_vaccinations as bigint)) As HighestVaccinationCases
From PortfolioProject..CovidVaccinations$
Where continent is not null--location Like '%Nigeria%'
Group by Location
order by 3 desc


--Filtered out the Location, date, total_cases, total_deaths, and population from CovidDeaths Table 
--Sorted by Location and Date

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Order by 1, 2; 

--Looking at Total Cases vs Total Deaths = (Death Percentage) and Total Cases vs Population (DeathPopPercentage)

Select Location, date, population,total_cases,total_deaths, (total_deaths/total_cases)* 100 As DeathPercentage,
 (total_deaths/population)*100 As DeathPopPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Nigeria%'
Order by 1, 2; 

--Looking at Total Infected and Percentage Population Infected for each location

Select Location, population, Max(total_cases) as HighestInfectedCount, Max(total_cases/population)* 100 As PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Group by location, population
Order by PercentagePopulationInfected desc

--Showing countries with highest death count per population

Select Location, Max(cast(total_deaths as int)) As TotalDeathCount
From PortfolioProject..CovidDeaths$
Where Continent is not null 
--and location like '%Nigeria%'
Group by Location
Order by TotalDeathCount desc;


-- Showing Continent with the Highest death from the Covid Deaths Table 

Select continent, Max(cast(total_deaths as int)) As TotalDeathCount
From PortfolioProject..CovidDeaths$
Where Continent is not null
Group by continent
Order by TotalDeathCount desc;

-- Showing Continent with the Highest Number of Vaccination From the Covid Vaccinations Table

Select continent, Max(cast(total_vaccinations as bigint)) As TotalVaccinations
From PortfolioProject..CovidVaccinations$
Where Continent is not null
Group by continent
Order by TotalVaccinations desc;


-- Global Numbers for Total covid cases, total deaths and Death Percentanges 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths As int)) as total_deaths, SUM (cast(New_deaths as int))/Sum(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null


-- Global Numbers for Total Covid Cases, Total Deaths, Total Vaccinations and Vaccination per populaton 

Select SUM(dea.new_cases) as total_cases, SUM(cast(dea.new_deaths As int)) as total_deaths, 
SUM(cast(New_deaths as int))/Sum(New_cases)*100 as DeathPercentage, 
Max(Cast(vac.total_vaccinations as bigint)) As TotalVaccinations, 
Max(cast(vac.total_vaccinations as bigint))/Max(dea.population)*100 as Vaccinationpercentage
From PortfolioProject..CovidDeaths$ As dea
Join PortfolioProject..CovidVaccinations$ As vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
 


-- Looking at Total Population and Vaccinations
-- USE CTE

With PopVSVac (Continent, Loaction, Date, Population, new_vaccinations, RowVaccinationwSummation)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.Location order by dea.location, dea.date) As RowVaccinationwSummation
--(RowVaccinationwSummation/population)*100 
From PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	on dea.location =vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
) 
Select *, (RowVaccinationwSummation/population)*100
From PopvsVac



-- TEMP Table

Drop Table if exists #RowVaccinationwSummation
Create Table #RowVaccinationwSummation
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime, 
Population numeric,
new_vaccinations numeric,
RowVaccinationwSummation numeric
)

Insert into #RowVaccinationwSummation
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.Location order by dea.location, dea.date) As RowVaccinationwSummation
--(RowVaccinationwSummation/population)*100 
From PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	on dea.location =vac.location
	and dea.date=vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RowVaccinationwSummation/population)*100
From #RowVaccinationwSummation



--Creating View to store data for later Visualizations

Create View RowVaccinationwSummations as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations as bigint)) OVER 
(Partition by dea.Location order by dea.location, dea.date) As RowVaccinationwSummation
--(RowVaccinationwSummation/population)*100 
From PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	on dea.location =vac.location
	and dea.date=vac.date
Where dea.continent is not null


Create View TotalDeathss as
Select Location, Max(cast(total_deaths as int)) As TotalDeathCount
From PortfolioProject..CovidDeaths$
Where Continent is not null 
--and location like '%Nigeria%'
Group by Location
--Order by TotalDeathCount desc;