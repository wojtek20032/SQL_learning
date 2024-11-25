-- Nazwisko: MACHAŁA
-- Imię: Wojciech
-- Numer albumu: 245867

USE Northwind
-- 1. Szukam produktów, których cena zawiera się w przedziale od 100 do 300 (łącznie z tymi wartościami) 
-- oraz dane produkty nie należą do kategorii o nazwie zaczynającej się na literę z zakresu od 'c' do 'p'. 
-- Następnie należy posortować dane względem nazwy produktu.
	SELECT P.ProductName, P.UnitPrice
	FROM Products P JOIN Categories C
	ON P.CategoryID = C.CategoryID	
	WHERE P.UnitPrice >= 100 AND P.UnitPrice <=300 AND C.CategoryName LIKE '[c-p]%'
	ORDER BY P.ProductName
-- 2. Znaleźć sumaryczną sprzedaż, w każdym roku i kwartale, kiedy realizowana była sprzedaż (podajemy rok, kwartał i sumaryczną sprzedaż bez upustów).
	SELECT 
    rok,
    kwartal,
    SUM(suma) AS suma_kwartału,
    SUM(SUM(suma)) OVER (PARTITION BY rok) AS suma_roku
FROM (
    SELECT 
        DATEPART(YEAR, O.OrderDate) AS rok, 
        DATEPART(QUARTER, O.OrderDate) AS kwartal, 
        SUM(OD.Quantity * OD.UnitPrice) AS suma
    FROM Orders O 
    JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    GROUP BY DATEPART(YEAR, O.OrderDate), DATEPART(QUARTER, O.OrderDate)
) AS sprzedaż
GROUP BY rok, kwartal
ORDER BY rok, kwartal;


	go 
-- 3. Podaj nazwę kraju klienta, ilość zamówień (ilość zamówień, a nie ilość pozycji na danym zamówieniu!) 
-- i sprzedaż, w każdym z krajów klientów (podać kraj klienta, ilość zamówień oraz sumaryczną kwotę na tych zamówieniach)?
	SELECT C.Country, COUNT(DISTINCT O.OrderID) AS ile_zamówień,
	SUM(OD.Quantity * OD.UnitPrice) AS suma_sprzedaży
FROM Customers C 
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN [Order Details] OD ON OD.OrderID = O.OrderID
GROUP BY C.Country;
go


-- 4. Znajdź najlepiej sprzedawane produkty (cena *ilość bez upustu), w każdym roku działania firmy, 
-- które nie są już aktualnie sprzedawane (są wycofane - kolumna Products.Discontinued = 1)
	
	WITH TEMP1 as(
	SELECT P.ProductName, SUM(OD.Quantity * OD.UnitPrice) as cena, P.Discontinued, DATENAME(YEAR, O.OrderDate) as dataa,
	ROW_NUMBER() OVER (PARTITION BY DATENAME(YEAR, O.OrderDate) ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc) as ranking
	FROM Products P JOIN [Order Details] OD ON P.ProductID = OD.ProductID
	JOIN Orders O ON O.OrderID = OD.OrderID
	WHERE P.Discontinued = 1
	GROUP BY P.ProductName, P.Discontinued, DATENAME(YEAR, O.OrderDate))
	SELECT * FROM TEMP1
	WHERE TEMP1.ranking = 1;
	
	
	go
-- 5. Podaj zamówienie(a) na najwyższą wartość zrealizowanych w 1998 roku (tylko na najwyższą wartość bez upustów)?
	WITH TEMP1 as (
	SELECT OD.OrderID as id, DATENAME(YEAR, O.OrderDate) as rok, SUM(OD.Quantity * OD.UnitPrice) as suma, 
	DENSE_RANK() OVER (PARTITION BY DATENAME(YEAR, O.OrderDate) 
	ORDER BY DATENAME(YEAR, O.OrderDate) desc, SUM(OD.Quantity * OD.UnitPrice) desc) as ranking
	FROM Orders O JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY  OD.OrderID, DATENAME(YEAR, O.OrderDate))
	SELECT * FROM  TEMP1 
	WHERE TEMP1.rok = 1998 AND TEMP1.ranking = 1

	

	
-- 6. Podaj sumaryczną wartość sprzedaży, w każdym dniu tygodnia dla kolejnych lat 
-- (wykorzystujemy PIVOT, pierwsza kolumna rok, następne kolumny to kolejne dni tygodnia w postaci słownej, 
-- na przecięciu mamy sprzedaż bez upustów). Przykład (w wynikach nie podajemy wartości NULL tylko wartość 0 jeśli nie było sprzedaży):
-- Rok		Poniedziałek	Wtorek		Środa		Czwartek	Piątek		Sobota	Niedziela
-- 1996		22795,30		17574,10	13834,40	18972,50	32555,30	0,00	0,00
-- 1997		66715,90		84373,40	73376,35	67970,54	83044,13	0,00	0,00
-- 1998		48894,89		60835,88	45308,87	45669,04	68778,01	0,00	0,00
	SELECT
    Year,
    ISNULL(Poniedziałek, 0) AS Poniedziałek,
    ISNULL(Wtorek, 0) AS Wtorek,
    ISNULL(Środa, 0) AS Środa,
    ISNULL(Czwartek, 0) AS Czwartek,
    ISNULL(Piątek, 0) AS Piątek,
    ISNULL(Sobota, 0) AS Sobota,
    ISNULL(Niedziela, 0) AS Niedziela
FROM (
    SELECT
        YEAR(OrderDate) AS Year,
        CASE WHEN DATEPART(dw, OrderDate) = 1 THEN 'Niedziela'
             WHEN DATEPART(dw, OrderDate) = 2 THEN 'Poniedziałek'
             WHEN DATEPART(dw, OrderDate) = 3 THEN 'Wtorek'
             WHEN DATEPART(dw, OrderDate) = 4 THEN 'Środa'
             WHEN DATEPART(dw, OrderDate) = 5 THEN 'Czwartek'
             WHEN DATEPART(dw, OrderDate) = 6 THEN 'Piątek'
             WHEN DATEPART(dw, OrderDate) = 7 THEN 'Sobota'
        END AS DayOfWeek,
        SUM(Quantity * UnitPrice) AS TotalSales
    FROM Orders
    JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
    GROUP BY YEAR(OrderDate), DATEPART(dw, OrderDate)
) AS SalesData
PIVOT (
    SUM(TotalSales)
    FOR DayOfWeek IN (Poniedziałek, Wtorek, Środa, Czwartek, Piątek, Sobota, Niedziela)
) AS PivotTable
ORDER BY Year;




-- 7. Podaj nazwisko pracownika oraz wartość przyznanych upustów, w każdym roku sprzedaży towarów
	SELECT E.LastName, DATENAME(YEAR, O.OrderDate) as rok, SUM(OD.Discount * OD.Quantity) as suma_upustow
	FROM Employees E JOIN Orders O
	ON E.EmployeeID = O.EmployeeID
	JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	GROUP BY E.LastName, DATENAME(YEAR, O.OrderDate)
	ORDER BY E.LastName

-- 8. Jakie trzy produkty zostały kupione za największą kwotę (sumaryczna cena * ilość bez upustów) 
-- dla każdego z klientów w całym okresie działania firmy Northwind?
-- (chodzi o sumaryczną wartość sprzedaży danego produktu a nie o ilość sztuk)
-- (Zapytanie zwraca: Nazwa klienta, nazwa produktu, sumaryczna wartość zakupionego produktu)
	go
	WITH TEMP1 as (
	SELECT C.CompanyName ,P.ProductName, SUM(OD.Quantity * OD.UnitPrice) as suma,
	ROW_NUMBER() OVER (PARTITION BY C.CompanyName ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc) as ranking
	FROM Customers C JOIN Orders O ON O.CustomerID =C.CustomerID
	JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	JOIN Products P ON P.ProductID = OD.ProductID
	GROUP BY C.CompanyName, P.ProductName
	)
	SELECT * FROM TEMP1 
	WHERE TEMP1.ranking <=3;
