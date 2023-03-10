CREATE DATABASE [WMS]
GO
USE [WMS]
GO

-- Section 1. DDL 

CREATE TABLE [Clients]
(
	[ClientId] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50) NOT NULL,
	[LastName] VARCHAR(50) NOT NULL,
	[Phone] CHAR(12) NOT NULL
)

CREATE TABLE [Mechanics]
(
	[MechanicId] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50) NOT NULL,
	[LastName] VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE [Models]
(
	[ModelId] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE [Jobs]
(
	[JobId] INT PRIMARY KEY IDENTITY,
	[ModelId] INT FOREIGN KEY REFERENCES [Models](ModelId) NOT NULL,
	[Status] VARCHAR(11) DEFAULT 'Pending' CHECK([Status] IN ('Pending', 'In Progress', 'Finished')) NOT NULL,
	[ClientId] INT FOREIGN KEY REFERENCES [Clients](ClientId) NOT NULL,
	[MechanicId] INT FOREIGN KEY REFERENCES [Mechanics](MechanicId),
	[IssueDate] DATE NOT NULL,
	[FinishDate] DATE
)

CREATE TABLE [Orders]
(
	[OrderId] INT PRIMARY KEY IDENTITY,
	[JobId] INT FOREIGN KEY REFERENCES [Jobs](JobId) NOT NULL,
	[IssueDate] DATE,
	[Delivered] BIT DEFAULT 0
)

CREATE TABLE [Vendors]
(
	[VendorId] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [Parts]
(
	[PartId] INT PRIMARY KEY IDENTITY,
	[SerialNumber] VARCHAR(50) UNIQUE NOT NULL,
	[Description] VARCHAR(255),
	[Price] MONEY CHECK([Price] <= 9999.99 AND [Price] > 0) NOT NULL,
	[VendorId] INT FOREIGN KEY REFERENCES [Vendors](VendorId) NOT NULL,
	[StockQty] INT DEFAULT 0 CHECK([StockQty] >= 0) NOT NULL
)

CREATE TABLE [OrderParts]
(
	[OrderId] INT FOREIGN KEY REFERENCES [Orders](OrderId) NOT NULL,
	[PartId] INT FOREIGN KEY REFERENCES [Parts](PartId) NOT NULL,
	[Quantity] INT DEFAULT 1 CHECK([Quantity] > 0) NOT NULL,
	PRIMARY KEY([OrderId],[PartId])
)

CREATE TABLE [PartsNeeded]
(
	[JobId] INT FOREIGN KEY REFERENCES [Jobs](JobId) NOT NULL,
	[PartId] INT FOREIGN KEY REFERENCES [Parts](PartId) NOT NULL,
	[Quantity] INT DEFAULT 1 CHECK([Quantity] > 0) NOT NULL,
	PRIMARY KEY([JobId],[PartId])
)

-- 2. INSERT

INSERT INTO Clients VALUES
    ('Teri',	'Ennaco',	    '570-889-5187'),
    ('Merlyn',	'Lawler',	    '201-588-7810'),
    ('Georgene','Montezuma',	'925-615-5185'),
    ('Jettie',	'Mconnell',	    '908-802-3564'),
    ('Lemuel',	'Latzke',	    '631-748-6479'),
    ('Melodie',	'Knipp',	    '805-690-1682'),
    ('Candida',	'Corbley',	    '908-275-8357')

INSERT INTO Parts (SerialNumber, Description, Price, VendorId)  VALUES
    ('WP8182119',	'Door Boot Seal',	117.86,	2),
    ('W10780048',	'Suspension Rod',	42.81,	1),
    ('W10841140',	'Silicone Adhesive', 	6.77,	4),
    ('WPY055980',	'High Temperature Adhesive',	13.94,	3)

-- 3. Update

UPDATE [Jobs]
SET [MechanicId] = 3, [Status] = 'In Progress'
WHERE [Status] = 'Pending'

-- 4. Delete
SELECT * FROM [OrderParts]

DELETE [OrderParts]
WHERE [OrderId] = 19

DELETE [Orders]
WHERE [OrderId] = 19

-- 5. Mechanic Assignments

SELECT 
  CONCAT(m.[FirstName], ' ', m.[LastName]) AS [Mechanic],
  	     j.[Status],
  	     j.[IssueDate]
      FROM [Jobs] AS j
      JOIN [Mechanics] AS m
      ON j.[MechanicId] = m.[MechanicId]
ORDER BY m.[MechanicId] ASC,
		 j.[JobId] ASC

-- 6. Current Clients

SELECT CONCAT(c.[FirstName], ' ', c.[LastName]) AS [Client],
DATEDIFF(DAY, j.[IssueDate], '2017-04-24') AS [Days going],
			  j.[Status]
		   FROM [Jobs] AS j
		   JOIN [Clients] AS c
		   ON j.[ClientId] = c.[ClientId]
		WHERE j.[Status] <> 'Finished'
       ORDER BY [Days going] DESC, c.[ClientId] ASC


-- 7. Mechanic Performance

SELECT 
  CONCAT([FirstName], ' ', [LastName]) AS [Mechanic],
     AVG([DaysForAJob]) AS [Average Days]
FROM 
(
	   SELECT m.[FirstName],
              m.[LastName],
			  m.[MechanicId],
DATEDIFF(DAY, j.[IssueDate], j.[FinishDate]) AS [DaysForAJob]
           FROM [Mechanics] AS m
           JOIN [Jobs] AS j
           ON j.[MechanicId] = m.[MechanicId]
        WHERE j.[Status] = 'Finished'
)     AS [SubQ]
GROUP BY [FirstName], [LastName], [MechanicId]
ORDER BY [MechanicId]

-- 8. Available Mechanics

SELECT
CONCAT([FirstName], ' ', [LastName]) AS [Available]
FROM [Mechanics]
WHERE [MechanicId] NOT IN 
(
	SELECT [MechanicId] FROM [Jobs]
	WHERE [Status] = 'In Progress'
)
ORDER BY [MechanicId]

-- 9. Past Expenses
SELECT
    [JobId],
SUM([TotalPriceForPart]) AS [Total]
FROM 
(
	SELECT
    (pn.[Quantity] * p.[Price]) AS [TotalPriceForPart],
    j.[JobId]
    FROM [Jobs] AS j
    JOIN [PartsNeeded] AS pn
    ON pn.[JobId] = j.[JobId]
    JOIN [Parts] AS p
    ON pn.[PartId] = p.[PartId]
    WHERE j.[Status] = 'Finished'
)AS [SubQ]
GROUP BY [JobId]
ORDER BY [Total] DESC,
		 [JobId] ASC

-- 10. Missing Parts


SELECT
            p.[PartId],
            p.[Description],
	   SUM(pn.[Quantity]) AS [Required],
	    SUM(p.[StockQty]) AS [In Stock],
ISNULL(SUM(op.[Quantity]), 0) AS [Ordered]
		 FROM [Parts] AS p
	LEFT JOIN [PartsNeeded] pn
		ON pn.[PartId] = p.[PartId]
	LEFT JOIN [Jobs] AS j
        ON pn.[JobId] = j.[JobId]
	LEFT JOIN [Orders] AS o
		 ON o.[JobId] = j.[JobId]
    LEFT JOIN [OrderParts] AS op
        ON op.[OrderId] = o.[OrderId]
      WHERE j.[Status] <> 'Finished'
   GROUP BY p.[PartId], p.[Description]
HAVING SUM(pn.[Quantity]) > SUM(p.[StockQty]) + ISNULL(SUM(op.[Quantity]), 0)
   ORDER BY p.[PartId]

-- 11. Place Order
GO
CREATE PROC usp_PlaceOrder(@jobID INT, @serial VARCHAR(50), @quantity INT)
AS
BEGIN
	IF(@jobID IN (SELECT [JobId] FROM [Jobs] WHERE [Status] = 'Finished'))
		THROW 50011, 'This job is not active!', 1
	IF(@quantity <= 0)
		THROW 50012, 'Part quantity must be more than zero!', 1
	IF(@jobID NOT IN (SELECT [JobId] FROM [Jobs]))
		THROW 50013, 'Job not found!', 1
	IF(@serial NOT IN (SELECT [SerialNumber] FROM [Parts]))
		THROW 50014, 'Part not found!', 1

DECLARE @partId INT = (SELECT TOP(1) PartId FROM Parts WHERE SerialNumber = @serial)
DECLARE @orderId INT

IF (@jobId IN (SELECT JobId FROM Orders WHERE IssueDate IS NULL))
    BEGIN
    SET @orderId = (SELECT TOP(1) OrderId FROM Orders WHERE JobId = @jobId)
    IF (@partId IN (SELECT PartId FROM OrderParts WHERE OrderId = @OrderId))
        BEGIN
        UPDATE OrderParts
            SET Quantity += @quantity 
            WHERE OrderId = @OrderId AND PartId = @partId
        RETURN
        END
    INSERT INTO OrderParts VALUES (@OrderId, @partId, @quantity)
    RETURN
    END

INSERT INTO Orders VALUES (@jobId, NULL, 0)
SET @orderId = (SELECT TOP(1) OrderId FROM Orders ORDER BY OrderId DESC)
INSERT INTO OrderParts VALUES (@OrderId, @partId, @quantity)
END


-- 12. 	Cost Of Order
GO

CREATE FUNCTION udf_GetCost(@jobId INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
RETURN ISNULL(
(
	  SELECT
	  SUM(p.[Price] * op.[Quantity])
	   FROM [Orders] AS o
	   JOIN [OrderParts] AS op
	  ON op.[OrderId] = o.[OrderId]
	   JOIN [Parts] AS p
	  ON op.[PartId] = p.[PartId]
	WHERE o.[JobId] = @jobId
), 0)
END

GO
