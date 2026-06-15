-- Uproszczone raporty SQL dla Ventis Motors

-- 1. Zestawienie sprzedaży wg Serii (Łączenie tabel i suma)
-- Cel: Pokazanie, ile zarobiliśmy na każdej serii aut po tabeli Series.
SELECT 
    ser.SeriesName, 
    SUM(s.FinalPrice) AS SumaSprzedazy
FROM Series ser
JOIN Cars c ON ser.SeriesID = c.SeriesID
JOIN Sales s ON c.CarID = s.CarID
GROUP BY ser.SeriesName;

-- 1.A Dodawanie sprzedaży z poziomu aplikacji WEB --- przykład

-- WYKLIKANIE W APLIKACJI

-- 1.B Usuwanie sprzedaży z poziomu zapytania SQL --- przykład
-- Załóżmy, że chcemy usunąć sprzedaż o SaleID = 5, ale najpierw musimy przywrócić status auta na 'Available' (StatusID = 1), aby zachować spójność danych.

BEGIN TRANSACTION;
-- 1.B.1 Przywróć status samochodu na 'Available' (StatusID = 1)
UPDATE Cars
SET StatusID = 1
WHERE CarID = (SELECT CarID FROM Sales WHERE SaleID = 19);

-- 1.B.2 Usuń rekord sprzedaży
DELETE FROM Sales
WHERE SaleID = 19;

COMMIT TRANSACTION;



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

CREATE VIEW Widok_DostepneAuta AS
SELECT 
    ser.SeriesName AS Seria,
    bt.TypeName AS TypNadwozia,
    c.Colour AS Kolor,
    c.Price AS CenaKatalogowa,
    c.CarID AS NumerKatalogowy
FROM Cars c
JOIN Series ser ON c.SeriesID = ser.SeriesID
JOIN BodyTypes bt ON c.BodyTypeID = bt.BodyTypeID
WHERE c.StatusID = (SELECT StatusID FROM Statuses WHERE StatusName = 'Available');


-- SYMULACJA REALNEGO UŻYCIA

-- A. WPROWADZANIE (Nowy klient przyszedł do salonu)
INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES ('Jan', 'Kowalski', 'jan.kowalski@email.com', '+48 123 456 789');

-- B. MODYFIKACJA (Zmiana ceny auta w promocji - podwyżka o 50%)
UPDATE Cars 
SET Price = Price * 1.5 
WHERE BodyTypeID = (SELECT BodyTypeID FROM BodyTypes WHERE TypeName = 'suv') 
AND StatusID = (SELECT StatusID FROM Statuses WHERE StatusName = 'Available');

-- C. SPRZEDAŻ (Zarejestrowanie sprzedaży auta)
BEGIN TRANSACTION;
-- C.1. Zaktualizuj status auta na 'Sold' (StatusID = 2)
UPDATE Cars
SET StatusID = 2
WHERE CarID = 1; -- Załóżmy, że sprzedajemy auto o CarID = 33
-- C.2. Dodaj rekord sprzedaży
INSERT INTO Sales (CarID, CustomerID, EmployeeID, FinalPrice)
VALUES (33, (SELECT CustomerID FROM Customers WHERE Email = 'jan.kowalski@email.com'), 1, 200000);
COMMIT TRANSACTION;

-- C. USUNIĘCIE (Usunięcie klienta, który wycofał zgodę na przetwarzanie danych - RODO)
-- Uwaga: Usuwamy tylko jeśli nie ma powiązanych rekordów w Sales (spójność kluczy obcych)
DELETE FROM Customers 
WHERE Email = 'jan.kowalski@email.com' 
AND CustomerID NOT IN (SELECT CustomerID FROM Sales);

-- 7. Zaawansowana analiza kosztów serwisu na tle średniej (Window Function)
-- Cel: Porównanie kosztów przygotowania konkretnego auta do średniej dla całej serii.
-- UWAGA: W Azure SQL instrukcja CREATE VIEW musi być wykonana jako pierwsze zapytanie w bloku, dlatego oddzielamy ją GO.
GO
CREATE VIEW Widok_AnalizaKosztowSerwisu AS
SELECT 
    sh.ServiceID,
    c.CarID,
    ser.SeriesName,
    sh.LaborCost,
    SUM(p.UnitPrice * sp.Quantity) AS KosztCzesci,
    sh.LaborCost + SUM(p.UnitPrice * sp.Quantity) AS CalkowityKosztSerwisu,
    AVG(sh.LaborCost + (p.UnitPrice * sp.Quantity)) OVER(PARTITION BY ser.SeriesID) AS SredniaDlaSerii
FROM ServiceHistory sh
JOIN Cars c ON sh.CarID = c.CarID
JOIN Series ser ON c.SeriesID = ser.SeriesID
JOIN ServiceParts sp ON sh.ServiceID = sp.ServiceID
JOIN Parts p ON sp.PartID = p.PartID
GROUP BY sh.ServiceID, c.CarID, ser.SeriesID, ser.SeriesName, sh.LaborCost, p.UnitPrice, sp.Quantity;
GO

-- Wywołanie testowe widoku analitycznego:
SELECT * FROM Widok_AnalizaKosztowSerwisu;