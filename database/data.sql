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
-- ID 1: Paweł, ID 2: Konrad, ID 3: Oliwier, ID 4: Ivo Czura
INSERT INTO Employees (FirstName, LastName, Position) VALUES 
('Paweł', 'Wolf', 'Manager'),
('Konrad', 'Skrzypek', 'Sales Manager'),
('Oliwier', 'Pol', 'Sales specialist'),
('Ivo', 'Czura', 'Sales specialist');

-- Przykładowe samochody początkowe
INSERT INTO Cars (SeriesID, BodyTypeID, EngineID, StatusID, Colour, Price, ProductionYear) VALUES 
(1, 2, 2, 1, 'blue', 85000.00, 2024),
(2, 1, 1, 1, 'red', 72000.00, 2024),
(3, 3, 3, 1, 'black', 120000.00, 2024);

-- ROZBUDOWA FLOTY VENTIS MOTORS (~40 NOWYCH AUT)
INSERT INTO Cars (SeriesID, BodyTypeID, EngineID, StatusID, Colour, Price, ProductionYear) VALUES
(1, 1, 1, 1, 'white', 68000.00, 2023),
(1, 1, 1, 1, 'black', 69500.00, 2024),
(1, 1, 2, 1, 'red', 75000.00, 2024),
(1, 1, 4, 1, 'blue', 95000.00, 2025),
(1, 2, 1, 1, 'white', 78000.00, 2023),
(1, 2, 2, 1, 'black', 84000.00, 2024),
(1, 2, 2, 1, 'red', 85500.00, 2024),
(1, 4, 2, 1, 'white', 89000.00, 2024),
(1, 4, 3, 1, 'black', 98000.00, 2023),
(1, 4, 1, 1, 'blue', 82000.00, 2024),
(1, 3, 2, 1, 'white', 92000.00, 2024),
(1, 3, 3, 1, 'black', 101000.00, 2024),
(2, 1, 2, 1, 'red', 94000.00, 2024),
(2, 1, 4, 1, 'black', 115000.00, 2025),
(2, 1, 4, 1, 'white', 112000.00, 2024),
(2, 2, 2, 1, 'blue', 102000.00, 2024),
(2, 2, 3, 1, 'black', 118000.00, 2024),
(2, 2, 4, 1, 'red', 135000.00, 2025),
(2, 3, 3, 1, 'red', 128000.00, 2024),
(2, 3, 3, 1, 'black', 126000.00, 2023),
(2, 3, 4, 1, 'blue', 145000.00, 2025),
(2, 4, 2, 1, 'white', 108000.00, 2024),
(2, 4, 3, 1, 'black', 122000.00, 2024),
(2, 4, 4, 1, 'red', 139000.00, 2025),
(3, 2, 3, 1, 'black', 145000.00, 2024),
(3, 2, 3, 1, 'white', 142000.00, 2023),
(3, 2, 4, 1, 'blue', 168000.00, 2025),
(3, 3, 3, 1, 'black', 175000.00, 2024),
(3, 3, 3, 1, 'white', 172000.00, 2024),
(3, 3, 4, 1, 'red', 198000.00, 2025),
(3, 3, 4, 1, 'black', 195000.00, 2025),
(3, 4, 3, 1, 'black', 158000.00, 2024),
(3, 4, 4, 1, 'white', 182000.00, 2024),
(3, 4, 3, 1, 'blue', 160000.00, 2024),
(3, 1, 2, 1, 'black', 125000.00, 2024),
(3, 1, 4, 1, 'white', 149000.00, 2025);

-- MATEMATYCZNY GENERATOR TRANSAKCJI Z GWARANTOWANYM 60% UDZIAŁEM IVO CZURY
-- Najpierw losujemy 75% aut, a potem przypisujemy im precyzyjną wagę handlowców
WITH PulaLosowychAut AS (
    SELECT 
        CarID, 
        Price,
        ROW_NUMBER() OVER (ORDER BY NEWID()) as NumerWiersza,
        COUNT(*) OVER () as WszystkichTransakcji
    FROM Cars
    WHERE StatusID = 1
)
INSERT INTO Sales (CarID, CustomerID, EmployeeID, SaleDate, FinalPrice)
SELECT 
    CarID, 
    1, 
    CASE 
        -- Pierwsze 60% wygenerowanych wierszy bezdyskusyjnie zgarnia Ivo Czura (ID 4)
        WHEN CAST(NumerWiersza AS FLOAT) / WszystkichTransakcji <= 0.60 THEN 4
        -- Pozostałe 40% rozkłada się losowo pomiędzy Pawła (1), Konrada (2) i Oliwiera (3)
        ELSE (ABS(CHECKSUM(NEWID())) % 3) + 1
    END, 
    DATEADD(day, -cast(CarID as int)*3, GETDATE()), 
    Price 
FROM PulaLosowychAut
-- Warunek upewniający się, że bierzemy dokładnie 75% bazy aut
WHERE CAST(NumerWiersza AS FLOAT) / WszystkichTransakcji <= 0.75;

-- Synchronizacja statusu 'Sold' w tabeli Cars
UPDATE Cars
SET StatusID = 2
WHERE CarID IN (SELECT CarID FROM Sales);

-- KOMPLETNY ASORTYMENT MAGAZYNU CZĘŚCI
INSERT INTO Parts (PartIndex, PartName, UnitPrice, StockQuantity) VALUES
('OEM-BRK-001', 'Klocki hamulcowe Sport V1', 450.00, 20),
('OEM-FLT-099', 'Filtr powietrza Carbon', 120.00, 50),
('OEM-EXH-555', 'Uklad wydechowy V-Lux Performance', 3200.00, 5),
('OEM-SUS-777', 'Zawieszenie adaptacyjne Sport', 4100.00, 8),
('OEM-OIL-002', 'Olej syntetyczny Premium 5W30', 80.00, 100),
('OEM-FLT-101', 'Filtr oleju EcoLine Miejskie', 45.00, 100),
('OEM-FLT-102', 'Filtr oleju Bosch ProStandard', 85.00, 120),
('OEM-FLT-103', 'Filtr oleju K&N High-Performance', 160.00, 30),
('OEM-FLT-201', 'Filtr kabinowy weglowy (Antyalergiczny)', 140.00, 60),
('OEM-BRK-002', 'Klocki hamulcowe Brembo Standard', 320.00, 40),
('OEM-BRK-003', 'Klocki ceramiczne ATE Ceramic Premium', 580.00, 25),
('OEM-TRC-001', 'Tarcze hamulcowe nacinane V-Sport Front', 890.00, 16),
('OEM-TRC-002', 'Tarcze hamulcowe wentylowane V-Lux Rear', 720.00, 16),
('OEM-OIL-003', 'Olej Castrol EDGE 5W30 V-Base', 90.00, 150),
('OEM-OIL-004', 'Olej Motul Specific 0W20 V-Sport', 130.00, 80),
('OEM-OIL-005', 'Plyn hamulcowy DOT-4 High-Temp', 50.00, 200),
('OEM-TYR-17L', 'Opony Letnie Michelin Pilot Sport 17', 550.00, 32),
('OEM-TYR-18Z', 'Opony Zimowe Continental WinterContact 18', 780.00, 24),
('OEM-WHL-17S', 'Felgi aluminiowe 17 Silver Elegance', 600.00, 40);

-- USŁUGI SERWISOWE POCZĄTKOWE
INSERT INTO ServiceHistory (CarID, EmployeeID, LaborCost, Description) VALUES
(1, 1, 300.00, 'Przeglad zerowy i wymiana filtrów'),
(2, 2, 1200.00, 'Montaz pakietu sportowego wydechu i zawieszenia'),
(3, 3, 500.00, 'Wymiana klocków hamulcowych i uzupelnienie plynów');

INSERT INTO ServiceParts (ServiceID, PartID, Quantity) VALUES
(1, 2, 1), (1, 5, 5), (2, 3, 1), (2, 4, 1), (3, 1, 2);

-- MAPOWANIE DLA JEDNEGO AUTA WOLNEGO (ID 10) I JEDNEGO SPRZEDANEGO (ID 15)
INSERT INTO ServiceHistory (CarID, EmployeeID, LaborCost, Description) VALUES
(10, 1, 250.00, 'Przeglad zerowy przedekspozycyjny (Auto Dostepne na stronie)'),
(15, 3, 900.00, 'Modyfikacja ukladu hamulcowego po zakupie (Auto Sprzedane)');

INSERT INTO ServiceParts (ServiceID, PartID, Quantity) VALUES
((SELECT MAX(ServiceID) - 1 FROM ServiceHistory), 14, 5),
((SELECT MAX(ServiceID) - 1 FROM ServiceHistory), 6, 1),
((SELECT MAX(ServiceID) FROM ServiceHistory), 11, 1),
((SELECT MAX(ServiceID) FROM ServiceHistory), 12, 2);