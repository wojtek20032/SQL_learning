USE Northwind

-- Wykonaj nast�puj�ce polecenia (aby uporz�dkowa� dane)
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

-- 1. Ile jest dostawc�w (tabela Suppliers) i ilu dostawc�w ma podany w bazie danych faks  
	SELECT COUNT(*), Count(Fax) FROM Suppliers
-- 2. Podaj nazwy pa�stw dostawc�w bez powt�rze�
	SELECT DISTINCT Country
	FROM Suppliers
-- 3. Ile jest pa�stw gdzie znajduj� si� nasi dostawcy (jedna liczba)
	SELECT  COUNT(DISTINCT Country)
	FROM Suppliers
-- 4. Ile jest produkt�w w tabeli Products (count), warto�� maksymalna ceny (max), minimalna cena (bez zera)(min) i warto�� �rednia (avg) (Dodaj produkt 'Prod X' z cen� NULL)
	insert into Products( ProductName, UnitPrice) values ('Prod X', NUll);
	select count(*), MAX(UnitPrice), (SELECT MIN(UnitPrice) from Products where UnitPrice > 0), AVG(UnitPrice) from Products
	go

	with 
	temp1(a1) as (select min(UnitPrice) from Products where UnitPrice > 0)
	select count(*), max(UnitPrice), (SELECT * from temp1) from Products
-- 5. Liczymy dodatkowo warto�� �redni� jako suma podzielona przez liczb� produkt�w oraz oblicona z wykorzystaniem AVG - por�wna� wyniki.
	SELECT SUM(UnitPrice)/ COUNT(*)
	FROM Products
-- 6. Jaka jest ca�kowita sprzeda� (bez upust�w, z upustami, same upusty)
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
-- 8. Ile firm jest w danym kraju zaczynaj�cych si� na litery od a do f.
	SELECT Country, count(*) as 'ILE'
	FROM Suppliers
	WHERE Country LIKE '[a-f]%'
	GROUP BY Country
-- 9. Ile firm jest w danym kraju zaczynaj�cych si� na litery od a do f. 
	-- Wy�wietl te kraje, gdzie liczba firm jest >=3 (GROUP BY, HAVING)
	SELECT Country, count(*) as 'ILE'
	FROM Suppliers
	WHERE Country LIKE '[a-f]%'
	GROUP BY Country
	HAVING count(*) >=3

-- 10. Podaj nazw� kraju, z kt�rych pochodz� pracownicy oraz ilu ich jest w danym kraju (tabela Employees) oraz ilo�� pracownik�w jest sumarycznie (jedno zapytanie) 
	-- (jedno zapytanie z opcj� rollup)
	SELECT Country, COUNT(*) as 'ILE'
	FROM Employees
	GROUP BY ROLLUP(Country) 
-- 11. Podaj na jak� kwot� znajduje sie towaru w magazynie
	SELECT SUM(UnitPrice * UnitsInStock)
	FROM Products
-- 12. Podaj na jak� kwot� znajduje sie towaru w magazynie w ka�dej kategorii (podajemy nazw� kategorii) oraz we wszystkich kategoriach 
	-- (jedno zapytanie z opcj� rollup)
	SELECT C.CategoryName, SUM(P.UnitPrice * P.UnitsInStock) as 'SUM BY CATEGORY'
	FROM Products P JOIN Categories C
	ON P.CategoryID = C.CategoryID
	GROUP BY C.CategoryName

	SELECT C.CategoryName, SUM(P.UnitPrice * P.UnitsInStock) as 'SUM BY CATEGORY'
	FROM Products P JOIN Categories C
	ON P.CategoryID = C.CategoryID
	GROUP BY ROLLUP(C.CategoryName)
-- 13. Podaj na jak� kwot� znajduje sie towaru w magazynie 
	-- w ka�dej kategorii categoryid (podajemy categoryid a nie nazw� kategorii)
	-- (s� produkty bez kategorii, dla kt�rej tak�e ma by� wy�wietlona kwota, 
	-- a kolumna categoryid ma podawa� 'Bez kategorii')

	SELECT C.CategoryID, SUM(P.UnitPrice * P.UnitsInStock)
	FROM Products P LEFT JOIN Categories C
	ON P.CategoryID = C.CategoryID
	GROUP BY C.CategoryID
-- 14. Podaj na jak� kwot� znajduje sie towaru w magazynie w ka�dej kategorii categoryname (s� produkty bez kategorii i te� ma byc wy�wietlona ich kwota)
	SELECT C.CategoryName, SUM(P.UnitPrice * P.UnitsInStock)
	FROM Products P LEFT JOIN Categories C
	ON P.CategoryID = C.CategoryID
	GROUP BY C.CategoryName
-- 15. Podaj sumaryczn� sprzeda� - tabela [order details] bez upust�w
	SELECT SUM(UnitPrice * Quantity) as 'SUMA'
	FROM [Order Details]
-- 16. Podaj na jak� kwot� sprzedano towaru w ka�dej kategorii  (podaj wszystkie kategorie)
	SELECT C.CategoryName, SUM(OD.UnitPrice * OD.Quantity) as 'SUM BY CATEGORY'
	FROM Categories C JOIN Products P
	ON C.CategoryID = P.CategoryID
	JOIN [Order Details] OD
	ON OD.ProductID = P.ProductID
	GROUP BY C.CategoryName

-- 17. Podaj na jak� kwot� sprzedano towaru w ka�dej kategorii - podajemy tylko te kategorie w kt�rych sprzedano towaru za kwot� powy�ej 200 000.
	SELECT C.CategoryName, SUM(OD.UnitPrice * OD.Quantity) as 'SUM BY CATEGORY'
	FROM Categories C JOIN Products P
	ON C.CategoryID = P.CategoryID
	JOIN [Order Details] OD
	ON OD.ProductID = P.ProductID
	GROUP BY C.CategoryName
	HAVING SUM(OD.UnitPrice * OD.Quantity) > 200000
-- 18. Podaj ile rodzaj�w produkt�w by�o sprzedanych w kazdej kategorii
	SELECT C.CategoryName, COUNT(DISTINCT P.ProductName) as 'Count by category'
	FROM Categories C JOIN Products P
	ON C.CategoryID = P.CategoryID
	GROUP BY C.CategoryName
-- 19. Por�wnujemy - -- nazw� kategorii, nazw� produktu i jego sprzeda� (wykorzysta� cube nast�pnie rollup i znajdujemy r�nic� odejmuj�c te zbiory)
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
-- 20. Kt�ry z pracownik�w sprzeda� towar�w za najwi�ksz� kwot�
	SELECT TOP 1 E.FirstName + E.LastName,SUM(OD.Quantity * OD.UnitPrice) as 'ILE sprzedal'
	FROM Employees E JOIN Orders O
	ON E.EmployeeID = O.EmployeeID
	JOIN [Order Details] OD
	ON OD.OrderID = O.OrderID
	GROUP BY E.FirstName+E.LastName
	ORDER BY SUM(OD.Quantity * OD.UnitPrice)
-- 21. Podaj klienta, nazw� kategorii i sumaryczn� jego sprzeda� w ka�dej z nich
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
-- 22. Jaki spedytor przewi�z� najwi�ksz� warto�� sprzedanych towar�w
	SELECT TOP 1 Sh.CompanyName, SUM(OD.Quantity * OD.UnitPrice) as 'ILE' 
	FROM Shippers Sh JOIN Orders O
	ON Sh.ShipperID = O.ShipVia
	JOIN [Order Details] OD
	ON OD.OrderID = O.OrderID
	GROUP BY Sh.CompanyName
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
-- 23. Wykorzysta� funkcj� grouping do zapytania podaj�cego nazw� kategorii, nazw� produktu i jego sprzeda�
	SELECT C.CategoryName, P.ProductName, SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ', GROUPING(C.CategoryName) as 'CATNAME'
	FROM Categories C
	JOIN Products P ON C.CategoryID = P.CategoryID
	JOIN [Order Details] OD ON OD.ProductID = P.ProductID
	GROUP BY C.CategoryName, P.ProductName WITH ROLLUP;
-- 24. Jaka by�a sprzeda� towar�w, kt�re aktualnie s� wycofane ze sprzeda�y (kolumna Discontinued w tabeli Products)
	SELECT P.ProductName, SUM(OD.Quantity * OD.UnitPrice) as 'SPRZEDAZ'
	FROM Products P JOIN [Order Details] OD
	ON P.ProductID = OD.ProductID
	WHERE P.Discontinued = 1
	GROUP BY P.ProductName
	
-- 25. Jaka by�a sumaryczna sprzeda� towar�w w ka�dej kategorii, 
	-- kt�re aktualnie s� wycofane ze sprzeda�y (kolumna Discontinued w tabeli Products)
	-- Podajemy CategoryName oraz sprzeda� (dwie kolumny)
	SELECT C.CategoryName, P.ProductName, SUM(OD.Quantity * OD.UnitPrice) as 'SPRZEDAZ'
	FROM Products P JOIN [Order Details] OD
	ON P.ProductID = OD.ProductID
	JOIN Categories C 
	ON C.CategoryID = P.CategoryID
	WHERE P.Discontinued = 1
	GROUP BY C.CategoryName, P.ProductName
-----------------------------------------------
-- Wykorzystanie funkcji zwi�zanych z datami --
-----------------------------------------------
-- 26. Podaj sprzeda� towar�w, w ka�dym roku dzia�ania firmy (bez upust�w)
	SELECT DATENAME(YEAR, O.ShippedDate) AS 'Rok', SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ'
	FROM Orders O 
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(YEAR, O.ShippedDate)
	ORDER BY 'Rok';
-- 27. Podaj sprzeda� towar�w w ka�dym roku i miesi�cu dzia�ania firmy
   -- rok i miesi�c podajemy w jednej kolumnie 
   SELECT DATENAME(YEAR, O.ShippedDate) +' '+ DATENAME(MONTH, O.ShippedDate) AS 'Rok i miesiac'  , SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ'
	FROM Orders O 
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(YEAR, O.ShippedDate), DATENAME(MONTH, O.ShippedDate)
	ORDER BY 'Rok i miesiac';

-- 28. Podaj sprzeda� towar�w w ka�dym roku i miesi�cu dzia�ania firmy
   -- rok i miesi�c podajemy w osobnych kolumnach)
	 SELECT DATENAME(YEAR, O.ShippedDate) AS 'Rok', DATENAME(MONTH, O.ShippedDate) as 'MIES', SUM(OD.Quantity * OD.UnitPrice) AS 'SPRZEDAZ'
	FROM Orders O 
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(YEAR, O.ShippedDate), DATENAME(MONTH, O.ShippedDate)
	ORDER BY 'Rok', 'MIES';
-- 29. Do ostatniego zapytania do�� klauzul� CUBE i ROLLUP i por�wnaj wyniki obu zapyta� (EXCEPT)
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
	
-- 30. Podaj numery zam�wie�, ich dat� oraz ca�kowit� warto�� danego zam�wienia (orderid, orderdate, unitprice, quantity) 
    -- dodatkowo podaj nazw� klienta i nazw� pracownika obs�uguj�cego dane zam�wienie
	-- oraz posortuj wzgl�dem ca�kowitej warto�ci
	SELECT O.OrderID, O.OrderDate, SUM(OD.UnitPrice * Quantity) as 'SUMA', C.CompanyName, E.FirstName + E.LastName as 'imie pracownika'
	FROM Orders O JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	JOIN Employees E 
	ON E.EmployeeID = O.EmployeeID
	JOIN Customers C ON C.CustomerID = O.CustomerID
	GROUP BY O.OrderID, O.OrderDate, C.CompanyName, E.FirstName + E.LastName
	ORDER BY SUM(OD.UnitPrice * Quantity)
-- 31. Podaj numery zam�wie�, ich dat� oraz ca�kowit� warto��, 
	-- kt�re by�y zrealizowane na najwi�ksz� warto�� 
	SELECT TOP 1 OD.OrderID, O.OrderDate, SUM(OD.Quantity * OD.UnitPrice) as 'SUM'
	FROM [Order Details] OD JOIN Orders O
	ON OD.OrderID = O.OrderID
	GROUP BY OD.OrderID, O.OrderDate
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
-- 32. Podaj numery zam�wie�, ich dat� oraz ca�kowit� warto��, 
	-- kt�re by�y zrealizowane na najmniejsz� warto��(bez 0)
	SELECT TOP 1 OD.OrderID, O.OrderDate, SUM(OD.Quantity * OD.UnitPrice) as 'SUM'
	FROM [Order Details] OD JOIN Orders O
	ON OD.OrderID = O.OrderID
	GROUP BY OD.OrderID, O.OrderDate
	HAVING SUM(OD.Quantity * OD.UnitPrice) > 0
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) 
-- 33. Podaj numery zam�wie�, ich dat� oraz ca�kowit� warto��, 
	-- kt�re by�y zrealizowane na najwi�ksz� warto�� i na najmniejsz� warto��(bez 0) w jednym zapytaniu.
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

-- 34. Podaj numery zam�wie�, ich dat� oraz ca�kowit� warto��, 
	-- kt�re by�y zrealizowane na najwi�ksz� warto�� i na najmniejsz� warto��(bez 0) w jednym zapytaniu.
	-- zapytania typu CTE zaczynaj�ce si� klauzul� WITH
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

-- 35. Podaj najdro�szy i najta�szy z produkt�w (bez klauzuli TOP ani FETCH FIRST) (Podzapytania)
	SELECT 
    ProductName,
    UnitPrice
FROM 
    Products
WHERE 
    UnitPrice = (SELECT MAX(UnitPrice) FROM Products)
    OR 
    UnitPrice = (SELECT MIN(UnitPrice) FROM Products);
	

-- 36. Podaj najdro�szy i najta�szy z produkt�w (bez klauzuli TOP ani FETCH FIRST) (Podzapytania)
	-- Zapytanie typu CTE zaczynaj�c� si� na WITH
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

-- 37. Podaj numery zam�wie�, ich dat� oraz ca�kowit� warto��, 
	-- kt�re by�y zrealizowane na najwi�ksz� warto�� i na najmniejsz� warto��(bez 0) w jednym zapytaniu.
	-- wykonaj powy�sze zapytanie bez klauzuli top tylko z wykorzystaniem podzapyta�

-- 38. Skasuj produkty nale��ce do kategorii CATX (nie znamy categoryid tylko categoryname)
	-- (najpierw doda� kategorie CATX i p�niej 2 produkty nale��ce do tej kategorii)

-- 39. Jaka jest sprzeda� sumaryczna w roku 1996 i 1997 (bez group by)
	SELECT 
    SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
	FROM 
    [Order Details] OD
    JOIN Orders O ON OD.OrderID = O.OrderID
	WHERE 
    YEAR(O.OrderDate) IN (1996, 1997);

-- 40. Podaj nazw� klienta, rok sprzeda�y oraz warto�� sprzeda�y w danym roku.
	SELECT E.FirstName+E.LastName as 'NAME', DATENAME(YEAR, O.OrderDate), SUM(OD.Quantity * OD.UnitPrice)
	FROM Employees E JOIN Orders O
	ON E.EmployeeID = O.EmployeeID
	JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	GROUP BY E.FirstName+E.LastName, DATENAME(YEAR, O.OrderDate)
	


-- 41. W jaki dzie� tygodnia sumaryczenie sprzedano towaru za najw�ksz� kwot�.
	SELECT Top 1 DATENAME(DW,O.OrderDate), SUM(OD.Quantity * OD.UnitPrice)
	FROM Orders O JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(DW,O.OrderDate)
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
	
	
-- 42. Podaj nazw� kategorii oraz rok, w kt�rym w danej kategorii by�a najwi�ksza sprzeda�.
	SELECT TOP 1 C.CategoryName, DATENAME(YEAR, O.OrderDate) as 'YEAR', SUM(OD.Quantity * OD.UnitPrice) as 'SUMA'
	FROM Orders O JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	JOIN Products P ON P.ProductID = OD.ProductID
	JOIN Categories C ON C.CategoryID = P.CategoryID
	GROUP BY C.CategoryName, DATENAME(YEAR, O.OrderDate)
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
-- 43. W kt�rym roku by�a nawy�sza sprzeda�.
	SELECT TOP 1 DATENAME(YEAR,O.OrderDate) as 'YEAR', SUM(OD.Quantity * OD.UnitPrice) as 'SUMA'
	FROM Orders O JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	GROUP BY DATENAME(YEAR,O.OrderDate)
	ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc
-- 44. Kt�ry z pracownik�w obs�u�y� klient�w za najwi�ksz� kwot� w ka�dym z lat.

-- 45. Jaki jest �redni czas w godzinach oraz w dniach mi�dzy dat� zam�wienia a dat� dostawy
	SELECT AVG(DATEDIFF(DAY, OrderDate,ShippedDate ))
	FROM Orders 
	SELECT AVG(DATEDIFF(HOUR, OrderDate,ShippedDate ))
	FROM Orders 
-- 46. Jaki jest �redni czas w godzinach od czasu zam�wienia do dostarczenia przesy�ki 
	-- w ka�dym z pa�stw gdzie przesy�ki trafiaj�.
	SELECT ShipCountry,AVG(DATEDIFF(HOUR, OrderDate,ShippedDate ))
	FROM Orders 
	GROUP BY ShipCountry
