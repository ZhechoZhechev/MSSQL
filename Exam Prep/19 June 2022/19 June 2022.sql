-- 01. DDL

CREATE DATABASE [Zoo]
GO
USE [Zoo]
GO

CREATE TABLE [Owners]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PhoneNumber] VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50)
)

CREATE TABLE [AnimalTypes]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[AnimalType] VARCHAR(30) NOT NULL,
)

CREATE TABLE [Cages]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[AnimalTypeId] INT FOREIGN KEY REFERENCES [AnimalTypes](Id) NOT NULL
)

CREATE TABLE [Animals]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	[BirthDate] DATE NOT NULL,
	[OwnerId] INT FOREIGN KEY REFERENCES [Owners](Id),
	[AnimalTypeId] INT FOREIGN KEY REFERENCES [AnimalTypes](Id) NOT NULL
)

CREATE TABLE [AnimalsCages]
(
	[CageId] INT FOREIGN KEY REFERENCES [Cages](Id) NOT NULL,
	[AnimalId] INT FOREIGN KEY REFERENCES [Animals](Id) NOT NULL,
	PRIMARY KEY ([CageId], [AnimalId])
)

CREATE TABLE [VolunteersDepartments]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[DepartmentName] VARCHAR(30) NOT NULL
)

CREATE TABLE [Volunteers]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PhoneNumber] VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	[AnimalId] INT FOREIGN KEY REFERENCES [Animals](Id),
	[DepartmentId] INT FOREIGN KEY REFERENCES [VolunteersDepartments](Id) NOT NULL
)

-- 02. Insert

INSERT INTO Volunteers VALUES
    ('Anita Kostova',	'0896365412',	'Sofia, 5 Rosa str.',   	15,	1),
    ('Dimitur Stoev',	'0877564223',	NULL,	                    42,	4),
    ('Kalina Evtimova',	'0896321112',	'Silistra, 21 Breza str.',	9,	7),
    ('Stoyan Tomov',	'0898564100',	'Montana, 1 Bor str.',  	18,	8),
    ('Boryana Mileva',	'0888112233',	NULL,	                    31,	5)

INSERT INTO Animals VALUES
    ('Giraffe',	        '2018-09-21',	 21,	1),
    ('Harpy Eagle',	    '2015-04-17',	 15,	3),
    ('Hamadryas Baboon','2017-11-02',  NULL,	1),
    ('Tuatara',	        '2021-06-30',  	  2,	4)

-- 03. Update

SELECT [Id] FROM [Owners]
WHERE [Name] = 'Kaloqn Stoqnov'

UPDATE [Animals]
SET [OwnerId] = (
			SELECT [Id] FROM [Owners]
			WHERE [Name] = 'Kaloqn Stoqnov'
			)
WHERE [OwnerId] IS NULL

-- 04. Delete

SELECT [Id] FROM [VolunteersDepartments]
WHERE [DepartmentName] = 'Education program assistant'

DELETE [Volunteers]
WHERE [DepartmentId] = 
(
	SELECT [Id] FROM [VolunteersDepartments]
	WHERE [DepartmentName] = 'Education program assistant'
)

DELETE [VolunteersDepartments]
WHERE [DepartmentName] = 'Education program assistant'

-- FRESH DATABASE

-- 05. Volunteers

  SELECT [Name],
         [PhoneNumber], 
         [Address], 
         [AnimalId], 
         [DepartmentId] 
	FROM [Volunteers]
ORDER BY [Name],
		 [AnimalId],
		 [DepartmentId]

-- 06. Animals data

  SELECT a.[Name],
	   ant.[AnimalType],
  FORMAT(a.[BirthDate], 'dd.MM.yyyy') AS [BirthDate]
      FROM [Animals] AS a
 LEFT JOIN [AnimalTypes] AS ant
      ON a.[AnimalTypeId] = ant.[Id]
ORDER BY a.[Name]

-- 07. Owners and Their Animals

SELECT TOP(5) o.[Name] AS [Owner],
        COUNT(a.[Name]) AS CountOfAnimals
           FROM [Animals] AS a
           JOIN [Owners] as o
           ON a.[OwnerId] = o.[Id]
     GROUP BY o.[Name]
       ORDER BY [CountOfAnimals] DESC, Owner ASC

-- 08. Owners, Animals and Cages

SELECT 
  CONCAT(o.[Name], '-', a.[Name]) AS [OwnersAnimals],
         o.[PhoneNumber],
  	  ac.[CageId]
      FROM [Owners] AS o
      JOIN [Animals] AS a
      ON a.[OwnerId] = o.[Id]
      JOIN [AnimalTypes] AS ant
      ON a.[AnimalTypeId] = ant.[Id]
      JOIN [AnimalsCages] AS ac
     ON ac.[AnimalId] = a.[Id]
   WHERE a.[AnimalTypeId] = (SELECT [Id] FROM [AnimalTypes] WHERE [AnimalType] = 'mammals')
ORDER BY o.[Name],
		 a.[Name] DESC

-- 09. Volunteers in Sofia

SELECT [Id] FROM [VolunteersDepartments]
WHERE [DepartmentName] = 'Education program assistant'

SELECT [Name],
[PhoneNumber],
SUBSTRING([Address], CHARINDEX(',', [Address]) + 2, LEN([Address]))
FROM [Volunteers]
WHERE [Address] LIKE '%Sofia%' AND
	  [DepartmentId] = 
	  (
		SELECT [Id] FROM [VolunteersDepartments]
		WHERE [DepartmentName] = 'Education program assistant'
	  )
ORDER BY [Name]

-- 10. Animals for Adoption

        SELECT a.[Name],
          YEAR(a.[BirthDate]) AS [BirthYear],
			 ant.[AnimalType]
            FROM [Animals] AS a
       LEFT JOIN [AnimalTypes] AS ant
			ON a.[AnimalTypeId] = ant.[Id]
		 WHERE a.[OwnerId] IS NULL AND
             ant.[AnimalType] <> 'Birds' AND
DATEDIFF(YEAR, a.[BirthDate], '01/01/2022' ) < 5
      ORDER BY a.[Name]
		

-- 11. All Volunteers in a Department
GO

CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@volunteersDepartment VARCHAR(30))
RETURNS INT
BEGIN
	DECLARE @depId INT
	SET @depId = (SELECT [Id] FROM [VolunteersDepartments] WHERE [DepartmentName] = @volunteersDepartment)
	DECLARE @count INT
	SET @count = 
				(
					SELECT COUNT([Name]) FROM [Volunteers] WHERE [DepartmentId] = @depId
				)
	RETURN @count
END

GO

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')

-- 12. Animals with Owner or Not
GO

CREATE PROC usp_AnimalsWithOwnersOrNot(@animalName VARCHAR(30))
AS
BEGIN
	SELECT
	          a.[Name],
	CASE WHEN
		      a.[OwnerId] IS NULL THEN 'For adoption'
		 ELSE o.[Name]
		 END 
		     AS [OwnersName]
	       FROM [Animals] AS a
	  LEFT JOIN [Owners] AS o
	       ON a.[OwnerId] = o.[Id]
	    WHERE a.[Name] = @animalName
END

GO
EXEC usp_AnimalsWithOwnersOrNot 'Brown bear' 