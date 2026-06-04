-- Wypełnienie typów nadwozia
INSERT INTO BodyTypes (TypeName) VALUES ('hatchback'), ('sedan'), ('suv'), ('kombi');

-- Wypełnienie serii
INSERT INTO Series (SeriesName, Description) VALUES 
('V-Base', 'Podstawowa linia miejska'),
('V-Sport', 'Wersja o podwyższonych osiągach'),
('V-Lux', 'Linia premium z luksusowym wykończeniem');

-- Wypełnienie silników
INSERT INTO Engines (Capacity, FuelType, Horsepower) VALUES 
(1.2, 'Petrol', 90),
(1.5, 'Petrol', 130),
(2.0, 'Diesel', 150),
(0.0, 'Electric', 204);

-- Statusy
INSERT INTO Statuses (StatusName) VALUES ('Available'), ('Sold'), ('Reserved');

-- Pracownicy
INSERT INTO Employees (FirstName, LastName, Position) VALUES 
('Paweł', 'Wolf', 'Manager'),
('Konrad', 'Skrzypek', 'Sales Manager'),
('Oliwier', 'Pol', 'Sales specialist'),
('Ivo', 'Czura', 'Sales specialist');

-- Przykładowe samochody
-- Przykład: CarID 1 to sedan_blue.jpg
INSERT INTO Cars (SeriesID, BodyTypeID, EngineID, StatusID, Colour, Price, ProductionYear) VALUES 
(1, 2, 2, 1, 'blue', 85000.00, 2024),  -- Sedan Blue
(2, 1, 1, 1, 'red', 72000.00, 2024),   -- Hatchback Red
(3, 3, 3, 1, 'black', 120000.00, 2024); -- SUV Black

-- ROZBUDOWA FLOTY VENTIS MOTORS (~40 NOWYCH AUT)

-- Seria 1: V-Base (Miejskie/Ekonomiczne) - SeriesID = 1
INSERT INTO Cars (SeriesID, BodyTypeID, EngineID, StatusID, Colour, Price, ProductionYear) VALUES
(1, 1, 1, 1, 'white', 68000.00, 2023),   -- Hatchback, Benzyna 1.2, Dostępny
(1, 1, 1, 1, 'black', 69500.00, 2024),   -- Hatchback, Benzyna 1.2, Dostępny
(1, 1, 2, 2, 'red', 75000.00, 2024),     -- Hatchback, Benzyna 1.5, Sprzedany
(1, 1, 4, 1, 'blue', 95000.00, 2025),    -- Hatchback, Elektryk, Dostępny
(1, 2, 1, 1, 'white', 78000.00, 2023),   -- Sedan, Benzyna 1.2, Dostępny
(1, 2, 2, 2, 'black', 84000.00, 2024),   -- Sedan, Benzyna 1.5, Sprzedany
(1, 2, 2, 1, 'red', 85500.00, 2024),     -- Sedan, Benzyna 1.5, Dostępny
(1, 4, 2, 1, 'white', 89000.00, 2024),   -- Kombi, Benzyna 1.5, Dostępny
(1, 4, 3, 2, 'black', 98000.00, 2023),   -- Kombi, Diesel 2.0, Sprzedany
(1, 4, 1, 3, 'blue', 82000.00, 2024),    -- Kombi, Benzyna 1.2, Rezerwacja
(1, 3, 2, 1, 'white', 92000.00, 2024),   -- SUV, Benzyna 1.5, Dostępny
(1, 3, 3, 2, 'black', 101000.00, 2024);  -- SUV, Diesel 2.0, Sprzedany

-- Seria 2: V-Sport (Osiągi/Dynamika) - SeriesID = 2
INSERT INTO Cars (SeriesID, BodyTypeID, EngineID, StatusID, Colour, Price, ProductionYear) VALUES
(2, 1, 2, 1, 'red', 94000.00, 2024),     -- Hatchback, Benzyna 1.5, Dostępny
(2, 1, 4, 2, 'black', 115000.00, 2025),  -- Hatchback, Elektryk, Sprzedany
(2, 1, 4, 1, 'white', 112000.00, 2024),  -- Hatchback, Elektryk, Dostępny
(2, 2, 2, 1, 'blue', 102000.00, 2024),   -- Sedan, Benzyna 1.5, Dostępny
(2, 2, 3, 2, 'black', 118000.00, 2024),  -- Sedan, Diesel 2.0, Sprzedany
(2, 2, 4, 1, 'red', 135000.00, 2025),    -- Sedan, Elektryk, Dostępny
(2, 3, 3, 1, 'red', 128000.00, 2024),    -- SUV, Diesel 2.0, Dostępny
(2, 3, 3, 2, 'black', 126000.00, 2023),  -- SUV, Diesel 2.0, Sprzedany
(2, 3, 4, 3, 'blue', 145000.00, 2025),   -- SUV, Elektryk, Rezerwacja
(2, 4, 2, 1, 'white', 108000.00, 2024),  -- Kombi, Benzyna 1.5, Dostępny
(2, 4, 3, 2, 'black', 122000.00, 2024),  -- Kombi, Diesel 2.0, Sprzedany
(2, 4, 4, 1, 'red', 139000.00, 2025);    -- Kombi, Elektryk, Dostępny

-- Seria 3: V-Lux (Klasa Premium) - SeriesID = 3
INSERT INTO Cars (SeriesID, BodyTypeID, EngineID, StatusID, Colour, Price, ProductionYear) VALUES
(3, 2, 3, 1, 'black', 145000.00, 2024),  -- Sedan, Diesel 2.0, Dostępny
(3, 2, 3, 2, 'white', 142000.00, 2023),  -- Sedan, Diesel 2.0, Sprzedany
(3, 2, 4, 1, 'blue', 168000.00, 2025),   -- Sedan, Elektryk, Dostępny
(3, 3, 3, 1, 'black', 175000.00, 2024),  -- SUV, Diesel 2.0, Dostępny
(3, 3, 3, 2, 'white', 172000.00, 2024),  -- SUV, Diesel 2.0, Sprzedany
(3, 3, 4, 1, 'red', 198000.00, 2025),    -- SUV, Elektryk, Dostępny
(3, 3, 4, 2, 'black', 195000.00, 2025),  -- SUV, Elektryk, Sprzedany
(3, 4, 3, 1, 'black', 158000.00, 2024),  -- Kombi, Diesel 2.0, Dostępny
(3, 4, 4, 2, 'white', 182000.00, 2024),  -- Kombi, Elektryk, Sprzedany
(3, 4, 3, 3, 'blue', 160000.00, 2024),   -- Kombi, Diesel 2.0, Rezerwacja
(3, 1, 2, 1, 'black', 125000.00, 2024),  -- Hatchback, Benzyna 1.5, Dostępny
(3, 1, 4, 2, 'white', 149000.00, 2025);  -- Hatchback, Elektryk, Sprzedany


-- NOWY, SPREPAROWANY GENERATOR TRANSAKCJI (Ivo Czura  jest debeściak i sprzedaje najwiecej bo proponuje przy okazji randke z nim w pastrami Leszno)
INSERT INTO Sales (CarID, CustomerID, EmployeeID, SaleDate, FinalPrice)
SELECT 
    CarID, 
    1, 
    CASE 
        WHEN CarID % 4 IN (0, 1, 2) THEN 4  -- Jeśli reszta z dzielenia to 0, 1 lub 2 -> Sprzedaje Ivo Czura (ID 4)
        ELSE (CarID % 3) + 1                -- W pozostałych przypadkach losowo Paweł, Konrad lub Oliwier (ID 1-3)
    END, 
    DATEADD(day, -cast(CarID as int)*3, GETDATE()), 
    Price 
FROM Cars 
WHERE StatusID = 2 AND CarID > 3;

-- WYPEŁNIENIE DANYCH DLA MAGAZYNU I SERWISU


INSERT INTO Parts (PartIndex, PartName, UnitPrice, StockQuantity) VALUES
('OEM-BRK-001', 'Klocki hamulcowe Sport V1', 450.00, 20),
('OEM-FLT-099', 'Filtr powietrza Carbon', 120.00, 50),
('OEM-EXH-555', 'Układ wydechowy V-Lux Performance', 3200.00, 5),
('OEM-SUS-777', 'Zawieszenie adaptacyjne Sport', 4100.00, 8),
('OEM-OIL-002', 'Olej syntetyczny Premium 5W30', 80.00, 100);

-- Dodanie pierwszych zleceń naprawy/tuningu dla istniejących aut
INSERT INTO ServiceHistory (CarID, EmployeeID, LaborCost, Description) VALUES
(1, 1, 300.00, 'Przegląd zerowy i wymiana filtrów'),
(2, 2, 1200.00, 'Montaż pakietu sportowego wydechu i zawieszenia'),
(3, 3, 500.00, 'Wymiana klocków hamulcowych i uzupełnienie płynów');

-- Zużycie części w konkretnych zleceniach
INSERT INTO ServiceParts (ServiceID, PartID, Quantity) VALUES
(1, 2, 1),
(1, 5, 5),
(2, 3, 1),
(2, 4, 1),
(3, 1, 2);