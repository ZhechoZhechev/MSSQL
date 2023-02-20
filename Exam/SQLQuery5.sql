CREATE DATABASE [Boardgames]
GO
USE [Boardgames]
GO

CREATE TABLE [Categories]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [Addresses]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[StreetName] NVARCHAR(100) NOT NULL,
	[StreetNumber] INT NOT NULL,
	[Town] VARCHAR(30) NOT NULL,
	[Country] VARCHAR(50) NOT NULL,
	[ZIP] INT NOT NULL
)

CREATE TABLE [Publishers]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) UNIQUE NOT NULL,
	[AddressId] INT FOREIGN KEY REFERENCES [Addresses](Id) NOT NULL,
	[Website] NVARCHAR(40),
	[Phone] NVARCHAR(20)
)

CREATE TABLE [PlayersRanges]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[PlayersMin] INT NOT NULL,
	[PlayersMax] INT NOT NULL
)

CREATE TABLE [Boardgames]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	[YearPublished] INT NOT NULL,
	[Rating] DECIMAL(18, 2) NOT NULL,
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories](Id) NOT NULL,
	[PublisherId] INT FOREIGN KEY REFERENCES [Publishers](Id) NOT NULL,
	[PlayersRangeId] INT FOREIGN KEY REFERENCES [PlayersRanges](Id) NOT NULL
)

CREATE TABLE [Creators]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(30) NOT NULL,
	[LastName] NVARCHAR(30) NOT NULL,
	[Email] NVARCHAR(30) NOT NULL
)

CREATE TABLE [CreatorsBoardgames]
(
	[CreatorId] INT FOREIGN KEY REFERENCES [Creators](Id) NOT NULL,
	[BoardgameId] INT FOREIGN KEY REFERENCES [Boardgames](Id) NOT NULL
	PRIMARY KEY([CreatorId],[BoardgameId])
)

--2 Insert
INSERT INTO [Boardgames] VALUES
('Deep Blue', 2019,	5.67, 1, 15, 7),
('Paris', 2016, 9.78, 7, 1, 5),
('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
('Bleeding Kansas', 2020, 3.25, 3, 7, 4),
('One Small Step', 2019, 5.75, 5, 9, 2)

INSERT INTO [Publishers] VALUES
('Agman Games',	5, 'www.agmangames.com', '+16546135542'),
('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
('BattleBooks',	13,	'www.battlebooks.com', '+12345678907')

--3 Update

UPDATE [PlayersRanges]
SET [PlayersMax] += 1
WHERE [PlayersMin] = 2 AND [PlayersMax] = 2

UPDATE [Boardgames] 
SET [Name] = CONCAT([Name], 'V2')
WHERE [YearPublished] >= 2020

--4 DELETE

SELECT [Id] FROM [Addresses]
WHERE LEFT([Town], 1) = 'L'

SELECT id from [Publishers]
WHERE [AddressId] = 5

SELECT ID from [Boardgames]
WHERE [PublisherId] = 1

DELETE FROM CreatorsBoardgames
WHERE [BoardgameId] IN (1, 16, 31)

DELETE [Boardgames]
WHERE [PublisherId] = 1

DELETE FROM [Publishers]
WHERE [AddressId] = 
(
	SELECT [Id] FROM [Addresses]
    WHERE LEFT([Town], 1) = 'L'
)

DELETE FROM [Addresses]
WHERE LEFT([Town], 1) = 'L'

--5

  SELECT [Name], [Rating] FROM [Boardgames]
ORDER BY [YearPublished] ASC, 
		 [Name] DESC

--6

SELECT b.[Id], b.[Name], b.[YearPublished], c.[Name] AS [CategoryName] 
FROM [Boardgames] AS b
JOIN [Categories] AS c ON b.[CategoryId] = c.[Id]
WHERE c.[Name] IN ('Strategy Games', 'Wargames')
ORDER BY b.[YearPublished] DESC

--7

SELECT c.[Id], CONCAT(c.[FirstName], ' ', c.[LastName]) AS [CreatorName], c.[Email]  
FROM [Creators] AS c
LEFT JOIN [CreatorsBoardgames] AS cb ON cb.[CreatorId] = c.[Id]
WHERE cb.[BoardgameId] IS NULL
ORDER BY [CreatorName] ASC

--8

SELECT TOP(5) b.[Name], b.[Rating], c.[Name] FROM [Boardgames] AS b
JOIN [PlayersRanges] AS pr ON b.[PlayersRangeId] = pr.[Id]
JOIN [Categories] AS c ON b.[CategoryId] = c.[Id]
WHERE (b.[Rating] > 7.00 AND b.[Name] LIKE '%a%') OR
	  (b.[Rating] > 7.50? AND pr.[PlayersMin] = 2 AND pr.[PlayersMax] = 5)
ORDER BY b.[Name] ASC,
		b.[Rating] DESC


--9

SELECT
CONCAT(c.[FirstName], ' ', c.[LastName]) AS [FullName] ,
c.[Email],
MAX(b.[Rating]) AS [Rating]
FROM [Creators] AS c
JOIN [CreatorsBoardgames] AS cb ON cb.[CreatorId] = c.[Id]
JOIN [Boardgames] AS b ON cb.[BoardgameId] = b.[Id]
WHERE RIGHT(c.[Email], 4) LIKE '.com'
GROUP BY c.[Id], c.[FirstName], c.[LastName], c.[Email]
ORDER BY [FullName] ASC

--10
SELECT
[LastName],
CEILING([AverageRating]),
[Name]
 FROM 
(
	SELECT
c.[LastName],
AVG(b.[Rating]) AS [AverageRating],
p.[Name]
FROM [Creators] AS c
JOIN [CreatorsBoardgames] AS cb ON cb.[CreatorId] = c.[Id]
JOIN [Boardgames] AS b ON cb.[BoardgameId] = b.[Id]
JOIN [Publishers] AS p ON b.[PublisherId] = p.[Id]
WHERE p.[Name] = 'Stonemaier Games'
GROUP BY c.[LastName], p.[Name]
--ORDER BY [AverageRating] DESC
)AS [Subq]
ORDER BY [AverageRating] DESC

--11
GO
CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR(30))
RETURNS INT
BEGIN
	DECLARE @creatorId INT
	SET @creatorId = (SELECT [Id] FROM [Creators] WHERE [FirstName] = @name)
	DECLARE @count INT
	SET @count = 
	(
		SELECT COUNT(*) FROM [CreatorsBoardgames] WHERE [CreatorId] = @creatorId 
	)
	RETURN @count
END
GO
SELECT dbo.udf_CreatorWithBoardgames('Bruno')

-- 12 
GO
CREATE PROC usp_SearchByCategory(@category VARCHAR(50))
AS
BEGIN

	SELECT b.[Name], b.[YearPublished], b.[Rating], c.[Name] AS [CategoryName], p.[Name] AS [PublisherName],
	CONCAT(pr.[PlayersMin], ' ', 'people') AS [MinPlayers],
	CONCAT(pr.[PlayersMax], ' ', 'people') AS [PlayersMax]
	FROM [Boardgames] AS b
	JOIN [Publishers] AS p ON b.[PublisherId] = p.[Id]
	JOIN [PlayersRanges] AS pr ON b.[PlayersRangeId] = pr.[Id]
	JOIN [Categories] AS c ON b.[CategoryId] = c.[Id]
	WHERE c.[Name] = @category
	ORDER BY p.[Name] ASC,
			b.[YearPublished] DESC
END
GO
EXEC usp_SearchByCategory 'Wargames' 