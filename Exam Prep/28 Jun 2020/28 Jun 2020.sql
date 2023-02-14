CREATE DATABASE [ColonialJourney]
GO
USE [ColonialJourney]
GO

-- 01. DDL

CREATE TABLE [Planets]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE [Spaceports]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PlanetId] INT FOREIGN KEY REFERENCES [Planets](Id) NOT NULL 
)

CREATE TABLE [Spaceships]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[Manufacturer] VARCHAR(30) NOT NULL,
	[LightSpeedRate] INT DEFAULT(0) NOT NULL
)

CREATE TABLE [Colonists]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(20) NOT NULL,
	[LastName] VARCHAR(20) NOT NULL,
	[Ucn] VARCHAR(10) UNIQUE NOT NULL,
	[BirthDate] DATE NOT NULL
)

CREATE TABLE [Journeys]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[JourneyStart] DATETIME NOT NULL,
	[JourneyEnd] DATETIME NOT NULL,
	[Purpose] VARCHAR(11) 
	CHECK([Purpose] IN ('Medical', 'Technical', 'Educational', 'Military')),
	[DestinationSpaceportId] INT FOREIGN KEY REFERENCES [Spaceports](Id) NOT NULL,
	[SpaceshipId] INT FOREIGN KEY REFERENCES [Spaceships](Id) NOT NULL
)

CREATE TABLE [TravelCards]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[CardNumber] CHAR(10) UNIQUE NOT NULL,
	[JobDuringJourney] VARCHAR(8)
	CHECK([JobDuringJourney] IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	[ColonistId] INT FOREIGN KEY REFERENCES [Colonists](Id) NOT NULL,
	[JourneyId] INT FOREIGN KEY REFERENCES [Journeys](Id) NOT NULL
)

-- 02. Insert

INSERT INTO Planets VALUES
    ('Mars'),
    ('Earth'),
    ('Jupiter'),
    ('Saturn')

INSERT INTO Spaceships VALUES
    ('Golf',	'VW',	3),
    ('WakaWaka',	'Wakanda',	4),
    ('Falcon9',	'SpaceX',	1),
    ('Bed',	'Vidolov',	6)

-- 03. Update

UPDATE [Spaceships]
SET [LightSpeedRate] += 1
WHERE [Id] BETWEEN 8 AND 12 

-- 04. Delete

DELETE [TravelCards]
WHERE [JourneyId] IN (1, 2, 3)

DELETE [Journeys]
WHERE [Id] IN (1, 2, 3)

-- FRESH DATASET

-- 05. Select All Military Journeys

SELECT
		 [Id],
  FORMAT([JourneyStart], 'dd/MM/yyyy') AS [JourneyStart],
  FORMAT([JourneyEnd], 'dd/MM/yyyy') AS [JourneyEnd]
    FROM [Journeys]
   WHERE [Purpose] = 'Military'
ORDER BY [JourneyStart] ASC

-- 06. Select All Pilots

SELECT
  	     c.[Id],
  CONCAT(c.[FirstName], ' ', c.[LastName]) AS [full_name]
      FROM [Colonists] AS c
  	JOIN [TravelCards] AS tc
     ON tc.[ColonistId] = c.[Id]
  WHERE tc.[JobDuringJourney] = 'pilot'
ORDER BY c.[Id] ASC

-- 07. Count Colonists

  SELECT 
  COUNT(*) AS [Count]
  FROM TravelCards
  WHERE [JobDuringJourney] = 'Engineer'

-- 08. Select Spaceships With Pilots

        SELECT s.[Name],
        	   s.[Manufacturer] 
            FROM [Colonists] AS c
            JOIN [TravelCards] AS tc ON tc.[ColonistId] = c.[Id]
            JOIN [Journeys] AS j ON tc.[JourneyId] = j.[Id]
            JOIN [Spaceships] AS s ON j.[SpaceshipId] = s.[Id]
        WHERE tc.[JobDuringJourney] = 'pilot' AND
DATEDIFF(YEAR, c.[BirthDate], '01/01/2019' ) < 30
	  ORDER BY s.[Name]

-- 09. Planets And Journeys

SELECT
         p.[Name] AS [PlanetName],
      COUNT(*) AS [JourneysCount]
      FROM [Journeys] AS j
      JOIN [Spaceports] AS sp ON j.[DestinationSpaceportId] = sp.[Id]
      JOIN [Planets] AS p ON sp.[PlanetId] = p.[Id]
GROUP BY p.[Name]
  ORDER BY [JourneysCount] DESC,
  		   [PlanetName] ASC

-- 10. Select Special Colonists
SELECT
      [JobDuringJourney],
      [FullName],
      [JobRank]
FROM 
			(
				SELECT
				tc.[JobDuringJourney],
				CONCAT(c.[FirstName], ' ', c.[LastName]) AS [FullName],
				RANK() OVER(PARTITION BY tc.[JobDuringJourney] ORDER BY c.[BirthDate] ASC) AS [JobRank]
				FROM [Colonists] AS c
				JOIN [TravelCards] AS tc ON tc.[ColonistId] = c.[Id]
			)AS [SubQ]
WHERE [JobRank] = 2

-- 11. Get Colonists Count
GO
CREATE FUNCTION udf_GetColonistsCount(@planetName VARCHAR (30))
RETURNS INT
BEGIN
	DECLARE @planetId INT = (SELECT [Id] FROM [Planets] WHERE [Name] = @planetName)
	DECLARE @count INT = 
	(
		SELECT
		COUNT(*)
		FROM [Colonists] AS c
		JOIN [TravelCards] AS tc ON tc.[ColonistId] = c.[Id]
		JOIN [Journeys] AS j ON tc.[JourneyId] = j.[Id]
		JOIN [Spaceports] AS sp ON j.[DestinationSpaceportId] = sp.[Id]
		JOIN [Planets] AS p ON sp.[PlanetId] = p.[Id]
		WHERE p.[Id] = @planetId
	)
RETURN @count
END

GO
--SELECT dbo.udf_GetColonistsCount('Otroyphus')

CREATE PROC usp_ChangeJourneyPurpose(@journeyId INT , @newPurpose VARCHAR(11))
AS
BEGIN
	IF(@journeyId NOT IN (SELECT [Id] FROM [Journeys]))
		THROW 50001, 'The journey does not exist!', 1

	IF(@newPurpose = (SELECT [Purpose] FROM [Journeys] WHERE [Id] = @journeyId))
		THROW 50002, 'You cannot change the purpose!', 1

	UPDATE [Journeys]
	   SET [Purpose] = @newPurpose
	 WHERE [Id] = @journeyId
END

GO

EXEC usp_ChangeJourneyPurpose 2, 'Educational' 
EXEC usp_ChangeJourneyPurpose 196, 'Technical' 
EXEC usp_ChangeJourneyPurpose 4, 'Technical' 
