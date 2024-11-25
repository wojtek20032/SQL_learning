USE Northwind

-- Wykonaj nastêpuj¹ce polecenia (aby uporz¹dkowaæ dane)
delete Products where ProductID>=78;
delete Categories where CategoryID >= 9;
insert into Categories (CategoryName) values ('A1');
insert into Products (ProductName) values ('P1');
insert into Products (ProductName, unitprice) values ('P2',1);
insert into Products (ProductName, unitprice, SupplierID) values ('P3',0,1);
select * from products
------------------------------------------------------
-- Agregacja danych, Group by, Having, Rollup, Cube --
------------------------------------------------------

-- 1. Ile jest dostawców (tabela Suppliers) i ilu dostawców ma podany w bazie danych faks  
	SELECT COUNT(*), Count(Fax) FROM Suppliers
-- 2. Podaj nazwy pañstw dostawców bez powtórzeñ
	SELECT DISTINCT Country
	FROM Suppliers
-- 3. Ile jest pañstw gdzie znajduj¹ siê nasi dostawcy (jedna liczba)
	SELECT  COUNT(DISTINCT Country)
	FROM Suppliers
-- 4. Ile jest produktów w tabeli Products (count), wartoœæ maksymalna ceny (max), minimalna cena (bez zera)(min) i wartoœæ œrednia (avg) (Dodaj produkt 'Prod X' z cen¹ NULL)
	insert into Products( ProductName, UnitPrice) values ('Prod X', NUll);
	select count(*), MAX(UnitPrice), (SELECT MIN(UnitPrice) from Products where UnitPrice > 0), AVG(UnitPrice) from Products
	go

	with 
	temp1(a1) as (select min(UnitPrice) from Products where UnitPrice > 0)
	select count(*), max(UnitPrice), (SELECT * from temp1) from Products
-- 5. Liczymy dodatkowo wartoœæ œredni¹ jako suma podzielona przez liczbê produktów oraz oblicona z wykorzystaniem AVG - porównaæ wyniki.
	SELECT SUM(UnitPrice)/ COUNT(*)
	FROM Products
-- 6. Jaka jest ca³kowita sprzeda¿ (bez upustów, z upustami, same upusty)
	SELECT SUM(UnitPrice * Quantity)
	FROM [Order Details]

	SELECT SUM((UnitPrice - (UnitPrice *Discount)) * Quantity)
	FROM [Order Details]

	SELECT SUM(Discount * Quantity * UnitPrice)
	FROM [Order Details]
-- 7. Ile firm jest w danym kraju
	SELECT Country, count(*)
	FROM Suppliers
	GROUP BY Country
-- 8. Ile firm jest w danym kraju zaczynaj¹cych siê na litery od a do f.
	SELECT Country, count(*) as 'ILE'
	FROM Suppliers
	WHERE Country LIKE '[a-f]%'
	GROUP BY Country
-- 9. Ile firm jest w danym kraju zaczynaj¹cych siê na litery od a do f. 
	-- Wyœwietl te kraje, gdzie liczba firm jest >=3 (GROUP BY, HAVING)
	SELECT Country, count(*) as 'ILE'
	FROM Suppliers
	WHERE Country LIKE '[a-f]%'
	GROUP BY Country
	HAVING count(*) >=3

-- 10. Podaj nazwê kraju, z których pochodz¹ pracownicy oraz ilu ich jest w danym kraju (tabela Employees) oraz iloœæ pracowników jest sumarycznie (jedno zapytanie) 
	-- (jedno zapytanie z opcj¹ rollup)
	SELECT Country, COUNT(*) as 'ILE'
	FROM Employees
	GROUP BY ROLLUP(Country) 
-- 11. Podaj na jak¹ kwotê znajduje sie towaru w magazynie
	SELECT SUM(UnitPrice * UnitsInStock)
	FROM Products
-- 12. Podaj na jak¹ kwotê znajduje sie towaru w magazynie w ka¿dej kategorii (podajemy nazwê kategorii) oraz we wszystkich kategoriach 
	-- (jedno zapytanie z opcj¹ rollup)
	SELECT C.CategoryName, SUM(P.UnitPrice * P.UnitsInStock) as 'SUM BY CATEGORY'
	FROM Products P JOIN Categories C
	ON P.CategoryID = C.CategoryID
	GROUP BY C.CategoryName

	SELECT C.CategoryName, SUM(P.UnitPrice * P.UnitsInStock) as 'SUM BY CATEGORY'
	FROM Products P JOIN Categories C
	ON P.CategoryID = C.CategoryID
	GROUP BY ROLLUP(C.CategoryName)
-- 13. Podaj na jak¹ kwotê znajduje sie towaru w magazynie 
	-- w ka¿dej kategorii categoryid (podajemy categoryid a nie nazwê kategorii)
	-- (s¹ produkty bez kategorii, dla której tak¿e ma byæ wyœwietlona kwota, 
	-- a kolumna categoryid ma podawaæ 'Bez kategorii')

	SELECT C.CategoryID, SUM(P.UnitPrice * P.UnitsInStock)
	FROM Products P LEFT JOIN Categories C
	ON P.CategoryID = C.CategoryID
	GROUP BY C.CategoryID
-- 14. Podaj na jak¹ kwotê znajduje sie towaru w magazynie w ka¿dej kategorii categoryname (s¹ produkty bez kategorii i te¿ ma byc wyœwietlona ich kwota)
	SELECT C.CategoryName, SUM(P.UnitPrice * P.UnitsInStock)
	FROM Products P LEFT JOIN Categories C
	ON P.CategoryID = C.CategoryID
	GROUP BY C.CategoryName
-- 15. Podaj sumaryczn¹ sprzeda¿ - tabela [order details] bez upustów
	SELECT SUM(UnitPrice * Quantity) as 'SUMA'
	FROM [Order Details]
-- 16. Podaj na jak¹ kwotê sprzedano towaru w ka¿dej kategorii  (podaj wszystkie kategorie)
	SELECT C.CategoryName, SUM(OD.UnitPrice * OD.Quantity) as 'SUM BY CATEGORY'
	FROM Categories C JOIN Products P
	ON C.CategoryID = P.CategoryID
	JOIN [Order Details] OD
	ON OD.ProductID = P.ProductID
	GROUP BY C.CategoryName

-- 17. Podaj na jak¹ kwotê sprzedano towaru w ka¿dej kategorii - podajemy tylko te kategorie w których sprzedano towaru za kwotê powy¿ej 200 000.
	SELECT C.CategoryName, SUM(OD.UnitPrice * OD.Quantity) as 'SUM BY CATEGORY'
	FROM Categories C JOIN Products P
	ON C.CategoryID = P.CategoryID
	JOIN [Order Details] OD
	ON OD.ProductID = P.ProductID
	GROUP BY C.CategoryName
	HAVING SUM(OD.UnitPrice * OD.Quantity) > 200000
-- 18. Podaj ile rodzajów produktów by³o sprzedanych w kazdej kategorii
	SELECT C.CategoryName, COUNT(DISTINCT P.ProductName) as 'Count by category'
	FROM Categories C JOIN Products P
	ON C.CategoryID = P.CategoryID
	GROUP BY C.CategoryName
-- 19. Porównujemy - -- nazwê kategorii, nazwê produktu i jego sprzeda¿ (wykorzystaæ cube nastêpnie rollup i znajdujemy ró¿nicê odejmuj¹c te zbiory)
	SELECT C.CategoryName, P.ProductName, SUM(OD.Quantity * OD.UnitPrice) 
	FROM Products P JOIN Categories C
	ON P.CategoryID = C.CategoryID
	JOIN [Order Details] OD
	ON OD.ProductID = P.ProductID
	GROUP BY ROLLUP(C.CategoryName), ROLLUP(P.ProductName)

	SELECT C.CategoryName, P.ProductName, SUM(OD.Quantity * OD.UnitPrice) 
	FROM Products P JOIN Categories C
	ON P.CategoryID = C.CategoryID
	JOIN [Order Details] OD
	ON OD.ProductID = P.ProductID
	GROUP BY CUBE(C.CategoryName), CUBE(P.ProductName)
-- 20. Który z pracowników sprzeda³ towarów za najwiêksz¹ kwotê
	SELECT TOP 1 E.FirstName + E.LastName,SUM(OD.Quantity * OD.UnitPrice) as 'ILE sprzedal'
	FROM Employees E JOIN Orders O
	ON E.EmployeeID = O.EmployeeID
	JOIN [Order Details] OD
	ON OD.OrderID = O.OrderID
	GROUP BY E.FirstName+E.LastName
	ORDER BY SUM(OD.Quantity * OD.UnitPrice)
-- 21. Podaj klienta, nazwê kategorii i sumaryczn¹ jego sprzeda¿ w ka¿dej z nich
	SELECT C.CompanyName, Ca.CategoryName, SUM(OD.Quantity * OD.UnitPrice)
	FROM Customers C JOIN Orders O
	ON C.CustomerID = O.CustomerID
	JOIN [Order Details] OD
	ON Od.OrderID = O.OrderID
	JOIN Products P
	ON P.ProductID = OD.ProductID
	JOIN Categories Ca
	ON Ca.CategoryID = P.CategoryID
	GROUP BY C.CompanyName, Ca.CategoryName
	ORDER BY C.CompanyName
-- 22. Jaki spedytor przewióz³ najwiêksz¹ wartoœæ sprzedanych towarów
	SELECT TOP 1 Sh.CompanyName, SUM(OD.Quantity * OD.UnitPrice) as 'ILE' 
	FROM Shippers Sh JOIN Orders O
	ON Sh.ShipperID = O.ShipVia
	JOIN [Order Details] OD
	ON OD.OrderID = O.OrderID
	GROUP BY Sh.CompanyName
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
-- 23. Wykorzystaæ funkcjê grouping do zapytania podaj¹cego nazwê kategorii, nazwê produktu i jego sprzeda¿
	SELECT C.CategoryName, P.ProductName, SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ', GROUPING(C.CategoryName) as 'CATNAME'
	FROM Categories C
	JOIN Products P ON C.CategoryID = P.CategoryID
	JOIN [Order Details] OD ON OD.ProductID = P.ProductID
	GROUP BY C.CategoryName, P.ProductName WITH ROLLUP;
-- 24. Jaka by³a sprzeda¿ towarów, które aktualnie s¹ wycofane ze sprzeda¿y (kolumna Discontinued w tabeli Products)
	SELECT P.ProductName, SUM(OD.Quantity * OD.UnitPrice) as 'SPRZEDAZ'
	FROM Products P JOIN [Order Details] OD
	ON P.ProductID = OD.ProductID
	WHERE P.Discontinued = 1
	GROUP BY P.ProductName
	
-- 25. Jaka by³a sumaryczna sprzeda¿ towarów w ka¿dej kategorii, 
	-- które aktualnie s¹ wycofane ze sprzeda¿y (kolumna Discontinued w tabeli Products)
	-- Podajemy CategoryName oraz sprzeda¿ (dwie kolumny)
	SELECT C.CategoryName, P.ProductName, SUM(OD.Quantity * OD.UnitPrice) as 'SPRZEDAZ'
	FROM Products P JOIN [Order Details] OD
	ON P.ProductID = OD.ProductID
	JOIN Categories C 
	ON C.CategoryID = P.CategoryID
	WHERE P.Discontinued = 1
	GROUP BY C.CategoryName, P.ProductName
-----------------------------------------------
-- Wykorzystanie funkcji zwi¹zanych z datami --
-----------------------------------------------
-- 26. Podaj sprzeda¿ towarów, w ka¿dym roku dzia³ania firmy (bez upustów)
	SELECT DATENAME(YEAR, O.ShippedDate) AS 'Rok', SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ'
	FROM Orders O 
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(YEAR, O.ShippedDate)
	ORDER BY 'Rok';
-- 27. Podaj sprzeda¿ towarów w ka¿dym roku i miesi¹cu dzia³ania firmy
   -- rok i miesi¹c podajemy w jednej kolumnie 
   SELECT DATENAME(YEAR, O.ShippedDate) +' '+ DATENAME(MONTH, O.ShippedDate) AS 'Rok i miesiac'  , SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ'
	FROM Orders O 
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(YEAR, O.ShippedDate), DATENAME(MONTH, O.ShippedDate)
	ORDER BY 'Rok i miesiac';

-- 28. Podaj sprzeda¿ towarów w ka¿dym roku i miesi¹cu dzia³ania firmy
   -- rok i miesi¹c podajemy w osobnych kolumnach)
	 SELECT DATENAME(YEAR, O.ShippedDate) AS 'Rok', DATENAME(MONTH, O.ShippedDate) as 'MIES', SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ'
	FROM Orders O 
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(YEAR, O.ShippedDate), DATENAME(MONTH, O.ShippedDate)
	ORDER BY 'Rok', 'MIES';
-- 29. Do ostatniego zapytania do³ó¿ klauzulê CUBE i ROLLUP i porównaj wyniki obu zapytañ (EXCEPT)
	--SELECT DATENAME(YEAR, O.ShippedDate) AS 'Rok', DATENAME(MONTH, O.ShippedDate) as 'MIES', SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ'
	--FROM Orders O 
	--JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	--GROUP BY ROLLUP(DATENAME(YEAR, O.ShippedDate), DATENAME(MONTH, O.ShippedDate) 
	--ORDER BY 'Rok', 'MIES'
	--EXCEPT
	--SELECT DATENAME(YEAR, O.ShippedDate) AS 'Rok', DATENAME(MONTH, O.ShippedDate) as 'MIES', SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ'
	--FROM Orders O 
	--JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	--GROUP BY DATENAME(YEAR, O.ShippedDate), DATENAME(MONTH, O.ShippedDate) with CUBE
	--ORDER BY 'Rok', 'MIES'
	
-- 30. Podaj numery zamówieñ, ich datê oraz ca³kowit¹ wartoœæ danego zamówienia (orderid, orderdate, unitprice, quantity) 
    -- dodatkowo podaj nazwê klienta i nazwê pracownika obs³uguj¹cego dane zamówienie
	-- oraz posortuj wzglêdem ca³kowitej wartoœci
	SELECT O.OrderID, O.OrderDate, SUM(OD.UnitPrice * Quantity) as 'SUMA', C.CompanyName, E.FirstName + E.LastName as 'imie pracownika'
	FROM Orders O JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	JOIN Employees E 
	ON E.EmployeeID = O.EmployeeID
	JOIN Customers C ON C.CustomerID = O.CustomerID
	GROUP BY O.OrderID, O.OrderDate, C.CompanyName, E.FirstName + E.LastName
	ORDER BY SUM(OD.UnitPrice * Quantity)
-- 31. Podaj numery zamówieñ, ich datê oraz ca³kowit¹ wartoœæ, 
	-- które by³y zrealizowane na najwiêksz¹ wartoœæ 
	SELECT TOP 1 OD.OrderID, O.OrderDate, SUM(OD.Quantity * OD.UnitPrice) as 'SUM'
	FROM [Order Details] OD JOIN Orders O
	ON OD.OrderID = O.OrderID
	GROUP BY OD.OrderID, O.OrderDate
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
-- 32. Podaj numery zamówieñ, ich datê oraz ca³kowit¹ wartoœæ, 
	-- które by³y zrealizowane na najmniejsz¹ wartoœæ(bez 0)
	SELECT TOP 1 OD.OrderID, O.OrderDate, SUM(OD.Quantity * OD.UnitPrice) as 'SUM'
	FROM [Order Details] OD JOIN Orders O
	ON OD.OrderID = O.OrderID
	GROUP BY OD.OrderID, O.OrderDate
	HAVING SUM(OD.Quantity * OD.UnitPrice) > 0
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) 
-- 33. Podaj numery zamówieñ, ich datê oraz ca³kowit¹ wartoœæ, 
	-- które by³y zrealizowane na najwiêksz¹ wartoœæ i na najmniejsz¹ wartoœæ(bez 0) w jednym zapytaniu.
	WITH OrderValues AS (
    SELECT 
        O.OrderID,
        O.OrderDate,
        SUM(OD.Quantity * OD.UnitPrice) AS TotalValue,
        ROW_NUMBER() OVER (ORDER BY SUM(OD.Quantity * OD.UnitPrice) DESC) AS MaxOrderRN,
        ROW_NUMBER() OVER (ORDER BY SUM(OD.Quantity * OD.UnitPrice) ASC) AS MinOrderRN
    FROM 
        Orders O
        JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    GROUP BY 
        O.OrderID, O.OrderDate
    HAVING 
        SUM(OD.Quantity * OD.UnitPrice) > 0
)
SELECT 
    OrderID,
    OrderDate,
    TotalValue
FROM 
    OrderValues
WHERE 
    MaxOrderRN = 1 OR MinOrderRN = 1;

-- 34. Podaj numery zamówieñ, ich datê oraz ca³kowit¹ wartoœæ, 
	-- które by³y zrealizowane na najwiêksz¹ wartoœæ i na najmniejsz¹ wartoœæ(bez 0) w jednym zapytaniu.
	-- zapytania typu CTE zaczynaj¹ce siê klauzul¹ WITH
	WITH OrderValues AS (
    SELECT 
        O.OrderID,
        O.OrderDate,
        SUM(OD.Quantity * OD.UnitPrice) AS TotalValue
    FROM 
        Orders O
        JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    GROUP BY 
        O.OrderID, O.OrderDate
    HAVING 
        SUM(OD.Quantity * OD.UnitPrice) > 0
),
MaxMinValues AS (
    SELECT 
        MAX(TotalValue) AS MaxValue,
        MIN(TotalValue) AS MinValue
    FROM 
        OrderValues
)
SELECT 
    OV.OrderID,
    OV.OrderDate,
    OV.TotalValue
FROM 
    OrderValues OV
    CROSS JOIN MaxMinValues MMV
WHERE 
    OV.TotalValue = MMV.MaxValue OR OV.TotalValue = MMV.MinValue;

-- 35. Podaj najdro¿szy i najtañszy z produktów (bez klauzuli TOP ani FETCH FIRST) (Podzapytania)
	SELECT 
    ProductName,
    UnitPrice
FROM 
    Products
WHERE 
    UnitPrice = (SELECT MAX(UnitPrice) FROM Products)
    OR 
    UnitPrice = (SELECT MIN(UnitPrice) FROM Products);
	

-- 36. Podaj najdro¿szy i najtañszy z produktów (bez klauzuli TOP ani FETCH FIRST) (Podzapytania)
	-- Zapytanie typu CTE zaczynaj¹c¹ siê na WITH
	WITH MaxMinPrices AS (
    SELECT 
        MAX(UnitPrice) AS MaxPrice,
        MIN(UnitPrice) AS MinPrice
    FROM 
        Products
)
SELECT 
    ProductName,
    UnitPrice
FROM 
    Products
CROSS JOIN MaxMinPrices
WHERE 
    UnitPrice = MaxPrice OR UnitPrice = MinPrice;

-- 37. Podaj numery zamówieñ, ich datê oraz ca³kowit¹ wartoœæ, 
	-- które by³y zrealizowane na najwiêksz¹ wartoœæ i na najmniejsz¹ wartoœæ(bez 0) w jednym zapytaniu.
	-- wykonaj powy¿sze zapytanie bez klauzuli top tylko z wykorzystaniem podzapytañ

-- 38. Skasuj produkty nale¿¹ce do kategorii CATX (nie znamy categoryid tylko categoryname)
	-- (najpierw dodaæ kategorie CATX i póŸniej 2 produkty nale¿¹ce do tej kategorii)

-- 39. Jaka jest sprzeda¿ sumaryczna w roku 1996 i 1997 (bez group by)
	SELECT 
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
	FROM 
    [Order Details] OD
    JOIN Orders O ON OD.OrderID = O.OrderID
	WHERE 
    YEAR(O.OrderDate) IN (1996, 1997);

-- 40. Podaj nazwê klienta, rok sprzeda¿y oraz wartoœæ sprzeda¿y w danym roku.
	SELECT E.FirstName+E.LastName as 'NAME', DATENAME(YEAR, O.OrderDate), SUM(OD.Quantity * OD.UnitPrice)
	FROM Employees E JOIN Orders O
	ON E.EmployeeID = O.EmployeeID
	JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	GROUP BY E.FirstName+E.LastName, DATENAME(YEAR, O.OrderDate)
	


-- 41. W jaki dzieñ tygodnia sumaryczenie sprzedano towaru za najwêksz¹ kwotê.
	SELECT Top 1 DATENAME(DW,O.OrderDate), SUM(OD.Quantity * OD.UnitPrice)
	FROM Orders O JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(DW,O.OrderDate)
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
	
	
-- 42. Podaj nazwê kategorii oraz rok, w którym w danej kategorii by³a najwiêksza sprzeda¿.
	SELECT TOP 1 C.CategoryName, DATENAME(YEAR, O.OrderDate) as 'YEAR', SUM(OD.Quantity * OD.UnitPrice) as 'SUMA'
	FROM Orders O JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	JOIN Products P ON P.ProductID = OD.ProductID
	JOIN Categories C ON C.CategoryID = P.CategoryID
	GROUP BY C.CategoryName, DATENAME(YEAR, O.OrderDate)
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
-- 43. W którym roku by³a nawy¿sza sprzeda¿.
	SELECT TOP 1 DATENAME(YEAR,O.OrderDate) as 'YEAR', SUM(OD.Quantity * OD.UnitPrice) as 'SUMA'
	FROM Orders O JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(YEAR,O.OrderDate)
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
-- 44. Który z pracowników obs³u¿y³ klientów za najwiêksz¹ kwotê w ka¿dym z lat.

-- 45. Jaki jest œredni czas w godzinach oraz w dniach miêdzy dat¹ zamówienia a dat¹ dostawy
	SELECT AVG(DATEDIFF(DAY, OrderDate,ShippedDate ))
	FROM Orders 
	SELECT AVG(DATEDIFF(HOUR, OrderDate,ShippedDate ))
	FROM Orders 
-- 46. Jaki jest œredni czas w godzinach od czasu zamówienia do dostarczenia przesy³ki 
	-- w ka¿dym z pañstw gdzie przesy³ki trafiaj¹.
	SELECT ShipCountry,AVG(DATEDIFF(HOUR, OrderDate,ShippedDate ))
	FROM Orders 
	GROUP BY ShipCountry
