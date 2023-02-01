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