--1)
CREATE DATABASE [Minions]

--2)
USE [Minions]

CREATE TABLE [Minions]
(
[Id] INT PRIMARY KEY,
[Name] NVARCHAR(50),
[Age] INT
)

CREATE TABLE [Towns]
(
[Id] INT PRIMARY KEY,
[Name] NVARCHAR(100)
)

--3)
ALTER TABLE [Minions]
ADD [TownID] INT FOREIGN KEY REFERENCES [Towns](Id)

--4)
INSERT INTO [Towns] VALUES
		(1, 'Sofia'),
		(2, 'Plovdiv'),
		(3, 'Varna')

INSERT INTO [Minions] VALUES
		(1, 'Kevin', 22, 1),
		(2, 'Bob', 15, 3),
		(3, 'Steward', NULL, 2)

SELECT * FROM [Minions]

--5)
TRUNCATE TABLE [Minions]

--6)
DROP TABLE [Minions], [Towns]

--7)
CREATE TABLE [People]
(
[Id] INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(200) NOT NULL,
[Picture] VARBINARY(MAX),
CHECK (DATALENGTH ([Picture]) <= 2000000),
[Height] DECIMAL(3, 2),
[Weight] DECIMAL(5, 2),
[Gender] CHAR(1) NOT NULL,
CHECK ([Gender] = 'm' OR [Gender] = 'f'),
[Birthdate] DATE NOT NULL,
[Biography] NVARCHAR(MAX)
)


INSERT INTO [People] VALUES
		('Gosho', NULL, 1.88, 100.20, 'm', '2002-01-29', 'No bio'),
		('Pesho', NULL, 1.89, 101.20, 'm', '2003-01-29', 'No bio'),
		('Jorko', NULL, 1.56, 60.20, 'm', '2004-01-29', 'No bio'),
		('Gichka', NULL, 1.33, 99.20, 'f', '2005-01-29', 'No bio'),
		('Ganka', NULL, 1.55, 120.20, 'f', '2006-01-29', 'No bio')


--8)Create Table Users


CREATE TABLE [Users]
(
[Id] INT PRIMARY KEY IDENTITY,
[UserName] VARCHAR(30) NOT NULL,
[Password] VARCHAR(26) NOT NULL,
[ProfilePicture] VARBINARY(max),
CHECK (DATALENGTH ([ProfilePicture]) <= 900000),
[LastLoginTime] DATETIME2,
[IsDeleted] BIT
)

INSERT INTO [Users] VALUES
		('Zhech1', 'Pass123', NULL, '1982-01-29 16:42:33', 1),
		('Zhech2', 'Pass1234', NULL, NULL, 0),
		('GoshoBoca', 'PaswordLesna', NULL, NULL, 1),
		('Zhech3', 'Pass12345', NULL, NULL, 1),
		('Zhech4', 'Pass123456', NULL, NULL, 0)


--9)Change Primary Key

SELECT name
FROM   sys.key_constraints
WHERE  [type] = 'PK'
       AND [parent_object_id] = Object_id('dbo.Users');

ALTER TABLE [Users]
	DROP CONSTRAINT PK__Users__3214EC070E8D984B

ALTER TABLE [Users]
	ADD CONSTRAINT PK_Users
	PRIMARY KEY ([Id], [UserName])

--10)Add Check Constraint

ALTER TABLE [Users]
	ADD CONSTRAINT Check_Pass_Lenght
	CHECK (LEN ([Password]) <= 5)


--11)Set Default Value of a Field

ALTER TABLE [Users] 
	ADD CONSTRAINT DF_LastLoginTime
	DEFAULT GETDATE() FOR [LastLoginTime]

--12)Set Unique Field

ALTER TABLE [Users]
	DROP CONSTRAINT PK_Users

ALTER TABLE [Users]
	ADD CONSTRAINT PK__Users__3214EC070E8D984B
	PRIMARY KEY ([Id])

ALTER TABLE [Users]
	ADD CONSTRAINT Check_UserName_Lenght
	CHECK (LEN ([UserName]) >= 3)

--13)Movies Database

CREATE DATABASE [Movies]

USE [Movies]

CREATE TABLE [Directors]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[DirectorName] NVARCHAR(50) NOT NULL,
	[Notes] NVARCHAR(800)
)

CREATE TABLE [Genres]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[GenreName] NVARCHAR(50) NOT NULL,
	[Notes] NVARCHAR(800)
)

CREATE TABLE [Categories]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[CategoryName] NVARCHAR(50) NOT NULL,
	[Notes] NVARCHAR(800)
)

CREATE TABLE [Movies]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Title] NVARCHAR(50),
	[DirectorId] INT FOREIGN KEY REFERENCES [Directors](Id) NOT NULL,
	[CopyrightYear] INT NOT NULL,
	[Length] TIME NOT NULL,
	[GenreId] INT FOREIGN KEY REFERENCES [Genres](Id) NOT NULL,
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories](Id) NOT NULL,
	[Rating] DECIMAL(2, 1) NOT NULL,
	[Notes] NVARCHAR(800)
)

INSERT INTO [Directors] VALUES
	('Director 1', NULL),
	('Director 2', NULL),
	('Director 3', NULL),
	('Director 4', NULL),
	('Director 5', NULL)


INSERT INTO [Genres] VALUES
	('Genre 1', NULL),
	('Genre 2', NULL),
	('Genre 3', NULL),
	('Genre 4', NULL),
	('Genre 5', NULL)

INSERT INTO [Categories] VALUES
	('Categorie 1', NULL),
	('Categorie 2', NULL),
	('Categorie 3', NULL),
	('Categorie 4', NULL),
	('Categorie 5', NULL)

INSERT INTO [Movies] VALUES
	('Movie 1', 5, 1989, '02:23:00', 5, 5, 4.5, NULL),
	('Movie 2', 3, 2021, '03:00:00', 3, 3, 6.5, NULL),
	('Movie 3', 2, 2013, '02:33:00', 2, 2, 9.5, NULL),
	('Movie 4', 4, 2022, '02:11:00', 4, 4, 2.5, NULL),
	('Movie 5', 1, 1982, '01:55:00', 1, 1, 9.9, NULL)

--14)Car Rental Database

CREATE DATABASE [CarRental]

USE [CarRental]

CREATE TABLE [Categories]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[CategoryName] NVARCHAR(50) NOT NULL,
	[DailyRate] DECIMAL(4, 2) NOT NULL,
	[WeeklyRate] DECIMAL (6, 2) NOT NULL,
	[MonthlyRate] DECIMAL (6, 2) NOT NULL,
	[WeekendRate] DECIMAL (6, 2) NOT NULL,
)

CREATE TABLE [Cars]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[PlateNumber] NVARCHAR(20) NOT NULL,
	[Manufacturer] NVARCHAR(50) NOT NULL,
	[Model] NVARCHAR(20) NOT NULL,
	[CarYear] INT NOT NULL,
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories](Id) NOT NULL,
	[Doors] INT NOT NULL,
	[Picture] IMAGE,
	[Condition] NVARCHAR(800) NOT NULL,
	[Available] BIT NOT NULL
)

CREATE TABLE [Employees]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(30) NOT NULL,
	[LastName] NVARCHAR(30) NOT NULL,
	[Title] NVARCHAR(60) NOT NULL,
	[Notes] NVARCHAR(500)
)

CREATE TABLE [Customers]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[DriverLicenceNumber] INT NOT NULL,
	[FullName] NVARCHAR(50) NOT NULL,
	[Address] NVARCHAR(100) NOT NULL,
	[City] NVARCHAR(50) NOT NULL,
	[ZIPCode] INT NOT NULL,
	[Notes] NVARCHAR(800)
)

CREATE TABLE [RentalOrders]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[EmployeeId] INT FOREIGN KEY REFERENCES [Employees](Id) NOT NULL,
	[CustomerId] INT FOREIGN KEY REFERENCES [Customers](Id) NOT NULL,
	[CarId] INT FOREIGN KEY REFERENCES [Cars](Id) NOT NULL,
	[TankLevel] INT NOT NULL,
	[KilometrageStart] INT NOT NULL,
	[KilometrageEnd] INT NOT NULL,
	[TotalKilometrage] INT NOT NULL,
	[StartDate] DATE NOT NULL,
	[EndDate] DATE NOT NULL,
	[TotalDays] INT NOT NULL,
	[RateApplied] DECIMAL(6, 2) NOT NULL,
	[TaxRate] DECIMAL(4, 2) NOT NULL,
	[OrderStatus] NVARCHAR(50) NOT NULL,
	[Notes] NVARCHAR(800)
)

INSERT INTO [Categories] VALUES
	('First category name', 10.00, 50.00, 150.00, 20.00),
	('Second category name', 50.00, 250.00, 750.00, 100.00),
	('Third category name', 99.00, 500.00, 1500.00, 200.00)

INSERT INTO [Cars] VALUES
	('PLN 0001', 'Ford', 'Model A', 1994, 4, 4, NULL, 'Good', 1),
	('PLN 0002', 'Tesla', 'Model B', 2021, 5, 4, NULL, 'Great', 1),
	('PLN 0003', 'Capsule Corp', 'Model C', 2054, 6, 10, NULL, 'Best', 0)

INSERT INTO [Employees] VALUES
	('Tyler', 'Durden', 'Edward Norton`s Alter Ego', NULL),
	('Plain', 'Jane', 'some gal', NULL),
	('Average', 'Joe', 'some dude', NULL)

INSERT INTO [Customers] VALUES
	('123456', 'Jimmy Carr', 'Britain', 'London', 1000, NULL),
	('654321', 'Bill Burr', 'USA', 'Washington', 2000, NULL),
	('999999', 'Louis CK', 'Mexico', 'Mexico City', 3000, NULL)

INSERT INTO [RentalOrders] VALUES
	(1, 1, 4, 70, 90000, 100000, 10000, '1994-10-01', '1994-10-21', 20, 100.00, 14.00, 'Pending', NULL),
	(2, 2, 5, 85, 250000, 2750000, 25000, '2011-11-12', '2011-11-24', 12, 150.00, 17.50, 'Canceled', NULL),
	(3, 3, 6, 90, 0, 120000, 120000, '2025-04-05', '2025-05-02', 27, 220.00, 21.25, 'Delivered', NULL)

--15)Hotel Database

CREATE DATABASE [Hotel]

USE [Hotel]

CREATE TABLE [Employees]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(30) NOT NULL,
	[LastName] NVARCHAR(30) NOT NULL,
	[Title] NVARCHAR(60) NOT NULL,
	[Notes] NVARCHAR(500)
)

CREATE TABLE [Customers]
(
	[AccountNumber] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(30) NOT NULL,
	[LastName] NVARCHAR(30) NOT NULL,
	[PhoneNumber] INT NOT NULL,
	[EmergencyName] NVARCHAR(30) NOT NULL,
	[EmergencyNumber] INT NOT NULL,
	[Notes] NVARCHAR(500)
)

CREATE TABLE [RoomStatus]
(
	[RoomStatus] VARCHAR(50) PRIMARY KEY NOT NULL,
	[Notes] NVARCHAR(500)
)

CREATE TABLE [RoomTypes]
(
	[RoomType] VARCHAR(50) PRIMARY KEY NOT NULL,
	[Notes] NVARCHAR(500)
)

CREATE TABLE [BedTypes]
(
	[BedType] VARCHAR(50) PRIMARY KEY NOT NULL,
	[Notes] NVARCHAR(500)
)

CREATE TABLE [Rooms]
(
	[RoomNumber] INT PRIMARY KEY IDENTITY,
	[RoomType] VARCHAR(50) FOREIGN KEY REFERENCES [RoomTypes](RoomType) NOT NULL,
	[BedType] VARCHAR(50) FOREIGN KEY REFERENCES [BedTypes](BedType) NOT NULL,
	[Rate] DECIMAL(6, 2) NOT NULL,
	[RoomStatus] VARCHAR(50) FOREIGN KEY REFERENCES [RoomStatus](RoomStatus) NOT NULL,
	[Notes] NVARCHAR(500)
)

CREATE TABLE [Payments]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[EmployeeId] INT FOREIGN KEY REFERENCES [Employees](Id) NOT NULL,
	[PaymentDate] DATE NOT NULL,
	[AccountNumber] INT FOREIGN KEY REFERENCES [Customers](AccountNumber),
	[FirstDateOccupied] DATE NOT NULL,
	[LastDateOccupied] DATE NOT NULL,
	[TotalDays] INT NOT NULL,
	[AmountCharged] DECIMAL(6, 2) NOT NULL,
	[TaxRate] DECIMAL(4, 2) NOT NULL,
	[TaxAmount] DECIMAL(6, 2) NOT NULL,
	[PaymentTotal] DECIMAL(6, 2) NOT NULL,
	[Notes] NVARCHAR(500)
)

CREATE TABLE [Occupancies]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[EmployeeId] INT FOREIGN KEY REFERENCES [Employees](Id) NOT NULL,
	[DateOccupied] DATE NOT NULL,
	[AccountNumber] INT FOREIGN KEY REFERENCES [Customers](AccountNumber) NOT NULL,
	[RoomNumber] INT FOREIGN KEY REFERENCES [Rooms](RoomNumber) NOT NULL,
	[RateApplied] DECIMAL (4, 2) NOT NULL,
	[PhoneCharge] DECIMAL (4, 2) NOT NULL,
	[Notes] NVARCHAR(500)
)

INSERT INTO [Employees] VALUES
	('First1', 'Last1', 'doing something1', NULL),
	('First2', 'Last2', 'doing something2', NULL),
	('First3', 'Last3', 'doing something3', NULL)

INSERT INTO [Customers] VALUES
	('CFirst1', 'CLast1', 111111, 'EmerContact1', 1111111, NULL),
	('CFirst2', 'CLast2', 222222, 'EmerContact2', 2222222, NULL),
	('CFirst3', 'CLast3', 333333, 'EmerContact3', 3333333, NULL)


INSERT INTO [RoomStatus] VALUES
	('Free', NULL),
	('Occupied', NULL),
	('No idea', NULL)
		
INSERT INTO [RoomTypes] VALUES
	('Room', NULL),
	('Studio', NULL),
	('Apartment', NULL)
		
INSERT INTO [BedTypes] VALUES
	('Big', NULL),
	('Small', NULL),
	('Child', NULL)

INSERT INTO [Rooms] VALUES
	('Room', 'Big', 15.00, 'Free', NULL),
	('Studio', 'Small', 12.50, 'Occupied', NULL),
	('Apartment', 'Child', 10.25, 'No idea', NULL)

INSERT INTO [Payments] VALUES
	(1, '2023-02-01', 1, '2023-01-11', '2023-01-14', 3, 250.00, 20.00, 50.00, 300.00, NULL),
	(2, '2023-02-02', 2, '2023-01-12', '2023-01-15', 3, 199.90, 20.00, 39.98, 239.88, NULL),
	(3, '2023-02-03', 3, '2023-01-13', '2023-01-16', 3, 330.50, 20.00, 66.10, 396.60, NULL)

INSERT INTO [Occupancies] VALUES
	(1, '2023-01-01', 1, 1, 20.00, 15.00, NULL),
	(2, '2023-01-02', 2, 2, 20.00, 12.50, NULL),
	(3, '2023-01-03', 3, 3, 20.00, 18.90, NULL)


--16)Create SoftUni Database

CREATE DATABASE SoftUni

USE [SoftUni]

CREATE TABLE [Towns]
(
	[Id] INT IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE [Addresses]
(
	[Id] INT IDENTITY NOT NULL,
	[AddressText] NVARCHAR(50) NOT NULL,
	[TownId] INT NOT NULL
)

CREATE TABLE [Departments]
(
	[Id] INT IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)


CREATE TABLE [Employees]
(
	[Id] INT IDENTITY NOT NULL,
	[FirstName] NVARCHAR(50) NOT NULL,
	[MiddleName] NVARCHAR(50) NOT NULL,
	[LastName] NVARCHAR(50) NOT NULL,
	[JobTitle] NVARCHAR(50) NOT NULL,
	[DepartmentId] INT NOT NULL,
	[HireDate] DATE NOT NULL,
	[Salary] DECIMAL(6, 2) NOT NULL,
	[AddressId] INT
)

ALTER TABLE [Towns]
	ADD CONSTRAINT PK_Towns
	PRIMARY KEY (Id)

ALTER TABLE [Addresses]
	ADD CONSTRAINT PK_Addresses
	PRIMARY KEY (Id)

ALTER TABLE [Addresses]
	ADD CONSTRAINT FK_Addresses
	FOREIGN KEY (TownId) REFERENCES [Towns](Id) 

ALTER TABLE [Departments]
	ADD CONSTRAINT PK_Departments
	PRIMARY KEY (Id)

ALTER TABLE [Employees]
	ADD CONSTRAINT PK_Employees
	PRIMARY KEY (Id)

ALTER TABLE [Employees]
	ADD CONSTRAINT FK_Employees
	FOREIGN KEY (DepartmentId) REFERENCES [Departments](Id)

ALTER TABLE [Employees]
	ADD CONSTRAINT FK_Employees_Address
	FOREIGN KEY (AddressId) REFERENCES [Addresses](Id)

--17)Backup Database

USE [master]

BACKUP DATABASE [SoftUni]
	TO DISK = N'C:\Program Files\Microsoft SQL Server\Backup\SoftUniDB.bak' 

GO

DROP DATABASE [SoftUni]

GO

RESTORE DATABASE [SoftUni] 
	FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\SoftUniDB.bak'