-- KORPORACYJNE RAPORTY ANALITYCZNE DLA VENTIS MOTORS

-- 1. Zestawienie łącznej sprzedaży według Serii pojazdów
SELECT 
    ser.SeriesName, 
    SUM(s.FinalPrice) AS SumaSprzedazy
FROM Series ser
JOIN Cars c ON ser.SeriesID = c.SeriesID
JOIN Sales s ON c.CarID = s.CarID
GROUP BY ser.SeriesName;

-- 2. Lista aut z pełną specyfikacją techniczną (Wielokrotny JOIN)
SELECT 
    c.CarID, 
    bt.TypeName AS TypNadwozia, 
    e.FuelType AS Paliwo, 
    c.Colour AS Kolor, 
    c.Price AS Cena
FROM Cars c
JOIN BodyTypes bt ON c.BodyTypeID = bt.BodyTypeID
JOIN Engines e ON c.EngineID = e.EngineID;

-- 3. Wyniki sprzedażowe pracowników (Ranking z filtrem HAVING)
SELECT 
    e.LastName, 
    COUNT(s.SaleID) AS IloscSprzedanych
FROM Employees e
JOIN Sales s ON e.EmployeeID = s.EmployeeID
GROUP BY e.LastName
HAVING COUNT(s.SaleID) > 1;

-- 4. Analiza czasowa przychodów salonu w podziale na lata
SELECT 
    YEAR(s.SaleDate) AS RokSprzedazy, 
    COUNT(*) AS LiczbaTransakcji,
    SUM(s.FinalPrice) AS UtargRoczny
FROM Sales s
GROUP BY YEAR(s.SaleDate);

-- 5. WIDOK: Interfejs szybkiej weryfikacji dostępnych aut dla sprzedawców
GO
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
GO

-- 6. GŁÓWNY RAPORT SERWISOWY (Mapowanie Części, Zleceń i Statusów aut)
SELECT 
    sh.ServiceID,
    c.CarID,
    st.StatusName AS StatusAutaNaStronie,
    sh.Description AS OpisZlecenia,
    p.PartName AS UzytaCzesc,
    sp.Quantity AS IloscSztuk,
    p.UnitPrice * sp.Quantity AS KosztCzesciBrutto
FROM ServiceHistory sh
JOIN Cars c ON sh.CarID = c.CarID
JOIN Statuses st ON c.StatusID = st.StatusID
JOIN ServiceParts sp ON sh.ServiceID = sp.ServiceID
JOIN Parts p ON sp.PartID = p.PartID;

-- 7. WIDOK: Analiza kosztów przygotowania auta na tle średniej dla Serii (Window Function)
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

-- 8. RAPORT: Czysty zysk salonu ze sprzedaży po odliczeniu kosztów serwisu i części
SELECT 
    c.CarID,
    ser.SeriesName AS Seria,
    c.Price AS CenaKatalogowa,
    ISNULL(sh.LaborCost, 0) AS KosztRobocizny,
    ISNULL(SUM(p.UnitPrice * sp.Quantity), 0) AS KosztCzesci,
    c.Price - (ISNULL(sh.LaborCost, 0) + ISNULL(SUM(p.UnitPrice * sp.Quantity), 0)) AS CzystyZyskSalonu
FROM Cars c
JOIN Series ser ON c.SeriesID = ser.SeriesID
LEFT JOIN ServiceHistory sh ON c.CarID = sh.CarID
LEFT JOIN ServiceParts sp ON sh.ServiceID = sp.ServiceID
LEFT JOIN Parts p ON sp.PartID = p.PartID
GROUP BY c.CarID, ser.SeriesName, c.Price, sh.LaborCost
ORDER BY CzystyZyskSalonu DESC;

-- 9. RAPORT PREMIUM: Ranking najdroższych napraw wewnątrz każdej Serii (CTE + RANK())
WITH PodsumowanieSerwisuCTE AS (
    SELECT 
        ser.SeriesName AS Seria,
        sh.CarID,
        sh.Description AS OpisNaprawy,
        sh.LaborCost + ISNULL(SUM(p.UnitPrice * sp.Quantity), 0) AS KosztCalkowity
    FROM ServiceHistory sh
    JOIN Cars c ON sh.CarID = c.CarID
    JOIN Series ser ON c.SeriesID = ser.SeriesID
    LEFT JOIN ServiceParts sp ON sh.ServiceID = sp.ServiceID
    LEFT JOIN Parts p ON sp.PartID = p.PartID
    GROUP BY ser.SeriesName, sh.CarID, sh.Description, sh.LaborCost
)
SELECT 
    Seria,
    CarID,
    OpisNaprawy,
    KosztCalkowity,
    RANK() OVER (PARTITION BY Seria ORDER BY KosztCalkowity DESC) AS PozycjaWSerii
FROM PodsumowanieSerwisuCTE;