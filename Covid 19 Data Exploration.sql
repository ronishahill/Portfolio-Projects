/*
Covid 19 Data Exploration

Skills Used: Joins, Windows Functions, Aggregate Functions, Converting Data Types, CTE's, Temp Tables, Creating Views

*/


SELECT *
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 


-- Selecting the data that we are going to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows the likihood of dying if you contract Covid in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM portfolio_project.coviddeaths
WHERE location = 'United States'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of the population has contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_by_population
FROM portfolio_project.coviddeaths
-- WHERE location = 'United States'
ORDER BY 1,2


-- Countries with the Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM portfolio_project.coviddeaths
-- WHERE location = 'United States'
GROUP BY location, population
ORDER BY percent_population_infected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


-- Breaking data down by Continent 

-- Continents with Highest Death Count per Population 

SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


-- Global Numbers by date

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Global Number overall

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS death_percentage
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vax
	ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 


-- Using CTE to perform calculation on Partition By from pervious query

WITH populationvsvaccinations (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)  
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vax
	ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL  
)
SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_percentage
FROM populationvsvaccinations


-- Using TEMP TABLE to perform calculation on Partition By from pervious query

DROP TABLE IF exist #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar (225),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percentpoplationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vax
	ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL  
)
SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_percentage
FROM populationvsvaccinations


-- Creating View to store data for later visulizations

CREATE VIEW percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM portfolio_project.coviddeaths dea
JOIN portfolio_project.covidvaccinations vax
	ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL  
