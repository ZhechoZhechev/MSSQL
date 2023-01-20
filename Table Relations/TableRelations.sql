CREATE DATABASE [TableRelations]
GO

USE [TableRelations]
GO

--01. One-To-One Relationship

CREATE TABLE [Passports]
(
	[PassportID] INT PRIMARY KEY IDENTITY(101, 1),
	[PassportNumber] VARCHAR(10) UNIQUE NOT NULL
)

CREATE TABLE [Persons]
(
	[PersonID] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(30) NOT NULL,
	[Salary] DECIMAL (7, 2) NOT NULL,
	[PassportID] INT FOREIGN KEY REFERENCES [Passports](PassportID) UNIQUE 
)

INSERT INTO [Passports] VALUES
	('N34FG21B'),
	('K65LO4R7'),
	('ZE657QP2')

INSERT INTO [Persons] VALUES
	('Roberto', 43300.00, 102),
	('Tom', 56100.00, 103),
	('Yana', 60200.00, 101)

--02. One-To-Many Relationship

CREATE TABLE [Manufacturers]
(
	[ManufacturerID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[EstablishedOn] DATE NOT NULL
)

CREATE TABLE [Models]
(
	[ModelID] INT PRIMARY KEY IDENTITY(101, 1),
	[Name] VARCHAR(30) NOT NULL,
	[ManufacturerID] INT FOREIGN KEY REFERENCES [Manufacturers](ManufacturerID)
)

INSERT INTO [Manufacturers] VALUES
	('BMW', '1916-03-07'),
	('Tesla', '2003-01-01'),
	('Lada', '1966-05-01')


INSERT INTO [Models] VALUES
	('X1', 1),
	('i6', 1),
	('Model S', 2),
	('Model X', 2),
	('Model 3', 2),
	('Nova', 3)

--03. Many-To-Many Relationship

CREATE TABLE [Students]
(
	[StudentID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE [Exams]
(
	[ExamID] INT PRIMARY KEY IDENTITY(101, 1),
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [StudentsExams]
(
	[StudentID] INT FOREIGN KEY 
	REFERENCES [Students](StudentID),
	[ExamID] INT FOREIGN KEY 
	REFERENCES [Exams](ExamID),
	CONSTRAINT PK_StudentsExams
	PRIMARY KEY([StudentID], [ExamID])
)

INSERT INTO [Students] VALUES
	('Mila'),
	('Toni'),
	('Ron')

INSERT INTO [Exams] VALUES
	('SpringMVC'),
	('Neo4j'),
	('Oracle 11g')

INSERT INTO [StudentsExams] VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103)

--04. Self-Referencing

CREATE TABLE [Teachers]
(
	[TeacherID] INT PRIMARY KEY IDENTITY(101, 1),
	[Name] VARCHAR(30) NOT NULL,
	[ManagerID] INT FOREIGN KEY REFERENCES [Teachers](TeacherID)
)

INSERT INTO [Teachers] VALUES
	('John', NULL),
	('Maya', 106),
	('Silvia', 106),
	('Ted', 105),
	('Mark', 101),
	('Greta', 101)

--05. Online Store Database

CREATE DATABASE [OnlineStore]
GO

USE [OnlineStore]
GO

CREATE TABLE [Cities]
(
	[CityID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [Customers]
(
	[CustomerID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[BirhtDay] DATE NOT NULL,
	[CityID] INT FOREIGN KEY REFERENCES [Cities](CityID)
)

CREATE TABLE [Orders]
(
	[OrderID] INT PRIMARY KEY IDENTITY,
	[CustomerID] INT FOREIGN KEY REFERENCES [Customers](CustomerId)
)

CREATE TABLE [ItemTypes]
(
	[ItemTypeID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [Items]
(
	[ItemID] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[ItemTypeID] INT FOREIGN KEY REFERENCES [ItemTypes](ItemTypeID)
)

CREATE TABLE [OrderItems]
(
	[OrderID] INT FOREIGN KEY REFERENCES [Orders](OrderID),
	[ItemID] INT FOREIGN KEY REFERENCES [Items](ItemID),
	CONSTRAINT PK_OrderItems
	PRIMARY KEY([OrderID],[ItemID])
)

--06. University Database

CREATE DATABASE [University]
GO

USE [University]
GO

CREATE TABLE [Subjects]
(
	[SubjectID] INT PRIMARY KEY IDENTITY,
	[SubjectName] NVARCHAR(30) NOT NULL
)

CREATE TABLE [Majors]
(
	[MajorID] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE [Students]
(
	[StudentID] INT PRIMARY KEY IDENTITY,
	[StudentNumber] INT UNIQUE NOT NULL,
	[StudentName] NVARCHAR(50) NOT NULL,
	[MajorID] INT FOREIGN KEY REFERENCES [Majors](MajorID)
)

CREATE TABLE [Agenda]
(
	[StudentID] INT FOREIGN KEY REFERENCES [Students](StudentID),
	[SubjectID] INT FOREIGN KEY REFERENCES [Subjects](SubjectID),
	CONSTRAINT PK_Agenda
	PRIMARY KEY ([StudentID], [SubjectID])
)

CREATE TABLE [Payments]
(
	[PaymentID] INT PRIMARY KEY IDENTITY,
	[PaymentDate] DATE NOT NULL,
	[PaymentAmount] DECIMAL (8, 2) NOT NULL,
	[StudentID] INT FOREIGN KEY REFERENCES [Students](StudentID)
)

--09. *Peaks in Rila

USE [Geography]
GO

SELECT m.MountainRange, p.PeakName, p.Elevation
FROM [Peaks] AS [p]
JOIN [Mountains] AS [m]
ON m.Id = p.MountainId
WHERE m.Id = 17
ORDER BY [Elevation] DESC