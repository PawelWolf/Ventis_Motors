-- T-SQL Schema for Ventis Motors (Azure SQL) - Wersja bezpieczna dla CI/CD

-- 1. Serie samochodów
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Series]') AND type in (N'U'))
CREATE TABLE Series (
    SeriesID INT PRIMARY KEY IDENTITY(1,1),
    SeriesName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255)
);

-- 2. Typy nadwozia
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BodyTypes]') AND type in (N'U'))
CREATE TABLE BodyTypes (
    BodyTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(30) NOT NULL
);

-- 3. Silniki
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Engines]') AND type in (N'U'))
CREATE TABLE Engines (
    EngineID INT PRIMARY KEY IDENTITY(1,1),
    Capacity FLOAT,
    FuelType NVARCHAR(20),
    Horsepower INT
);

-- 4. Statusy dostępności
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Statuses]') AND type in (N'U'))
CREATE TABLE Statuses (
    StatusID INT PRIMARY KEY IDENTITY(1,1),
    StatusName NVARCHAR(30) NOT NULL
);

-- 5. Samochody (Główna tabela)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cars]') AND type in (N'U'))
CREATE TABLE Cars (
    CarID INT PRIMARY KEY IDENTITY(1,1),
    SeriesID INT FOREIGN KEY REFERENCES Series(SeriesID),
    BodyTypeID INT FOREIGN KEY REFERENCES BodyTypes(BodyTypeID),
    EngineID INT FOREIGN KEY REFERENCES Engines(EngineID),
    StatusID INT FOREIGN KEY REFERENCES Statuses(StatusID),
    Colour NVARCHAR(30) NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    ProductionYear INT
);

-- 6. Klienci
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customers]') AND type in (N'U'))
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20)
);

-- 7. Pracownicy
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Employees]') AND type in (N'U'))
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Position NVARCHAR(50)
);

-- 8. Sprzedaż
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Sales]') AND type in (N'U'))
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    CarID INT FOREIGN KEY REFERENCES Cars(CarID),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    SaleDate DATETIME DEFAULT GETDATE(),
    FinalPrice DECIMAL(18, 2) NOT NULL
);

-- 9. Części
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Parts]') AND type in (N'U'))
CREATE TABLE Parts (
    PartID INT PRIMARY KEY IDENTITY(1,1),
    PartIndex NVARCHAR(50) UNIQUE NOT NULL,
    PartName NVARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    StockQuantity INT DEFAULT 0
);

-- 10. Historia serwisowa
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ServiceHistory]') AND type in (N'U'))
CREATE TABLE ServiceHistory (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    CarID INT FOREIGN KEY REFERENCES Cars(CarID),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    ServiceDate DATETIME DEFAULT GETDATE(),
    LaborCost DECIMAL(18,2) NOT NULL,
    Description NVARCHAR(255)
);

-- 11. Części serwisowe
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ServiceParts]') AND type in (N'U'))
CREATE TABLE ServiceParts (
    ServiceID INT FOREIGN KEY REFERENCES ServiceHistory(ServiceID),
    PartID INT FOREIGN KEY REFERENCES Parts(PartID),
    Quantity INT NOT NULL,
    PRIMARY KEY (ServiceID, PartID)
);