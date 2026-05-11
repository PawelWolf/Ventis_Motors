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