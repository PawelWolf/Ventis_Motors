-- T-SQL Schema for Ventis Motors (Azure SQL)

-- 1. Serie samochodów (zamiast marek)
CREATE TABLE Series (
    SeriesID INT PRIMARY KEY IDENTITY(1,1),
    SeriesName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255)
);

-- 2. Typy nadwozia (powiązane z plikami graficznymi)
CREATE TABLE BodyTypes (
    BodyTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(30) NOT NULL -- hatchback, sedan, suv, kombi
);

-- 3. Silniki
CREATE TABLE Engines (
    EngineID INT PRIMARY KEY IDENTITY(1,1),
    Capacity FLOAT,
    FuelType NVARCHAR(20), -- Petrol, Diesel, Electric
    Horsepower INT
);

-- 4. Statusy dostępności
CREATE TABLE Statuses (
    StatusID INT PRIMARY KEY IDENTITY(1,1),
    StatusName NVARCHAR(30) NOT NULL -- Available, Sold, Reserved
);

-- 5. Samochody (Główna tabela)
CREATE TABLE Cars (
    CarID INT PRIMARY KEY IDENTITY(1,1),
    SeriesID INT FOREIGN KEY REFERENCES Series(SeriesID),
    BodyTypeID INT FOREIGN KEY REFERENCES BodyTypes(BodyTypeID),
    EngineID INT FOREIGN KEY REFERENCES Engines(EngineID),
    StatusID INT FOREIGN KEY REFERENCES Statuses(StatusID),
    Colour NVARCHAR(30) NOT NULL, -- blue, red, white, black
    Price DECIMAL(18, 2) NOT NULL,
    ProductionYear INT
);

-- 6. Klienci
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20)
);

-- 7. Pracownicy
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Position NVARCHAR(50)
);

-- 8. Sprzedaż (Tabela transakcyjna)
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    CarID INT FOREIGN KEY REFERENCES Cars(CarID),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    SaleDate DATETIME DEFAULT GETDATE(),
    FinalPrice DECIMAL(18, 2) NOT NULL
);