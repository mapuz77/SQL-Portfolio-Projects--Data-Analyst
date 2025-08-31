SELECT * FROM [PortfolioProjectSQL1]..CovidDeaths$
ORDER BY 3,4; 

SELECT * FROM [PortfolioProjectSQL1]..CovidVaccinations$ 
ORDER BY 3,4;

--SELECT THE DATA THAT WE WILL BE USING 

--SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProjectSQL1]..CovidDeaths$
ORDER BY 1,2

--LOOKING AT TOTAL CASES  VS TOTAL DEATHS 
--shows percentage of deaths in your country IF YOU CATHC COVID 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
FROM [PortfolioProjectSQL1]..CovidDeaths$
WHERE location like '%Croatia%'
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID 
SELECT location, date, population, total_cases, (total_cases/population)*100 as got_covid_percentage 
FROM [PortfolioProjectSQL1]..CovidDeaths$
--WHERE location like '%Croatia%'
ORDER BY 1,2

--LOOKING AT HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percentage_population_infected   --DATE ne treba
FROM [PortfolioProjectSQL1]..CovidDeaths$
--WHERE location like '%Croatia%'
GROUP BY location, population
ORDER BY percentage_population_infected DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 
SELECT location, MAX(CAST (total_deaths  as int)) as  total_death_count 
FROM [PortfolioProjectSQL1]..CovidDeaths$
GROUP BY location
ORDER BY total_death_count  DESC

SELECT location, MAX(CAST (total_deaths  as int)) as  total_death_count 
FROM [PortfolioProjectSQL1]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count  DESC

SELECT * FROM [PortfolioProjectSQL1]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4; 

--LETS BREAK THINGS DOWN BY CONTINENT / ali NISU TOČNI 
SELECT continent, MAX(CAST (total_deaths  as int)) as  total_death_count 
FROM [PortfolioProjectSQL1]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count  DESC


--LETS BREAK THINGS DOWN BY CONTINENT / ali OVI SU  TOČNI 
SELECT location, MAX(CAST (total_deaths  as int)) as  total_death_count 
FROM [PortfolioProjectSQL1]..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count  DESC

--showing continent with the highest death count per population 
SELECT location, MAX(CAST (total_deaths  as int)) as  total_death_count 
FROM [PortfolioProjectSQL1]..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count  DESC

--GLOBAL NUMBERS 
--FROM  LOOKING AT TOTAL CASES  VS TOTAL DEATHS / shows percentage of deaths in your country IF YOU CATHC COVID 
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as death_percentage
FROM [PortfolioProjectSQL1]..CovidDeaths$
--WHERE location like %states%
WHERE continent IS NOT NULL 
GROUP BY date 
ORDER BY 1,2

--uklonimo date 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as death_percentage
FROM [PortfolioProjectSQL1]..CovidDeaths$
--WHERE location like %states%
WHERE continent IS NOT NULL 
--GROUP BY date 
ORDER BY 1,2


--WE ARE JOINIG TABLES 
SELECT *
FROM PortfolioProjectSQL1..CovidDeaths$ DEA 
JOIN PortfolioProjectSQL1..CovidVaccinations$ VACC
ON DEA.location = VACC.location 
and DEA.date = VACC.date 

-- looking at TOTALPopulation vs Vaccinations 
SELECT 
dea.continent, DEA.location, dea.date, dea.population, vacc.new_vaccinations
FROM PortfolioProjectSQL1..CovidDeaths$ DEA 
JOIN PortfolioProjectSQL1..CovidVaccinations$ VACC
ON DEA.location = VACC.location 
and DEA.date = VACC.date 
order by 1, 2,3 


-- looking at TOTALPopulation vs Vaccinations 
SELECT 
dea.continent, DEA.location, dea.date, dea.population, vacc.new_vaccinations
FROM PortfolioProjectSQL1..CovidDeaths$ DEA 
JOIN PortfolioProjectSQL1..CovidVaccinations$ VACC
ON DEA.location = VACC.location 
and DEA.date = VACC.date 
WHERE dea.continent IS NOT NULL 
order by 1, 2,3 

SELECT 
dea.continent, DEA.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCumulativePeopleVaccinted
, RollingCumulativePeopleVaccinted/population*100 
FROM PortfolioProjectSQL1..CovidDeaths$ DEA 
JOIN PortfolioProjectSQL1..CovidVaccinations$ VACC
ON DEA.location = VACC.location 
and DEA.date = VACC.date 
WHERE dea.continent IS NOT NULL 
order by 2,3 

--USE CTE 

WITH PopulvsVacc  (	Continent, Location, Date, Population, New_Vaccinations, RollingCumulativePeopleVaccinted)
AS (
SELECT 
dea.continent, DEA.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCumulativePeopleVaccinted
--, RollingCumulativePeopleVaccinted/population*100 
FROM PortfolioProjectSQL1..CovidDeaths$ DEA 
JOIN PortfolioProjectSQL1..CovidVaccinations$ VACC
ON DEA.location = VACC.location 
and DEA.date = VACC.date 
WHERE dea.continent IS NOT NULL 
--order by 2,3 
)
SELECT *,  (RollingCumulativePeopleVaccinted/population)*100 
FROM PopulvsVacc







--TEMP TABLE
DROP Table if exists  #PercentPopulationVaccinated   --bitno za buduće izmjene tabele 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingCumulativePeopleVaccinted numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, DEA.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCumulativePeopleVaccinted
--, RollingCumulativePeopleVaccinted/population*100 
FROM PortfolioProjectSQL1..CovidDeaths$ DEA 
JOIN PortfolioProjectSQL1..CovidVaccinations$ VACC
ON DEA.location = VACC.location 
and DEA.date = VACC.date 
--WHERE dea.continent IS NOT NULL 
--order by 2,3 
SELECT *,  (RollingCumulativePeopleVaccinted/population)*100 
FROM #PercentPopulationVaccinated


--create VIEW to store data for later visualisation 
Create View PercentPopulationVaccinated	 as
SELECT dea.continent, DEA.location, dea.date, dea.population, vacc.new_vaccinations
,SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCumulativePeopleVaccinted
--, RollingCumulativePeopleVaccinted/population*100 
FROM PortfolioProjectSQL1..CovidDeaths$ DEA 
JOIN PortfolioProjectSQL1..CovidVaccinations$ VACC
ON DEA.location = VACC.location 
and DEA.date = VACC.date 
WHERE dea.continent IS NOT NULL 
--Order by 2,3 

SELECT *
FROM PercentPopulationVaccinated