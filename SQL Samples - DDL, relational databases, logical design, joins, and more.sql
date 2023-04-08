
/*
*@Author: Thomas Sorenson and Jill Mallek
*Description: This is a scriptfor the aggragation and reporting of Coved Deaths by State for the function of a final project in ANYL6250
*
*CHANGELOG:  
 *Created using the following Variables and descriptions:
submission_date - Date of counts - Date & Time
state - Jurisdiction - Plain Text
submission_date - Jurisdiction - Plain Text
tot_cases - Total number of cases - Number
conf_cases - Total confirmed cases - Number
prob_cases - Total probable cases - Number
new_case - Number of new cases - Number
pnew_case - Number of new probable cases - Number
tot_death - Total number of deaths - Number
conf_death - Total number of confirmed deaths - Number
prob_death - Total number of probable deaths - Number
new_death - Number of new deaths - Number
pnew_death - Number of new probable deaths - Number
created_at - Date and time record was created - Date & Time
consent_cases - If Agree, then confirmed and probable cases are included. If Not Agree, then only total cases are included. - Plain Text
consent_deaths - If Agree, then confirmed and probable deaths are included. If Not Agree, then only total deaths are included. - Plain Tex
*12/05/2022 -Adding Sections of project to represent the modiles covered in the course
*Mod2: Intro to Databases
*Mod3: Basic SQL Syntax
*Mod4&5: Joins, Relationships, Logic, Functions, and DML
*Mod6: Code Development standards and best practices
*Mod9&10: DDL/DML Logical Database Design
*Mod11: Set operators, CTE, and temp tables
*mod13: SQL Reports and Dashboard Design
     */


/*
* This script will illustrate use of DDL, Relational Database and logical design
* Putting this first, as we need to alter and adjust our tables before using them.
*/

--Create a table to hold the State + State ID
CREATE TABLE State (	
[State_Id] INTEGER UNIQUE PRIMARY KEY,
[State_Name] VARCHAR(3) UNIQUE
	);

--DROP TABLE State; --This is just to help me as I need to drop it to remake it

--Inserting the States Names into State table + creating a unique ID for each State
INSERT INTO State(State_Name)
SELECT DISTINCT cd.state
FROM CovidDeaths cd

--Testing to make sure it did what I wanted and created a unique ID for each state
SELECT *
FROM State s 
LIMIT 25;

--Adding a column to CovidDeaths to bring the State ID number over from the new State table
ALTER TABLE CovidDeaths 
ADD COLUMN State_Id INTEGER;

--Adding the State ID number based on the state being the same state from the state table
UPDATE CovidDeaths
SET State_Id = st.State_Id
FROM (SELECT State.State_Id, State.State_Name FROM State) st
WHERE state = st.State_Name;

--Testing to make sure it did what I wanted
SELECT cd.State_Id
FROM CovidDeaths cd 
LIMIT 25;

--Renaming the original CovidDeaths table to a backup, in case I need the original states
ALTER TABLE CovidDeaths 
RENAME TO CovidDeathsBackup;

--Creating a new table with a foreign key to the State table
CREATE TABLE CovidDeaths (
	Submission_Key INTEGER NOT NULL,
	Submission_Date VARCHAR(50) NOT NULL,
	State VARCHAR(50) NOT NULL,
	Tot_Cases VARCHAR(50),
	Conf_Cases VARCHAR(50),
	Prob_Cases VARCHAR(50),
	New_Case VARCHAR(50),
	Pnew_Case VARCHAR(50),
	Tot_Death VARCHAR(50),
	Conf_Death VARCHAR(50),
	Prob_Death VARCHAR(50),
	New_Death INTEGER,
	Pnew_Death INTEGER,
	Created_At VARCHAR(50),
	Consent_Cases VARCHAR(50),
	Consent_Deaths VARCHAR(50),
	State_Id INTEGER,
	CONSTRAINT [PK_CD] PRIMARY KEY ([Submission_Key]),
	FOREIGN KEY ([State_Id]) REFERENCES [State] ([State_Id])
);

--Copying over from the Backup into CovidDeaths to the table with the foreign key
INSERT INTO CovidDeaths (
	Submission_Date, 
	State,
	Tot_Cases,
	Conf_Cases,
	Prob_Cases,
	New_Case,
	Pnew_Case,
	Tot_Death,
	Conf_Death,
	Prob_Death,
	New_Death,
	Pnew_Death,
	Created_At,
	Consent_Cases,
	Consent_Deaths,
	State_Id)
SELECT submission_date
	, state
	, tot_cases
	, conf_cases
	, prob_cases
	, new_case
	, pnew_case
	, tot_death
	, conf_death
	, prob_death
	, new_death
	, pnew_death
	, created_at
	, consent_cases
	, consent_deaths
	, State_Id
FROM CovidDeathsBackup; 

--Dropping State column, since I no longer need it, since the tables are properly linking
ALTER TABLE CovidDeaths 
DROP COLUMN state;
 
/* 
 * This section illustrates the goals of Modules 2-4. The syntax, logic, setup and functions of using SQL in a database. in this case a database created with a singlur dataset.
 *This script will show the basic totals of cases of coved by state and the total deaths by state. There is no extra data about probable or confirmed cases in this report
 */ 
 
SELECT DISTINCT
s.state_Name  AS 'State'
, cdbs.tot_death AS 'Total Deaths' 
, cdbs.tot_cases AS 'Total Cases' 
FROM CovidDeaths cdbs
 LEFT JOIN State s
 ON s.State_Id=cdbs.State_Id
 GROUP BY 1, 2, 3

 /*
* This script will show the breakdown of cases and deaths by state. These are sepereated into probable and confirmed cases and deaths.
*/
*/

SELECT DISTINCT 
s.State_Name  AS 'State' 
, cdbs.conf_death AS'Confirmed Deaths' 
, cdbs.prob_death  AS 'probable Deaths'
, cdbs.conf_cases  AS 'Confirmed Cases'
, cdbs.prob_cases AS 'Probable Cases' 
FROM CovidDeaths cdbs 
 LEFT JOIN State s
 ON s.State_Id=cdbs.State_Id  
 GROUP BY 1, 2, 3, 4, 5 ;
 
/*
*This script will Make table for percentage of deaths by state USING TMP TABLES 
*/

CREATE TEMP TABLE Percentage_Deaths_By_State AS 
 SELECT
s.State_Name  AS 'State' 
, ROUND(cdbs.tot_death / SUM(cdbs.tot_death)*100, 4) || '%' AS 'Percentage of Deaths' 
 FROM CovidDeaths cdbs
 LEFT JOIN State s 
 ON s.State_Id=cdbs.State_Id  
 GROUP BY 1; 

/*
 * This script will do the same as above but with cases  
  */
 
CREATE TEMP TABLE Percentage_Cases_By_State AS
SELECT
s.State_Name  AS 'State'
, ROUND(cdbs.tot_cases / SUM(cdbs.tot_cases)*100, 4) || '%' AS 'Percentage of Cases' 
FROM CovidDeaths cdbs 
LEFT JOIN State s  
ON s.State_Id =cdbs.State_Id 
GROUP BY 1;

