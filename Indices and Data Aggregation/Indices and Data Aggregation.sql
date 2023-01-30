USE [Gringotts]
GO

-- 01. Records’ Count

SELECT COUNT([Id])
          AS [Count]
        FROM [WizzardDeposits]

-- 02. Longest Magic Wand

SELECT MAX([MagicWandSize])
        AS [LongestMagicWand]
      FROM [WizzardDeposits]

-- 03. Longest Magic Wand per Deposit Groups

  SELECT [DepositGroup],
     MAX([MagicWandSize]) AS [LongestMagicWand]
    FROM [WizzardDeposits]
GROUP BY [DepositGroup]

-- 04. Smallest Deposit Group per Magic Wand Size

SELECT TOP(2) [DepositGroup]
         FROM [WizzardDeposits]
     GROUP BY [DepositGroup]
 ORDER BY AVG([MagicWandSize]) ASC

-- 05. Deposits Sum

  SELECT [DepositGroup],
     SUM([DepositAmount]) AS [TotalSum]
    FROM [WizzardDeposits]
GROUP BY [DepositGroup]

-- 06. Deposits Sum for Ollivander Family

  SELECT [DepositGroup],
     SUM([DepositAmount]) AS [TotalSum]
    FROM [WizzardDeposits]
   WHERE [MagicWandCreator] = 'Ollivander family'
GROUP BY [DepositGroup]

-- 07. Deposits Filter

    SELECT [DepositGroup],
       SUM([DepositAmount]) AS [TotalSum]
      FROM [WizzardDeposits]
     WHERE [MagicWandCreator] = 'Ollivander family'
  GROUP BY [DepositGroup]
HAVING SUM([DepositAmount]) <= 150000
  ORDER BY [TotalSum] DESC

-- 08. Deposit Charge

  SELECT [DepositGroup],[MagicWandCreator],
     MIN([DepositCharge]) AS [MinDepositCharge]
    FROM [WizzardDeposits] 
GROUP BY [DepositGroup], [MagicWandCreator]
ORDER BY [MagicWandCreator],
		 [DepositGroup]

-- 09. Age Groups

      SELECT [AgeGroup],
 COUNT(*) AS [WizardCount] FROM 
(
	SELECT
	CASE
		WHEN [Age] BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN [Age] BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN [Age] BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN [Age] BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN [Age] BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN [Age] BETWEEN 51 AND 60 THEN '[51-60]'
		WHEN [Age] >= 61 THEN '[61+]'
	  END AS [AgeGroup]
	    FROM [WizzardDeposits]
)
          AS [AgeGroupsSubQ]
    GROUP BY [AgeGroup]

-- 10. First Letter
SELECT * FROM
(
	  SELECT
	  DISTINCT LEFT([FirstName], 1)
				 AS [FirstLetter]
			   FROM [WizzardDeposits]
			  WHERE [DepositGroup] = 'Troll Chest'
)AS [SubQ]
GROUP BY [FirstLetter]
ORDER BY [FirstLetter]

-- 11. Average Interest

  SELECT [DepositGroup],[IsDepositExpired],
     AVG([DepositInterest]) AS [AverageInterest]
    FROM [WizzardDeposits]
   WHERE [DepositStartDate] > '1985-01-01'
GROUP BY [DepositGroup], [IsDepositExpired]
ORDER BY [DepositGroup] DESC,
		 [IsDepositExpired] ASC

-- 12. *Rich Wizard, Poor Wizard

SELECT SUM(Difference) AS [SumDifference] FROM 
(
		SELECT wd1.[FirstName] AS [Host Wizard],
		       wd1.[DepositAmount] AS [Host Wizard Deposit],
		       wd2.[FirstName] AS [Guest Wizard],
		       wd2.[DepositAmount] AS [Guest Wizard Deposit],
		       wd1.[DepositAmount] - wd2.[DepositAmount] AS [Difference]
	          FROM [WizzardDeposits] AS [wd1]
	          JOIN [WizzardDeposits] AS [wd2]
	        ON wd1.[Id] + 1 = wd2.[Id]
) AS [SubQ]

USE [SoftUni]
GO

-- 13. Departments Total Salaries

  SELECT [DepartmentID],
     SUM([Salary]) AS [TotalSalary]
    FROM [Employees]
GROUP BY [DepartmentID]
ORDER BY [DepartmentID]

-- 14. Employees Minimum Salaries

  SELECT [DepartmentID],
     MIN([Salary]) AS [MinimumSalary]
    FROM [Employees]
   WHERE [HireDate] > '2000-01-01' AND
	     [DepartmentID] IN (2,5,7)
GROUP BY [DepartmentID]

-- 15. Employees Average Salaries

SELECT * INTO [Newtable]
         FROM [Employees]
        WHERE [Salary] > 30000

DELETE FROM [Newtable]
      WHERE [ManagerID] = 42

UPDATE [Newtable]
   SET [Salary] += 5000
 WHERE [DepartmentID] = 1

  SELECT [DepartmentID],
      AVG(Salary) AS [AverageSalary]
    FROM [Newtable]
GROUP BY [DepartmentID]

-- 16. Employees Maximum Salaries

  SELECT [DepartmentID],
     MAX([Salary]) AS MaxSalary
    FROM [Employees]
GROUP BY [DepartmentID]
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

-- 17. Employees Count Salaries

SELECT SUM(CASE WHEN [ManagerID] IS NULL THEN 1 END) AS [Count]
                FROM [Employees]
            GROUP BY [ManagerID]
HAVING SUM(CASE WHEN [ManagerID] IS NULL THEN 1 END) IS NOT NULL