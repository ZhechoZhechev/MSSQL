-- 01. DDL
CREATE DATABASE [CigarShop]
GO

USE [CigarShop]
GO

CREATE TABLE [Sizes]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Length] INT NOT NULL
	CHECK ([Length] BETWEEN 10 AND 25),
	[RingRange] DECIMAL(2, 1) NOT NULL
	CHECK ([RingRange] BETWEEN 1.5 AND 7.5)
)

CREATE TABLE [Tastes] 
(
	[Id] INT PRIMARY KEY IDENTITY,
	[TasteType] VARCHAR(20) NOT NULL,
	[TasteStrength] VARCHAR(15) NOT NULL,
	[ImageURL] NVARCHAR(100) NOT NULL
)

CREATE TABLE [Brands] 
(
	[Id] INT PRIMARY KEY IDENTITY,
	[BrandName] VARCHAR(30) UNIQUE NOT NULL,
	[BrandDescription] VARCHAR(MAX)
)

CREATE TABLE [Cigars]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[CigarName] VARCHAR(80) NOT NULL,
	[BrandId] INT FOREIGN KEY REFERENCES [Brands](Id),
	[TastId] INT FOREIGN KEY REFERENCES [Tastes](Id),
	[SizeId] INT FOREIGN KEY REFERENCES [Sizes](Id),
	[PriceForSingleCigar] MONEY NOT NULL,
	[ImageURL] NVARCHAR(100) NOT NULL
)

CREATE TABLE [Addresses]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Town] VARCHAR(30) NOT NULL,
	[Country] NVARCHAR(30) NOT NULL,
	[Streat] NVARCHAR(100) NOT NULL,
	[ZIP] VARCHAR(20) NOT NULL
)

CREATE TABLE [Clients]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(30) NOT NULL,
	[LastName] NVARCHAR(30) NOT NULL,
	[Email] NVARCHAR(50) NOT NULL,
	[AddressId] INT FOREIGN KEY REFERENCES [Addresses](Id)
)

CREATE TABLE [ClientsCigars]
(
	[ClientId] INT FOREIGN KEY REFERENCES [Clients](Id),
	[CigarId] INT FOREIGN KEY REFERENCES [Cigars](Id),
	PRIMARY KEY ([ClientId], [CigarId])
)

-- 02. Insert

INSERT INTO [Cigars]
VALUES
	('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg'),
	('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg'),
	('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50, 'hoyo-du-maire-stick_17.jpg'),
	('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00, 'hoyo-de-san-juan-stick_20.jpg'),
	('TRINIDAD COLONIALES', 2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg')

INSERT INTO [Addresses] 
VALUES
    ('Sofia',	'Bulgaria',	'18 Bul. Vasil levski',	1000),
    ('Athens',	'Greece',	'4342 McDonald Avenue',	10435),
    ('Zagreb',	'Croatia',	'4333 Lauren Drive',	10000)

-- 03. Update

SELECT [Id] FROM [Tastes]
WHERE [TasteType] = 'Spicy'

UPDATE [Cigars]
SET [PriceForSingleCigar] *= 1.2
WHERE [TastId] = 
(
	SELECT [Id] FROM [Tastes]
	WHERE [TasteType] = 'Spicy'
)

UPDATE [Brands]
SET [BrandDescription] = 'New description'
WHERE [BrandDescription] IS NULL

-- 04. Delete

SELECT [Id] FROM [Addresses]
WHERE [Country] LIKE ('c' + '%')

DELETE [Clients]
WHERE [AddressId] IN 
(
	SELECT [Id] FROM [Addresses]
	WHERE [Country] LIKE ('c' + '%')
)

DELETE [Addresses]
 WHERE [Country] LIKE ('c' + '%')

-- NEW DATASET

-- 05. Cigars by Price

  SELECT [CigarName],
         [PriceForSingleCigar],
         [ImageURL]
    FROM [Cigars]
ORDER BY [PriceForSingleCigar],
		 [CigarName] DESC

-- 06. Cigars by Taste

   SElECT c.[Id],
          c.[CigarName],
          c.[PriceForSingleCigar],
          t.[TasteType],
          t.[TasteStrength]
       FROM [Cigars] AS c
       JOIN [Tastes] AS t
       ON c.[TastId] = t.[Id]
    WHERE t.[TasteType] IN ('Earthy', 'Woody')
 ORDER BY c.[PriceForSingleCigar] DESC

-- 07. Clients without Cigars

 SELECT c.[Id],
 CONCAT(c.[FirstName], ' ', c.[LastName]) AS [ClientName],
        c.[Email]
     FROM [Clients] AS c
LEFT JOIN [ClientsCigars] AS cc
    ON cc.[ClientId] = c.[Id]
    WHERE [CigarId] IS NULL
 ORDER BY [ClientName]

-- 08. First 5 Cigars

SELECT TOP(5) c.[CigarName],
              c.[PriceForSingleCigar],
			  c.[ImageURL] 
		   FROM [Cigars] as c
		   JOIN [Sizes] as s
		   ON c.[SizeId] = s.[Id]
        WHERE s.[Length] >= 12 AND
	         (c.[CigarName] LIKE '%ci%' OR c.PriceForSingleCigar > 50) AND
	          s.[RingRange] > 2.55
     ORDER BY c.[CigarName],
		      c.[PriceForSingleCigar] DESC

-- 09. Clients with ZIP Codes

SELECT [FullName], [Country], [ZIP], [CigarPrice]  FROM 
(
	SELECT CONCAT(c.[FirstName], ' ', c.[LastName]) AS [FullName],
				  a.[Country],
	              a.[ZIP],
	CONCAT('$', cig.[PriceForSingleCigar]) AS [CigarPrice],
	DENSE_RANK() OVER(PARTITION BY a.[ZIP] ORDER BY cig.[PriceForSingleCigar] DESC) AS [Ranks]
	           FROM [Clients] AS c
	      LEFT JOIN [Addresses] AS a
	           ON c.[AddressId] = a.[Id]
	      LEFT JOIN [ClientsCigars] AS cc
	          ON cc.[ClientId] = c.[Id]
	      LEFT JOIN [Cigars] AS cig
	          ON cc.[CigarId] = cig.[Id]
	        WHERE a.[ZIP] NOT LIKE '%[^0-9]%'
)
      AS [Subq]
   WHERE [Ranks] = 1
ORDER BY [FullName]

SELECT 
    c.FirstName + ' ' + c.LastName AS FullName,
    a.Country,
    a.ZIP,
    '$' + CAST(MAX(ci.PriceForSingleCigar) AS VARCHAR) AS CigarPrice
FROM Clients AS c
JOIN Addresses AS a ON c.AddressId = a.Id
JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
JOIN Cigars AS ci ON cc.CigarId = ci.Id
WHERE a.ZIP NOT LIKE '%[A-Z]%'
GROUP BY c.FirstName, c.LastName, a.Country, a.ZIP
ORDER BY FullName ASC

-- 10. Cigars by Size

     SELECT c.[LastName],
        AVG(s.[Length]) AS [CiagrLength],
CEILING(AVG(s.[RingRange])) AS [CiagrRingRange]
         FROM [Clients] AS c
         JOIN [ClientsCigars] AS cc
        ON cc.[ClientId] = c.[Id]
         JOIN [Cigars] AS cig
        ON cc.[CigarId] = cig.[Id]
         JOIN [Sizes] AS s
       ON cig.[SizeId] = s.[Id]
   GROUP BY c.[LastName]
     ORDER BY [CiagrLength] DESC

-- 11. Client with Cigars
GO

CREATE FUNCTION udf_ClientWithCigars(@name NVARCHAR(30))
RETURNS INT
BEGIN
	DECLARE @clientId INT
	SET @clientId = (SELECT [Id] FROM [Clients] WHERE [FirstName] = @name)
	DECLARE @count INT
	SET @count = (SELECT COUNT(*) FROM [ClientsCigars] WHERE [ClientId] = @clientId)
	RETURN @count
END

GO

-- 12. Search for Cigar with Specific Taste

CREATE PROC usp_SearchByTaste(@taste VARCHAR(20))
AS
BEGIN
	
	     SELECT c.[CigarName],
	CONCAT('$', c.[PriceForSingleCigar]) AS [Price],
	            t.[TasteType],
	            b.[BrandName],
		 CONCAT(s.[Length], ' ', 'cm') AS [CigarLength],
		 CONCAT(s.[RingRange], ' ', 'cm') AS [CigarRingRange]
		     FROM [Cigars] AS c
		     JOIN [Tastes] AS t
		     ON c.[TastId] = t.[Id]
		     JOIN [Brands] AS b
		     ON c.[BrandId] = b.[Id]
		     JOIN [Sizes] AS s
		     ON c.[SizeId] = s.[Id]
	      WHERE t.[TasteType] = @taste
	     ORDER BY [CigarLength],
	     		  [CigarRingRange] DESC

END

GO
EXEC usp_SearchByTaste 'Woody' 