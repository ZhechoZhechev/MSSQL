USE [SoftUni]
GO

-- 01. Employee Address

SELECT TOP(5) e.[EmployeeID], e.[JobTitle], a.[AddressID], a.[AddressText] 
	FROM [Employees] AS e
	JOIN [Addresses] AS a
	ON e.AddressID = a.AddressID
	ORDER BY e.[AddressID]

-- 02. Addresses with Towns

SELECT TOP(50) e.[FirstName], e.[LastName], t.[Name] AS [Town], a.[AddressText] 
	FROM [Employees] AS e
	JOIN [Addresses] AS a
	ON e.[AddressID] = a.AddressID
	JOIN [Towns] AS t
	ON t.[TownID] = a.[TownID]
	ORDER BY e.[FirstName] ASC,
			 e.[LastName] ASC

-- 03. Sales Employees

SELECT e.[EmployeeID], e.[FirstName], e.[LastName], d.[Name] AS [DepartmentName]
	FROM [Employees] AS e
	JOIN [Departments] as d
	ON e.[DepartmentID] = d.[DepartmentID]
	WHERE d.[Name] = 'Sales'
	ORDER BY e.[EmployeeID] ASC

-- 04. Employee Departments

SELECT TOP(5) e.[EmployeeID], e.[FirstName], e.[Salary], d.[Name] AS [DepartmentName]
	FROM [Employees] AS e
	JOIN [Departments] as d
	ON e.[DepartmentID] = d.[DepartmentID]
	WHERE e.[Salary] > 15000
	ORDER BY d.[DepartmentID] ASC

-- 05. Employees Without Projects

SELECT TOP(3) e.[EmployeeID], e.[FirstName] FROM [Employees] AS e
	  LEFT JOIN [EmployeesProjects] AS ep
	       ON e.[EmployeeID] = ep.[EmployeeID]
	  LEFT JOIN [Projects] AS p
	      ON ep.[ProjectID] = p.[ProjectID]
	   WHERE ep.[ProjectID] IS NULL
	 ORDER BY e.[EmployeeID]

-- 06. Employees Hired After

SELECT e.[FirstName], e.[LastName], e.[HireDate], d.[Name] AS [DeptName]
	FROM [Employees] AS e
	JOIN [Departments] AS d
	ON e.[DepartmentID] = d.[DepartmentID]
 WHERE d.[Name] IN ('Sales', 'Finance') AND
	   e.[HireDate] > '1999-01-01'

-- 07. Employees With Project

SELECT TOP(5) e.[EmployeeID], e.[FirstName], p.[Name] AS [ProjectName] 
           FROM [Employees] AS e
	       JOIN [EmployeesProjects] AS ep
	       ON e.[EmployeeID] = ep.[EmployeeID]
	       JOIN [Projects] AS p
          ON ep.[ProjectID] = p.[ProjectID]
        WHERE p.[StartDate] > '2002-08-13' AND
		      p.[EndDate] IS NULL

-- 08. Employee 24

SELECT e.[EmployeeID], e.[FirstName],
  CASE 
  WHEN p.[StartDate] >= '2005-01-01' THEN NULL
  ELSE p.[Name]
  END AS [ProjectName]
    FROM [Employees] AS e
	JOIN [EmployeesProjects] AS ep
	ON e.[EmployeeID] = ep.[EmployeeID]
	JOIN [Projects] AS p
   ON ep.[ProjectID] = p.[ProjectID]
 WHERE e.[EmployeeID] = 24

-- 09. Employee Manager

SELECT e.[EmployeeID], e.[FirstName], e.[ManagerID], e1.[FirstName]
      AS [ManagerName] 
    FROM [Employees] AS e
    JOIN [Employees] AS e1
    ON e.[ManagerID]  = e1.[EmployeeID]
WHERE e.[ManagerID] IN (3, 7)
ORDER BY e.[EmployeeID] ASC

-- 10. Employees Summary

SELECT TOP(50) e.[EmployeeID],
        CONCAT(e.[FirstName], ' ', e.[LastName]) AS [EmployeeName],
        CONCAT(m.[FirstName], ' ', m.[LastName])AS [ManagerName],
               d.[Name] AS [DepartmentName] 
            FROM [Employees] AS e
            JOIN [Employees] AS m
            ON e.[ManagerID] = m.[EmployeeID]
            JOIN [Departments] AS d
            ON e.[DepartmentID] = d.[DepartmentID]
      ORDER BY e.[EmployeeID] ASC

-- 11. Min Average Salary

SELECT MIN(a.[AvSalary]) AS MinAverageSalary
FROM 
(

    SELECT [DepartmentID], AVG([Salary])AS [AvSalary]
      FROM [Employees]
  GROUP BY [DepartmentID]

) AS a

-- 12. Highest Peaks in Bulgaria
USE [Geography]
GO

SELECT mc.[CountryCode], m.[MountainRange], p.[PeakName], p.[Elevation] 
     FROM [Peaks] AS p
     JOIN [Mountains] AS m
     ON p.[MountainId] = m.[Id]
     JOIN [MountainsCountries] AS mc
    ON mc.[MountainId] = m.[Id]
 WHERE mc.[CountryCode] = 'BG' AND
	    p.[Elevation] > 2835
ORDER BY p.[Elevation] DESC

-- 13. Count Mountain Ranges

SELECT c.CountryCode,
		COUNT(mc.MountainId) AS [MountainRanges]
        FROM [Countries] AS c
   LEFT JOIN [MountainsCountries] AS mc
        ON c.[CountryCode] = mc.[CountryCode]
     WHERE c.[CountryCode] IN ('US', 'RU', 'BG')
  GROUP BY c.[CountryCode]


 -- 14. Countries With or Without Rivers

SELECT TOP(5) c.[CountryName], r.[RiverName]
           FROM [Countries] AS c
           JOIN [Continents] AS cn
           ON c.[ContinentCode] = cn.[ContinentCode]
      LEFT JOIN [CountriesRivers] AS cr
          ON cr.[CountryCode] = c.[CountryCode]
      LEFT JOIN [Rivers] AS r
          ON cr.[RiverId] = r.[Id]
       WHERE cn.[ContinentName] = 'Africa'
     ORDER BY c.[CountryName] ASC

-- 15. Continents and Currencies

SELECT [ContinentCode], [CurrencyCode], [CurrencyUsage]
FROM 
(
	 SELECT *,
	DENSE_RANK() OVER(PARTITION BY [ContinentCode] ORDER BY [CurrencyUsage] DESC) AS [CurrencyRank]
	FROM 
	(

		SELECT [ContinentCode], [CurrencyCode],
		COUNT(ContinentCode) AS CurrencyUsage
		FROM [Countries] 
		GROUP BY [ContinentCode], [CurrencyCode]

	) AS [CurencyUsageQuery]
	WHERE [CurrencyUsage] > 1

)AS [TakeFirstRankSubquery]
WHERE [CurrencyRank] = 1
ORDER BY [ContinentCode]

-- 16. Countries Without any Mountains

SELECT COUNT(c.[CountryCode]) AS [Count]
        FROM [Countries] AS c
   LEFT JOIN [MountainsCountries] mc
       ON mc.[CountryCode] = c.[CountryCode]
    WHERE mc.[MountainId] IS NULL

-- 17. Highest Peak and Longest River by Country

SELECT TOP(5) c.[CountryName],
       MAX(p.[Elevation]) AS [HighestPeakElevation],
       MAX(r.[Length]) AS [LongestRiverLength]
        FROM [Peaks] AS p
        JOIN [MountainsCountries] AS mc
        ON p.[MountainId] = mc.[MountainId]
        JOIN [Countries] AS c
       ON mc.[CountryCode] = c.[CountryCode]
        JOIN [CountriesRivers] AS cr
       ON cr.[CountryCode] = c.[CountryCode]
        JOIN [Rivers] AS r
       ON cr.[RiverId] = r.[Id]
    GROUP BY [CountryName]
    ORDER BY [HighestPeakElevation] DESC,
		     [LongestRiverLength] DESC,
		     [CountryName]

-- 18. Highest Peak Name and Elevation by Country
USE [Geography]
GO

SELECT TOP(5) [CountryName] AS [Country],
	   CASE 
	   WHEN [PeakName] IS NULL THEN '(no highest peak)'
	   ELSE [PeakName]
	   END AS [Highest Peak Name],
	   CASE
	   WHEN [PeakName] IS NULL THEN '0'
	   ELSE [Elevation]
	   END AS [Highest Peak Elevation],
	   CASE WHEN [MountainRange] IS NULL THEN '(no mountain)'
	   ELSE [MountainRange]
	   END AS [Mountain]
FROM 
(
	SELECT c.[CountryName], p.[PeakName], p.[Elevation], m.[MountainRange],
	DENSE_RANK() OVER(PARTITION BY c.[CountryName] ORDER BY p.[Elevation] DESC)
	AS [PeakRanks]
	FROM [Countries] AS c
	LEFT JOIN [MountainsCountries] AS mc
	ON mc.[CountryCode] = c.[CountryCode]
	LEFT JOIN [Mountains] AS m
	ON mc.[MountainId] = m.[Id]
	LEFT JOIN [Peaks] AS p
	ON p.[MountainId] = m.[Id]
)
AS [PeaksRankingSubQ]
WHERE [PeakRanks] = 1
ORDER BY [CountryName],
		 [PeakName]