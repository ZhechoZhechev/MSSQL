CREATE DATABASE [TripService]
GO
USE [TripService]
GO

-- 01. DDL

CREATE TABLE [Cities]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	[CountryCode] CHAR(2) NOT NULL
)

CREATE TABLE [Hotels]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	[CityId] INT FOREIGN KEY REFERENCES [Cities](Id) NOT NULL,
	[EmployeeCount] INT NOT NULL,
	[BaseRate] DECIMAL(18, 2)
)

CREATE TABLE [Rooms]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Price] DECIMAL(18, 2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	[Beds] INT NOT NULL,
	[HotelId] INT FOREIGN KEY REFERENCES [Hotels](Id) NOT NULL,
)

CREATE TABLE [Trips]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[RoomId] INT FOREIGN KEY REFERENCES [Rooms](Id) NOT NULL,
	[BookDate] DATE NOT NULL,
	[ArrivalDate] DATE NOT NULL,
	[ReturnDate] DATE NOT NULL,
	[CancelDate] DATE,
	CHECK([BookDate] < [ArrivalDate]),
	CHECK([ArrivalDate] < [ReturnDate]) 
)

CREATE TABLE [Accounts]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(50) NOT NULL,
	[MiddleName] NVARCHAR(20),
	[LastName] NVARCHAR(50) NOT NULL,
	[CityId] INT FOREIGN KEY REFERENCES [Cities](Id) NOT NULL,
	[BirthDate] DATE NOT NULL,
	[Email] VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE [AccountsTrips]
(
	[AccountId] INT FOREIGN KEY REFERENCES [Accounts](Id) NOT NULL,
	[TripId] INT FOREIGN KEY REFERENCES [Trips](Id) NOT NULL,
	[Luggage] INT CHECK([Luggage] >= 0) NOT NULL
	PRIMARY KEY ([AccountId], [TripId])
)

-- 02. Insert

INSERT INTO Accounts VALUES
    ('John',	    'Smith',	'Smith',	34,	'1975-07-21', 'j_smith@gmail.com'),
    ('Gosho',	    NULL,	    'Petrov',	11,	'1978-05-16', 'g_petrov@gmail.com'),
    ('Ivan',	    'Petrovich','Pavlov',	59,	'1849-09-26', 'i_pavlov@softuni.bg'),
    ('Friedrich',	'Wilhelm',	'Nietzsche', 2,	'1844-10-15', 'f_nietzsche@softuni.bg')


INSERT INTO Trips VALUES
    (101,	'2015-04-12',	'2015-04-14',	'2015-04-20',	'2015-02-02'),
    (102,	'2015-07-07',   '2015-07-15',	'2015-07-22',	'2015-04-29'),
    (103,	'2013-07-17',	'2013-07-23',	'2013-07-24',	NULL),
    (104,	'2012-03-17',	'2012-03-31',	'2012-04-01',	'2012-01-10'),
    (109,	'2017-08-07',	'2017-08-28',	'2017-08-29',	NULL)

-- 03. Update

UPDATE [Rooms]
SET [Price] *= 1.14
WHERE [HotelId] IN (5,7,9)

-- 04. Delete

DELETE FROM [AccountsTrips]
WHERE [AccountId] = 47

-- FRESH DATASET

-- 05. EEE-Mails

SELECT
       a.[FirstName],
       a.[LastName],
  FORMAT([BirthDate], 'MM-dd-yyyy') AS [BirthDate],
       c.[Name] AS [Hometown],
       a.[Email]
    FROM [Accounts] AS a
    JOIN [Cities] AS c
    ON a.[CityId] = c.[Id]
   WHERE [Email] LIKE 'e%'
ORDER BY [Hometown] ASC

-- 06. City Statistics

SELECT
         c.[Name],
   COUNT(c.[Id]) AS [Hotels]
      FROM [Cities] AS c
      JOIN [Hotels] AS h
      ON h.[CityId] = c.[Id]
GROUP BY c.[Name]
  ORDER BY [Hotels] DESC,
  	     c.[Name] ASC

-- 07. Longest and Shortest Trips

SELECT
                  a.[Id],
           CONCAT(a.[FirstName], ' ', a.[LastName]) AS [FullName],
MAX(DATEDIFF(DAY, t.[ArrivalDate], t.[ReturnDate])) AS [LongestTrip],
MIN(DATEDIFF(DAY, t.[ArrivalDate], t.[ReturnDate])) AS [ShortestTrip]
               FROM [Accounts] AS a
               JOIN [AccountsTrips] AS ac
			  ON ac.[AccountId] = a.[Id]
			   JOIN [Trips] AS t
              ON ac.[TripId] = t.[Id]
            WHERE a.[MiddleName] IS NULL AND
	              t.[CancelDate] IS NULL
         GROUP BY a.[Id], a.[FirstName], a.[LastName]
		   ORDER BY [LongestTrip] DESC,
			        [ShortestTrip] ASC

-- 08. Metropolis 

SELECT TOP(10)
         c.[Id],
         c.[Name] AS [City],
         c.[CountryCode] AS [Country],
   COUNT(a.[Id]) AS [Accounts]
      FROM [Cities] c
      JOIN [Accounts] AS a
      ON a.[CityId] = c.[Id]
GROUP BY c.[Id], c.[Name], c.[CountryCode]
  ORDER BY [Accounts] DESC

-- 09. Romantic Getaways

SELECT 
      a.[Id],
      a.[Email],
      c.[Name] AS [City],
COUNT(c.[Id]) AS [Trips]
   FROM [Accounts] AS a
   JOIN [AccountsTrips] AS [at] 
   ON a.[Id] = [at].[AccountId]
   JOIN [Trips] AS t 
     ON [at].[TripId] = t.[Id]
   JOIN [Rooms] AS r 
   ON t.[RoomId] = r.[Id]
   JOIN [Hotels] AS h 
   ON r.[HotelId] = h.[Id]
   JOIN [Cities] AS c 
   ON h.[CityId] = c.[Id]
WHERE a.[CityId] = h.[CityId]
GROUP BY a.[Id], a.[Email], c.[Name]
  ORDER BY [Trips] DESC,
		 a.[Id] ASC

-- 10. GDPR Violation

SELECT
	   t.[Id],
CONCAT(a.[FirstName], ' ', a.[MiddleName], ' ', a.[LastName]) AS [Full Name],
      ci.[Name] AS [From],
       c.[Name] AS [To],
CASE WHEN
t.[CancelDate] IS NULL THEN CONCAT(DATEDIFF(DAY, t.[ArrivalDate], t.[ReturnDate]), ' ', 'days')
     ELSE 'Canceled'
  END AS [Duration]
    FROM [Trips] AS t
    JOIN [AccountsTrips] AS [at]
      ON [at].[TripId] = t.[Id]
    JOIN [Accounts] AS a 
	  ON [at].[AccountId] = a.[Id]
    JOIN [Rooms] AS r
    ON t.[RoomId] = r.[Id]
    JOIN [Hotels] AS h
    ON r.[HotelId] = h.[Id]
    JOIN [Cities] AS c
    ON h.[CityId] = c.[Id]
    JOIN [Cities] AS ci
    ON a.[CityId] = ci.[Id]
ORDER BY [Full Name],
	   t.[Id]

SELECT
    t.Id,
    CONCAT(a.FirstName + ' ', a.MiddleName + ' ', a.LastName) AS FullName,
    c.Name AS [From],
    ci.Name AS [To],
    CASE
        WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
        ELSE CAST(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate) AS VARCHAR) + ' days'
    END AS Duration
FROM Trips AS t
JOIN AccountsTrips AS at ON t.Id = at.TripId
JOIN Accounts AS a ON at.AccountId = a.Id
JOIN Cities AS c ON a.CityId = c.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS ci ON h.CityId = ci.Id
ORDER BY FullName, t.Id

-- 11. Available Room

GO

CREATE OR ALTER FUNCTION udf_GetAvailableRoom(@hotelId INT , @date DATE, @people INT)
RETURNS NVARCHAR(200)
BEGIN


	 DECLARE @roomNum INT
	 SET @roomNum =
	 ( 
	 		SELECT TOP(1) r.[Id]
		    FROM [Trips] AS t
		    JOIN [Rooms] AS r ON t.[RoomId] = r.[Id]
		    JOIN [Hotels] AS h ON r.[HotelId] = h.[Id]
		    WHERE t.[CancelDate] IS NULL AND
		    @date NOT BETWEEN t.[ArrivalDate] AND t.[ReturnDate] AND
			YEAR(@Date) = YEAR(t.ArrivalDate) AND
		    h.[Id] = @hotelId AND
		    r.[Beds] >= @people
		    ORDER BY r.[Price] DESC

	 )
	 	 IF(@roomNum IS NULL)
		RETURN 'No rooms available'

	 DECLARE @roomType NVARCHAR(20) 
	 SET @roomType = (SELECT [Type] FROM [Rooms] WHERE [Id] = @roomNum)

	 DECLARE @bedsNum INT 
	 SET @bedsNum = (SELECT [Beds] FROM [Rooms] WHERE [Id] = @roomNum)

	 DECLARE @roomPrice DECIMAL(18,2)= (SELECT Price
        FROM Rooms
        WHERE Id=@roomNum)
     DECLARE @hotelBaseRate DECIMAL(5,2)= (SELECT BaseRate
        FROM Hotels
        WHERE Id=@HotelId)

    DECLARE @TOTALPRICE DECIMAL(18,2)= (@hotelBaseRate + @roomPrice) * @people

     RETURN  'Room ' + CAST(@roomNum AS varchar) + ': ' + @roomType + ' (' + CAST(@bedsNum AS varchar) + ' beds) - $' + CAST(@TOTALPRICE AS varchar)
END

GO

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)

SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3) 

-- 12. Switch Room
GO

CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
	DECLARE @tripHotelID INT
	SET @tripHotelID = 
	(
		SELECT r.[HotelId] FROM [Trips] AS t
		JOIN [Rooms] AS r
		ON t.[RoomId] = r.[Id]
		WHERE t.[Id] = @TripId
	)

	DECLARE @roomHotelId INT
	SET @roomHotelId = 
	(
		SELECT [HotelId] FROM [Rooms]
		WHERE [Id] = @TargetRoomId
	)

	IF(@tripHotelID <> @roomHotelId) 
		THROW 50001, 'Target room is in another hotel!', 1

	DECLARE @targetRoomBeds INT
	SET @targetRoomBeds = 
	(
		SELECT [Beds] FROM [Rooms]
		WHERE [Id] = @TargetRoomId
	)

	DECLARE @people INT
	SET @people = 
	(
		SELECT COUNT(a.[Id]) FROM [Trips] AS t
		JOIN [AccountsTrips] AS [at]
		ON [at].[TripId] = t.[Id]
		JOIN [Accounts] AS a
		ON [at].[AccountId] = a.[Id]
		WHERE t.[Id] = @TripId
	)

	IF(@targetRoomBeds < @people)
		THROW 50002, 'Not enough beds in target room!', 1

	UPDATE [Trips]
	SET [RoomId] = @TargetRoomId
	WHERE [Id] = @TripId
END

GO

EXEC usp_SwitchRoom 10, 7 

EXEC usp_SwitchRoom 10, 8 

EXEC usp_SwitchRoom 10, 11

SELECT RoomId FROM Trips WHERE Id = 10 