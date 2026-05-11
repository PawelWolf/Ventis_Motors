-- Uproszczone raporty SQL dla Ventis Motors

-- 1. Zestawienie sprzedaży wg Serii (Łączenie tabel i suma)
-- Cel: Pokazanie, ile zarobiliśmy na każdej serii aut.
SELECT 
    ser.SeriesName, 
    SUM(s.FinalPrice) AS SumaSprzedazy
FROM Series ser
JOIN Cars c ON ser.SeriesID = c.SeriesID
JOIN Sales s ON c.CarID = s.CarID
GROUP BY ser.SeriesName;

-- 2. Lista aut z ich parametrami technicznymi (Wielokrotny JOIN)
-- Cel: Wyświetlenie pełnych informacji o aucie w jednym widoku.
SELECT 
    c.CarID, 
    bt.TypeName AS TypNadwozia, 
    e.FuelType AS Paliwo, 
    c.Colour AS Kolor, 
    c.Price AS Cena
FROM Cars c
JOIN BodyTypes bt ON c.BodyTypeID = bt.BodyTypeID
JOIN Engines e ON c.EngineID = e.EngineID;

-- 3. Najlepsi klienci (Agregacja i Sortowanie)
-- Cel: Znalezienie klientów, którzy kupili u nas najdroższe auta.
SELECT 
    cust.FirstName, 
    cust.LastName, 
    s.FinalPrice
FROM Customers cust
JOIN Sales s ON cust.CustomerID = s.CustomerID
WHERE s.FinalPrice > 80000
ORDER BY s.FinalPrice DESC;

-- 4. Liczba aut sprzedanych przez każdego pracownika (Group By i Having)
-- Cel: Sprawdzenie aktywności pracowników (tylko tych, co sprzedali więcej niż 1 auto).
SELECT 
    e.LastName, 
    COUNT(s.SaleID) AS IloscSprzedanych
FROM Employees e
JOIN Sales s ON e.EmployeeID = s.EmployeeID
GROUP BY e.LastName
HAVING COUNT(s.SaleID) > 1;

-- 5. Raport sprzedaży z podziałem na rok (Funkcja daty)
-- Cel: Prosta analiza czasowa sprzedaży.
SELECT 
    YEAR(s.SaleDate) AS RokSprzedazy, 
    COUNT(*) AS LiczbaTransakcji,
    SUM(s.FinalPrice) AS UtargRoczny
FROM Sales s
GROUP BY YEAR(s.SaleDate);

-- 6. Widok (View) dostępności (Wirtualna tabela)
-- Cel: Stworzenie prostego interfejsu dla sprzedawców łączącego serię, model i cenę.
-- UWAGA: W Azure SQL 'CREATE VIEW' jako osobne zapytanie w skłądni powinno znaleźć sie przedtem "GO".
/*
CREATE VIEW Widok_DostepneAuta AS
SELECT 
    ser.SeriesName AS Seria,
    bt.TypeName AS TypNadwozia,
    c.Colour AS Kolor,
    c.Price AS CenaKatalogowa
FROM Cars c
JOIN Series ser ON c.SeriesID = ser.SeriesID
JOIN BodyTypes bt ON c.BodyTypeID = bt.BodyTypeID
WHERE c.StatusID = (SELECT StatusID FROM Statuses WHERE StatusName = 'Available');
*/

-- SYMULACJA REALNEGO UŻYCIA

-- A. WPROWADZANIE (Nowy klient przyszedł do salonu)
INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES ('Jan', 'Kowalski', 'jan.kowalski@email.com', '+48 123 456 789');

-- B. MODYFIKACJA (Zmiana ceny auta w promocji - obniżka o 10%)
UPDATE Cars 
SET Price = Price * 0.9 
WHERE BodyTypeID = (SELECT BodyTypeID FROM BodyTypes WHERE TypeName = 'hatchback') 
AND StatusID = (SELECT StatusID FROM Statuses WHERE StatusName = 'Available');

-- C. USUNIĘCIE (Usunięcie klienta, który wycofał zgodę na przetwarzanie danych - RODO)
-- Uwaga: Usuwamy tylko jeśli nie ma powiązanych rekordów w Sales (spójność kluczy obcych)
DELETE FROM Customers 
WHERE Email = 'jan.kowalski@email.com' 
AND CustomerID NOT IN (SELECT CustomerID FROM Sales);