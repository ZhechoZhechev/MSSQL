USE [SoftUni]
GO
-- 1)Find All the Information About Departments

SELECT * FROM [Departments]

-- 2)Find all Department Names

SELECT [Name] FROM [Departments]

-- 3)Find Salary of Each Employee

SELECT [FirstName], [LastName], [Salary]
  FROM [Employees]

-- 4)Find Full Name of Each Employee

SELECT [FirstName],[MiddleName], [LastName]
  FROM [Employees]

-- 5)Find Email Address of Each Employee

SELECT 
CONCAT([FirstName], '.', [LastName], '@', 'softuni.bg' )
    AS [Full Email Address]
  FROM [Employees] 

-- 6)Find All Different Employees' Salaries

SELECT DISTINCT [Salary]
  FROM [Employees]

-- 7)Find All Information About Employees

SELECT * FROM [Employees]
 WHERE [JobTitle] = 'Sales Representative'

-- 8)Find Names of All Employees by Salary in Range

SELECT [FirstName], [LastName], [JobTitle]
  FROM [Employees]
 WHERE [Salary] BETWEEN 20000 AND 30000

-- 9)Find Names of All Employees

SELECT 
CONCAT([FirstName], ' ', [MiddleName], ' ', [LastName]) 
    AS [Full Name]
  FROM [Employees]
 WHERE [Salary] IN (25000, 14000, 12500, 23600)

-- 10)Find All Employees Without a Manager

SELECT * FROM [Employees] 

SELECT [FirstName], [LastName] 
  FROM [Employees]
 WHERE [ManagerID] IS NULL

-- 11)Find All Employees with a Salary More Than 50000

SELECT [FirstName], [LastName], [Salary]
  FROM [Employees]
 WHERE [Salary] > 50000
 ORDER BY [Salary] DESC

-- 12)Find 5 Best Paid Employees

SELECT TOP(5) [FirstName], [LastName]
  FROM [Employees]
 ORDER BY [Salary] DESC

-- 13)Find All Employees Except Marketing

SELECT [FirstName], [LastName]
  FROM [Employees]
 WHERE [DepartmentID] <> 4

-- 14)Sort Employees Table

SELECT * FROM [Employees]
ORDER BY [Salary] DESC,
		 [FirstName] ASC,
		 [LastName] DESC,
		 [MiddleName] ASC

-- 15)Create View Employees with Salaries
GO

CREATE VIEW V_EmployeesSalaries
         AS
		  (
	 SELECT [FirstName], [LastName], [Salary]
	   FROM [Employees]
	      )

-- 16)Create View Employees with Job Titles
GO

CREATE VIEW V_EmployeeNameJobTitle AS
(
SELECT CONCAT([FirstName], ' ', [MiddleName], ' ', [LastName])
    AS [Full Name],
	   [JobTitle]
	FROM [Employees]
)

-- 17)Distinct Job Titles

SELECT DISTINCT [JobTitle] 
FROM [Employees]

-- 18)Find First 10 Started Projects

SELECT TOP(10) * FROM [Projects]
  ORDER BY [StartDate],
           [Name]


-- 19)Last 7 Hired Employees

SELECT TOP(7) [FirstName], [LastName], [HireDate]
      FROM [Employees]
  ORDER BY [HireDate] DESC

-- 20)Increase Salaries

SELECT * FROM [Departments]
WHERE [Name] IN ('Engineering', 'Tool Design', 'Marketing', 'Information Services')

UPDATE [Employees]
   SET [Salary] *= 1.12
 WHERE [DepartmentID] IN (1, 2, 4, 11)

SELECT [Salary] 
  FROM [Employees]

--UPDATE [Employees]
--   SET [Salary] /= 1.12
-- WHERE [DepartmentID] IN (1, 2, 4, 11)

-- 21)All Mountain Peaks
USE [Geography]
GO

SELECT [PeakName]
  FROM [Peaks]
 ORDER BY [PeakName] ASC


-- 22)Biggest Countries by Population

SELECT TOP(30) [CountryName], [Population]
  FROM [Countries]
  WHERE [ContinentCode] = 'EU'
  ORDER BY [Population] DESC,
           [CountryName] ASC

-- 23)Countries and Currency (Euro / Not Euro)

SELECT [CountryName], [CountryCode],
  CASE WHEN [CurrencyCode] = 'EUR' THEN 'Euro'
  ELSE 'Not Euro'
   END AS [Currency]
  FROM [Countries]
 ORDER BY [CountryName]


 -- 24)All Diablo Characters

 USE [Diablo]
 GO

 SELECT [Name]
   FROM [Characters]
  ORDER BY [Name] ASC