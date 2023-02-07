CREATE DATABASE [NationalTouristSitesOfBulgaria]
GO
USE [NationalTouristSitesOfBulgaria]
GO

-- 01. DDL

CREATE TABLE [Categories]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [Locations]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[Municipality] VARCHAR(50),
	[Province] VARCHAR(50)
)

CREATE TABLE [Sites]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	[LocationId] INT FOREIGN KEY REFERENCES [Locations](Id) NOT NULL,
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories](Id) NOT NULL,
	[Establishment] VARCHAR(15)
)

CREATE TABLE [Tourists]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[Age] INT NOT NULL
	CHECK([Age] BETWEEN 0 AND 120),
	[PhoneNumber] VARCHAR(20) NOT NULL,
	[Nationality] VARCHAR(30) NOT NULL,
	[Reward] VARCHAR(20)
)

CREATE TABLE [SitesTourists]
(
	[TouristId] INT FOREIGN KEY REFERENCES [Tourists](Id) NOT NULL,
	[SiteId] INT FOREIGN KEY REFERENCES [Sites](Id) NOT NULL,
	PRIMARY KEY ([TouristId], [SiteId])
)

CREATE TABLE [BonusPrizes]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [TouristsBonusPrizes]
(
	[TouristId] INT FOREIGN KEY REFERENCES [Tourists](Id) NOT NULL,
	[BonusPrizeId] INT FOREIGN KEY REFERENCES [BonusPrizes](Id) NOT NULL,
	PRIMARY KEY([TouristId], [BonusPrizeId])
)

-- 02. Insert

INSERT INTO Tourists VALUES
    ('Borislava Kazakova',	52,	'+359896354244',	'Bulgaria',	NULL),
    ('Peter Bosh',	48,	'+447911844141',	'UK',	NULL),
    ('Martin Smith',	29,	'+353863818592',	'Ireland',	'Bronze badge'),
    ('Svilen Dobrev',	49,	'+359986584786',	'Bulgaria',	'Silver badge'),
    ('Kremena Popova',	38,	'+359893298604',	'Bulgaria',	NULL)

INSERT INTO Sites VALUES
    ('Ustra fortress',	90,	7,	'X'),
    ('Karlanovo Pyramids',	65,	7,	NULL),
    ('The Tomb of Tsar Sevt',	63,	8,	'V BC'),
    ('Sinite Kamani Natural Park',	17,	1,	NULL),
    ('St. Petka of Bulgaria – Rupite',	92,	6,	'1994')

-- 03. Update

UPDATE [Sites]
SET [Establishment] = '(not defined)'
WHERE [Establishment] IS NULL

-- 04. Delete

SELECT [Id] FROM [BonusPrizes]
WHERE [Name] = 'Sleeping bag'

DELETE [TouristsBonusPrizes]
WHERE [BonusPrizeId]  =
                       (
						SELECT [Id] FROM [BonusPrizes]
						WHERE [Name] = 'Sleeping bag'
                       )

DELETE [BonusPrizes]
WHERE [Name] = 'Sleeping bag'

-- FRESH DATABASE

-- 05. Tourists

  SELECT [Name],
         [Age],
         [PhoneNumber],
         [Nationality]
    FROM [Tourists]
ORDER BY [Nationality] ASC,
		 [Age] DESC,
		 [Name] ASC

-- 06. Sites with Their Location and Category

SELECT s.[Name],
       l.[Name] AS [Location],
       s.[Establishment],
       c.[Name] AS [Category]
    FROM [Sites] AS s
    JOIN [Locations] AS l
    ON s.[LocationId] = l.[Id]
    JOIN [Categories] AS c
    ON s.[CategoryId] = c.[Id]
ORDER BY [Category] DESC,
		 [Location] ASC,
	   s.[Name] ASC


-- 07. Count of Sites in Sofia Province

   SELECT l.[Province],
    	  l.[Municipality],
    	  l.[Name] AS [Location],
COUNT(*) AS [CountOfSites]
       FROM [Sites] AS s
       JOIN [Locations] AS l
       ON s.[LocationId] = l.[Id]
    WHERE l.[Province] = 'Sofia'
 GROUP BY l.[Province], l.[Municipality],  l.[Name]
   ORDER BY [CountOfSites] DESC,
		  l.[Name] ASC

-- 08. Tourist Sites established BC

    SELECT s.[Name] AS [Site],
           l.[Name] AS [Location],
           l.[Municipality],
           l.[Province],
           s.[Establishment]
        FROM [Sites] AS s
        JOIN [Locations] AS l
        ON s.[LocationId] = l.[Id]
WHERE LEFT(l.[Name], 1) NOT IN('B', 'M', 'D') AND
	       s.[Establishment] LIKE ('%BC%')
    ORDER BY [Site] ASC

-- 09. Tourists with their Bonus Prizes

 SELECT t.[Name],
        t.[Age],
        t.[PhoneNumber],
        t.[Nationality],
    CASE 
    WHEN b.[Name] IS NULL THEN '(no bonus prize)'
    ELSE b.[Name]
    END AS [Reward]
      FROM [Tourists] AS t
 LEFT JOIN [TouristsBonusPrizes] AS tb
     ON tb.[TouristId] = t.[Id]
 LEFT JOIN [BonusPrizes] AS b
     ON tb.[BonusPrizeId] = b.[Id]
ORDER BY t.[Name] ASC

-- 10. Tourists visiting History & Archaeology sites

SELECT DISTINCT
SUBSTRING(t.[Name], CHARINDEX(' ', t.[Name]) + 1, LEN(t.[Name])) AS [LastName],
          t.[Nationality],
          t.[Age],
          t.[PhoneNumber]
       FROM [Tourists] AS t
       JOIN [SitesTourists] AS st
	  ON st.[TouristId] = t.[Id]
	   JOIN [Sites] AS s
      ON st.[SiteId] = s.[Id]
       JOIN [Categories] AS c
       ON s.[CategoryId] = c.[Id]
    WHERE c.[Name] = 'History and archaeology'
   ORDER BY [LastName] ASC

-- 11. Tourists Count on a Tourist Site
GO

CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@site VARCHAR(100))
RETURNS INT
BEGIN
	DECLARE @siteId INT
	SET @siteId = (SELECT [Id] FROM [Sites] WHERE [Name] = @site)
	DECLARE @touristCount INT
	SET @touristCount = (SELECT COUNT(*) FROM [SitesTourists] WHERE [SiteId] = @siteId)
	RETURN @touristCount
END

GO

-- 12. Annual Reward Lottery

CREATE OR ALTER PROC usp_AnnualRewardLottery(@touristName VARCHAR(50))
AS
BEGIN
DECLARE @sitesNum INT
SET @sitesNum =
(
		SELECT COUNT(*) FROM [SitesTourists]
	    WHERE [TouristId] =
	(
		SELECT [Id] FROM [Tourists]
		WHERE [Name] = @touristName
	)
)
DECLARE @reward VARCHAR(30) = NULL
IF (@sitesNum >= 100) SET @reward = 'Gold badge'
    ELSE IF (@sitesNum >= 50 ) SET @reward = 'Silver badge'
        ELSE IF (@sitesNum >= 25) SET @reward = 'Bronze badge'

IF(@reward IS NOT NULL)
	UPDATE [Tourists]
	SET [Reward] = @reward

SELECT [Name], [Reward] FROM Tourists WHERE [Name] = @touristName
END

GO

EXEC usp_AnnualRewardLottery 'Zac Walsh' 