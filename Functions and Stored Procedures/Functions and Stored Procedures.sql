USE [SoftUni]
GO

-- 01. Employees with Salary Above 35000

CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
BEGIN
	SELECT [FirstName], [LastName]
	  FROM [Employees]
	 WHERE [Salary] > 35000
END

GO

-- 02. Employees with Salary Above Number

CREATE PROC usp_GetEmployeesSalaryAboveNumber (@salaryValue DECIMAL(18,4))
AS
BEGIN
	SELECT [FirstName], [LastName]
	  FROM [Employees]
	  WHERE[Salary] >= @salaryValue
END

EXEC dbo.usp_GetEmployeesSalaryAboveNumber 48100

GO

-- 03. Town Names Starting With

CREATE OR ALTER PROC usp_GetTownsStartingWith (@startsWith VARCHAR(30))
AS
BEGIN
	SELECT [Name] AS [Town]
	  FROM [Towns]
	 WHERE SUBSTRING([Name], 1, LEN(@startsWith)) = @startsWith
END

GO
-- 04. Employees from Town

CREATE PROC usp_GetEmployeesFromTown (@townName VARCHAR(50))
AS
BEGIN 
	   SELECT e.[FirstName],
		      e.[LastName]
	       FROM [Employees] AS e
	       JOIN [Addresses] AS a
	       ON e.[AddressID] = a.[AddressID]
	       JOIN [Towns] AS t
	       ON a.[TownID] = t.TownID 
		WHERE t.[Name] = @townName
END

GO

-- 05. Salary Level Function

CREATE FUNCTION ufn_GetSalaryLevel (@salary DECIMAL(18,4))
RETURNS VARCHAR(7)
BEGIN
	DECLARE @salaryLevel VARCHAR (7)
	IF(@salary < 30000)
		SET @salaryLevel = 'Low'
	ELSE IF(@salary BETWEEN 30000 AND 50000)
		SET @salaryLevel = 'Average'
	ELSE
		SET @salaryLevel = 'High'
	RETURN @salaryLevel
END

GO

SElECT [Salary],
dbo.ufn_GetSalaryLevel ([Salary]) AS [SalaryLevel]
FROM [Employees]
ORDER BY [Salary] DESC

GO

-- 06. Employees by Salary Level

CREATE PROC usp_EmployeesBySalaryLevel(@salaryLevel VARCHAR(7))
AS
BEGIN
	SELECT [FirstName], [LastName]
	FROM [Employees]
	WHERE dbo.ufn_GetSalaryLevel([Salary]) = @salaryLevel
END

GO

-- 07. Define Function

CREATE OR ALTER FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN
DEClARE @index INT = 1
DECLARE @lenght INT = LEN(@word)
DECLARE @curLetter CHAR(1)
WHILE(@index <= @lenght)
	BEGIN
		SET @curLetter = SUBSTRING(@word, @index, 1)
		IF(CHARINDEX(@curLetter, @setOfLetters) > 0)
			SET @index += 1
		ELSE
			RETURN 0
	END
		RETURN 1
END

GO

-- 08. *Delete Employees and Departments

CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS 
BEGIN
	ALTER TABLE [Departments]
	ALTER COLUMN [ManagerID] INT NULL

	DELETE FROM [EmployeesProjects]
	WHERE [EmployeeID] IN 
	(
		SELECT [EmployeeID] FROM [Employees]
		WHERE [DepartmentID] = @departmentId
	)

	UPDATE [Employees]
	SET [ManagerID] = NULL
	WHERE [ManagerID] IN
	(
		SELECT [EmployeeID] FROM [Employees]
		WHERE [DepartmentID] = @departmentId
	)

	UPDATE [Departments]
	SET [ManagerID] = NULL
	WHERE [DepartmentID] = @departmentId

	DELETE FROM [Employees]
	WHERE [DepartmentID] = @departmentId

	DELETE FROM [Departments]
	WHERE [DepartmentID] = @departmentId

	SELECT COUNT(*) FROM [Employees]
	WHERE [DepartmentID] = @departmentId
END

GO

EXEC dbo.usp_DeleteEmployeesFromDepartment 2

-- 09. Find Full Name

USE [Bank]
GO

CREATE PROC usp_GetHoldersFullName
AS
BEGIN
	SELECT CONCAT([FirstName], ' ', [LastName])
			   AS [Full Name]
	         FROM [AccountHolders]
END

GO

-- 10. People with Balance Higher Than

CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan (@margin MONEY)
AS
BEGIN
SELECT [FirstName], [LastName] FROM [AccountHolders] AS ah
JOIN 
(
	  SELECT [AccountHolderId], SUM([Balance])
	      AS [TotalBalance] FROM [Accounts]
	GROUP BY [AccountHolderId]
)
        AS [subQ]
   ON subQ.[AccountHolderId] = ah.[Id]
WHERE subQ.[TotalBalance] > @margin
  ORDER BY [FirstName],
		   [LastName]
END


GO

-- 11. Future Value Function

CREATE OR ALTER FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(18, 4), @yearlyInterest FLOAT, @numOfYears INT)
RETURNS DECIMAL(18, 4)
BEGIN
	RETURN @sum * POWER((1+ @yearlyInterest),@numOfYears)
END

GO
-- 12. Calculating Interest

CREATE OR ALTER PROC usp_CalculateFutureValueForAccount (@accoubtID INT, @yearlyInterest FLOAT)
AS
BEGIN
	SELECT a.[Id] AS [Account Id],
	      ah.[FirstName] AS [First Name],
	      ah.[LastName] AS [Last Name],
	       a.[Balance] AS [Current Balance],
	dbo.ufn_CalculateFutureValue(a.[Balance], @yearlyInterest, 5) AS [Balance in 5 years]
	    FROM [AccountHolders] AS ah
	    JOIN [Accounts] AS a
	    ON a.[AccountHolderId] = ah.[Id]
		WHERE a.[Id] = @accoubtID
END

EXEC dbo.usp_CalculateFutureValueForAccount 4, 0.1 

GO

-- 13. *Cash in User Games Odd Rows

USE [Diablo]
GO

CREATE FUNCTION ufn_CashInUsersGames (@gameName VARCHAR(50))
RETURNS TABLE
AS
RETURN SELECT 
SUM([Cash]) AS [SumCash]
FROM
(
	SELECT ug.[Cash],
	ROW_NUMBER() OVER(ORDER BY ug.[Cash] DESC) AS [RowNumber]
	FROM [UsersGames] AS ug
	JOIN [Games] AS g
	ON ug.[GameId] = g.[Id]
	WHERE g.[Name] = @gameName
	
)
AS [subQ]
WHERE [RowNumber] % 2 = 1

GO

