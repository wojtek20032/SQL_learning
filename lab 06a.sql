Use Northwind
----------------------------------------------------------------------------
-- Zapytania z podzapytaniami skorelowane i nieskorelowane, zapytania CTE --
----------------------------------------------------------------------------

--1. Wyœwietl najdro¿sze produkty w danej kategorii.
	SELECT C.CategoryName, P.ProductName, P.UnitPrice
	FROM Categories C JOIN Products P ON C.CategoryID = P.CategoryID
	WHERE UnitPrice IN (SELECT MAx(UnitPrice) from Products as p1 where p1.CategoryID = P.CategoryID)
	ORDER BY C.CategoryName, P.UnitPrice

--2. ZnaleŸæ kategoriê do której nie przypisano ¿adnego produktu
   --a. wykorzystuj¹c operator JOIN
	SELECT C.CategoryName, P.ProductName, P.UnitPrice
	FROM Categories C LEFT JOIN Products P ON C.CategoryID = P.CategoryID
	WHERE P.CategoryID is null
   --b. zapytanie z podzapytaniem skorelowane --np. EXISTS lub NOT EXISTS
   SELECT C.CategoryName
   FROM Categories C
   where NOT EXISTS(Select * FROM Products as P where P.CategoryID = C.CategoryID ) 
   --c. zapytanie z podzapytaniem nieskorelowane
   SELECT C.CategoryName
   FROM Categories C
   WHERE C.CategoryID NOT IN (SELECT P.CategoryID  FROM Products as P where P.CategoryID is not NULL)
--3. Który z pracowników zrealizowa³ najwiêksz¹ liczbê zamówieñ, w ka¿dym z lat funkcjonowania firmy.
	
	WITH TEMP1 as (
	SELECT E.FirstName + E.LastName as prac , DATENAME(YEAR, O.OrderDate) as dataa, COUNT(*) as ile, 
	ROW_NUMBER() OVER (PARTITION BY DATENAME(YEAR, O.OrderDate) ORDER BY COUNT(*) desc) as ranking
	FROM Employees E JOIN Orders O
	ON E.EmployeeID = O.EmployeeID
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY E.FirstName + E.LastName, DATENAME(YEAR, O.OrderDate))
	SELECT * FROM TEMP1
	WHERE TEMP1.ranking = 1
	
	
--4. Który z pracowników zrealizowa³ zamówienia sumarycznie za najwy¿sz¹ kwotê w danym roku.
	WITH TEMP1 as (
	SELECT E.FirstName + E.LastName as prac , DATENAME(YEAR, O.OrderDate) as dataa, SUM(OD.Quantity * OD.UnitPrice) as ile, 
	ROW_NUMBER() OVER (PARTITION BY DATENAME(YEAR, O.OrderDate) ORDER BY  SUM(OD.Quantity * OD.UnitPrice) desc) as ranking
	FROM Employees E JOIN Orders O
	ON E.EmployeeID = O.EmployeeID
	JOIN [Order Details] OD ON O.OrderID = OD.OrderID
	GROUP BY E.FirstName + E.LastName, DATENAME(YEAR, O.OrderDate))
	SELECT * FROM TEMP1
	WHERE TEMP1.ranking = 1
	go

--5. Jaki klient kupi³ za najwiêksz¹ kwotê sumarycznie, w ka¿dym z lat funkcjonowania firmy.
	WITH TEMP2 as (
	SELECT C.CompanyName as imie , DATENAME(YEAR, O.OrderDate) as dataa, SUM(OD.Quantity * OD.UnitPrice) as suma, 
	ROW_NUMBER() OVER  (PARTITION BY DATENAME(YEAR, O.OrderDate) ORDER BY  SUM(OD.Quantity * OD.UnitPrice) desc) as ranking
	FROM Customers C JOIN Orders O
	ON C.CustomerID = O.CustomerID
	JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	GROUP BY DATENAME(YEAR, O.OrderDate), C.CompanyName)
	SELECT * FROM TEMP2
	WHERE TEMP2.ranking = 1

--6. ZnajdŸ faktury ka¿dego z klientów opiewaj¹ce na najwy¿sze kwoty.
	SELECT C.CompanyName as nazwa, C.Fax, OD.Quantity * Od.UnitPrice as ile
	--ROW_NUMBER() OVER (PARTITION BY (C.CompanyName) ORDER BY SUM(OD.Quantity * Od.UnitPrice) desc) 
	FROM Customers C JOIN Orders O
	ON C.CustomerID = O.CustomerID
	JOIN [Order Details] OD ON OD.OrderID = O.OrderID
	ORDER BY C.CompanyName
	
--7. Podaj najlepiej sprzedaj¹ce siê produkty, w ka¿dej kategorii.
	WITH TEMP1 as(
	SELECT C.CategoryName, P.ProductName, SUM(OD.Quantity * OD.UnitPrice) as suma,
	ROW_NUMBER() OVER (PARTITION BY C.CategoryName ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc) as ranking
	FROM Categories C JOIN Products P
	ON C.CategoryID = P.CategoryID
	JOIN [Order Details] OD ON OD.ProductID = P.ProductID
	GROUP BY C.CategoryName, P.ProductName
	)
	SELECT * FROM TEMP1
	WHERE TEMP1.ranking = 1;
	
--8. Podaj jakiego towaru, ka¿dego z dostawców jest w magazynie na najwy¿sz¹ kwotê.
	WITH TEMP1 as (
	SELECT S.CompanyName,P.ProductName,  SUM(OD.Quantity * OD.UnitPrice) as suma,
	ROW_NUMBER() OVER (PARTITION BY S.CompanyName ORDER BY SUM(OD.Quantity * OD.UnitPrice) desc) as ranking
	FROM Suppliers S JOIN Products P ON S.SupplierID = P.SupplierID
	JOIN [Order Details] OD ON OD.ProductID = P.ProductID
	GROUP BY P.ProductName, S.CompanyName
	)
	SELECT * FROM TEMP1
	WHERE TEMP1.ranking = 1;

--9. Podaj najlepiej sprzedaj¹cy siê produkt, w ka¿dym z roku i kwartale funkcjonowania firmy.
	WITH YearlyTopSales AS (
    SELECT 
        S.CompanyName, 
        YEAR(O.OrderDate) AS Year,
        SUM(OD.Quantity * OD.UnitPrice) AS TotalSales,
        ROW_NUMBER() OVER (PARTITION BY YEAR(O.OrderDate) ORDER BY SUM(OD.Quantity * OD.UnitPrice) DESC) AS Ranking
    FROM 
        Suppliers S 
    JOIN 
        Products P ON S.SupplierID = P.SupplierID
    JOIN 
        [Order Details] OD ON OD.ProductID = P.ProductID
    JOIN 
        Orders O ON O.OrderID = OD.OrderID
    GROUP BY 
        S.CompanyName, YEAR(O.OrderDate)
),
QuarterlyTopSales AS (
    SELECT 
        S.CompanyName, 
        YEAR(O.OrderDate) AS Year,
        DATEPART(QUARTER, O.OrderDate) AS Quarter,
        SUM(OD.Quantity * OD.UnitPrice) AS TotalSales,
        ROW_NUMBER() OVER (PARTITION BY YEAR(O.OrderDate), DATEPART(QUARTER, O.OrderDate) ORDER BY SUM(OD.Quantity * OD.UnitPrice) DESC) AS Ranking
    FROM 
        Suppliers S 
    JOIN 
        Products P ON S.SupplierID = P.SupplierID
    JOIN 
        [Order Details] OD ON OD.ProductID = P.ProductID
    JOIN 
        Orders O ON O.OrderID = OD.OrderID
    GROUP BY 
        S.CompanyName, YEAR(O.OrderDate), DATEPART(QUARTER, O.OrderDate)
)

SELECT 
    yt.CompanyName, 
    yt.Year, 
    yt.TotalSales AS TotalSales_Year,
    qt.Quarter,
    qt.TotalSales AS TotalSales_Quarter
FROM 
    YearlyTopSales yt
JOIN 
    QuarterlyTopSales qt ON yt.CompanyName = qt.CompanyName AND yt.Year = qt.Year
WHERE 
    yt.Ranking = 1
    AND qt.Ranking = 1


--10. W jaki dzieñ tygodnia by³a najwiêksza i najmniejsza sprzeda¿.
	
	WITH DailySales AS (
    SELECT 
        DATEPART(DW, O.OrderDate) AS DayOfWeek,
        SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
    FROM 
        Suppliers S 
    JOIN 
        Products P ON S.SupplierID = P.SupplierID
    JOIN 
        [Order Details] OD ON OD.ProductID = P.ProductID
    JOIN 
        Orders O ON O.OrderID = OD.OrderID
    GROUP BY 
        DATEPART(DW, O.OrderDate)
)

SELECT 
    DayOfWeek,
    TotalSales
FROM 
    DailySales
WHERE 
    TotalSales = (SELECT MAX(TotalSales) FROM DailySales)
    OR TotalSales = (SELECT MIN(TotalSales) FROM DailySales)


--11. Tworzenie tabel na podstawie wyników polecenia: select * from products  (SELECT INTO)
   -- Do³ó¿ do wczeœniej utworzonej tabeli na podstawie zapytania jeszcze raz te same dane.
	
	SELECT * INTO NewProducts
	FROM Products

--12. Skasuj produkty nale¿¹ce do kategorii CAT1 (najpierw dodaæ 2 produkty bez kategorii, nastêpnie now¹ kategoriê CAT1 i przypisaæ    --dodanym wczeœniej produktom t¹ kategoriê)
   INSERT INTO Products (ProductName, SupplierID, UnitPrice)
	VALUES ('£Y¯KA', 1, 10.00),
       ('ROBOT', 2, 15.00);

	INSERT INTO Categories (CategoryName)
	VALUES('CAT1')

	DECLARE @CategoryID INT;
	SELECT @CategoryID = CategoryID
	FROM Categories
	WHERE CategoryName = 'CAT1';

	UPDATE Products
	SET CategoryID = @CategoryID
	WHERE ProductName in ('£Y¯KA', 'ROBOT')

	DELETE FROM Products 
   WHERE CategoryID IN (SELECT CategoryID FROM Categories WHERE CategoryName = 'CAT1')
-- ZnajdŸ ID kategorii na podstawie jej nazwy
	
	
   --a. wykorzystaæ zapytanie z podzapytaniem
	SELECT CategoryID
	FROM Categories
	WHERE CategoryName IN (SELECT CategoryName FROM Categories)
   --b. oraz zapytanie typu JOIN - jeœli siê da
	SELECT C.CategoryID
	FROM Categories C JOIN Categories CA
	ON C.CategoryName = CA.CategoryName
--13. Zmodyfikuj cenê produktów o 20% dla produktów nale¿¹cych do kategorii o nazwie CAT1.
	UPDATE Products
	SET UnitPrice = UnitPrice - (UnitPrice * 0.2)
	WHERE CategoryID IN (SELECT CategoryID from Categories WHERE CategoryName = 'CAT1')

--14. Podaj w pierwszej kolumnie ROK, w nastêpnych kolumnach miesi¹ce od 1 do 12.
  --W kolejnych rekordach podajemy sprzeda¿ w danym roku w danym miesi¹cu. Wykorzystaæ funkcjê COALESCE.
	
	SELECT 
    Year,
    COALESCE(SUM(CASE WHEN Month = 1 THEN TotalSales ELSE 0 END), 0) AS January,
    COALESCE(SUM(CASE WHEN Month = 2 THEN TotalSales ELSE 0 END), 0) AS February,
    COALESCE(SUM(CASE WHEN Month = 3 THEN TotalSales ELSE 0 END), 0) AS March,
    COALESCE(SUM(CASE WHEN Month = 4 THEN TotalSales ELSE 0 END), 0) AS April,
    COALESCE(SUM(CASE WHEN Month = 5 THEN TotalSales ELSE 0 END), 0) AS May,
    COALESCE(SUM(CASE WHEN Month = 6 THEN TotalSales ELSE 0 END), 0) AS June,
    COALESCE(SUM(CASE WHEN Month = 7 THEN TotalSales ELSE 0 END), 0) AS July,
    COALESCE(SUM(CASE WHEN Month = 8 THEN TotalSales ELSE 0 END), 0) AS August,
    COALESCE(SUM(CASE WHEN Month = 9 THEN TotalSales ELSE 0 END), 0) AS September,
    COALESCE(SUM(CASE WHEN Month = 10 THEN TotalSales ELSE 0 END), 0) AS October,
    COALESCE(SUM(CASE WHEN Month = 11 THEN TotalSales ELSE 0 END), 0) AS November,
    COALESCE(SUM(CASE WHEN Month = 12 THEN TotalSales ELSE 0 END), 0) AS December
FROM (
    SELECT 
        YEAR(O.OrderDate) AS Year,
        MONTH(O.OrderDate) AS Month,
        SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
    FROM Orders O
    JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
) AS MonthlySales
GROUP BY Year
ORDER BY Year;


--15. Wyœwietl najdro¿sze dwa produkty w danej kategorii (podajemy nazwê kategorii, nazwê produktu i jego cenê)

--16. Napisz kilka przyk³adowych zapytañ wykorzystuj¹cych operator [ANY|SOME, ALL] na bazie Northwind. Zadaj pytania, na które odpowiadaj¹ dane przyk³ady.

------------------------------------------------------------
-- Zastosowanie klauzuli OVER oraz funkcji rankingowowych --
------------------------------------------------------------
--17. Ponumerowaæ rekordy w tabeli PRODUCTS zgodnie z narastaj¹c¹ wartoœci¹ kolumny productname-ROW_NUMBER().
	SELECT ProductName, ROW_NUMBER()  OVER (ORDER BY ProductName) as 'numer' FROM Products
--18. Ponumerowaæ rekordy w tabeli PRODUCTS malej¹co po cenie produktu - ROW_NUMBER(), RANK(), DENSE_RANK().
	SELECT ProductName, UnitPrice ,
	ROW_NUMBER()  OVER (ORDER BY UnitPrice desc) as 'numer', 
	RANK()  OVER (ORDER BY UnitPrice desc) as 'numer' ,
	DENSE_RANK() OVER (ORDER BY UnitPrice desc) as 'numer' 
	FROM Products
--19. Ponumerowaæ rekordy rosn¹co po numerze kategorii produktu i malej¹co po cenie produktu.
	
	SELECT P.CategoryID, 
	DENSE_RANK() OVER (ORDER BY P.CategoryID asc) as kategoria,
	P.UnitPrice,
	
	DENSE_RANK() OVER (ORDER BY P.UnitPrice desc) as cena
	FROM Products P JOIN Categories C
	ON P.CategoryID = C.CategoryID
	
--20. Podaj nazwê kategorii, nazwê produktu oraz jego cenê oraz ranking wg. cen w danej kategorii (PARTITION BY)
	go
	With 
	temp1 as (
	SELECT C.CategoryName, P.ProductName, P.UnitPrice,
	ROW_NUMBER()  OVER (PARTITION BY C.CategoryName ORDER BY UnitPrice desc) as ranking
	FROM Categories C JOIN Products P ON C.CategoryID = P.CategoryID)
	SELECT * FROM temp1
	where ranking <=3
--21. Podaj ranking sprzeda¿y, w ka¿dej z kategorii.	
	WITH CategorySalesRanking AS (
    SELECT 
        c.CategoryName,
        p.ProductName,
        SUM(od.Quantity * od.UnitPrice) AS TotalSales,
        ROW_NUMBER() OVER (PARTITION BY c.CategoryName ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) AS SalesRank
    FROM 
        Categories c
    JOIN 
        Products p ON c.CategoryID = p.CategoryID
    JOIN 
        [Order Details] od ON p.ProductID = od.ProductID
    GROUP BY 
        c.CategoryName, p.ProductName
)

SELECT 
    CategoryName,
    ProductName,
    TotalSales,
    SalesRank
FROM 
    CategorySalesRanking
ORDER BY 
    CategoryName, SalesRank;

--22. Podaj trzy kategorie, w których sprzedano produktów za najwy¿sz¹ kwotê.
	SELECT TOP 3
        c.CategoryName,
        SUM(od.Quantity * od.UnitPrice) AS TotalSales
    FROM 
        Categories c
    JOIN 
        Products p ON c.CategoryID = p.CategoryID
    JOIN 
        [Order Details] od ON p.ProductID = od.ProductID
    GROUP BY 
        c.CategoryName
		ORDER BY SUM(od.Quantity * od.UnitPrice) desc
	
--23. Podaj w danej kategorii 3 najlepiej sprzedawane produkty.
	WITH TEMP1 as(
	SELECT 
        c.CategoryName,
		p.ProductName,
        SUM(od.Quantity * od.UnitPrice) AS TotalSales,
		ROW_NUMBER() OVER (PARTITION BY c.CategoryName  ORDER BY SUM(od.Quantity * od.UnitPrice) desc) as ranking
    FROM 
        Categories c
    JOIN 
        Products p ON c.CategoryID = p.CategoryID
    JOIN 
        [Order Details] od ON p.ProductID = od.ProductID
    GROUP BY 
        c.CategoryName, p.ProductName
		)
		SELECT * FROM TEMP1
		WHERE TEMP1.ranking <=3
-----------------------
-- Dodatkowe zadania --
-----------------------

--24. Chcemy otrzymaæ sprzeda¿, w ka¿dym miesi¹cu dla kolejnych lat z wykorzystaniem operatora PIVOT
	SELECT
    Month,
    [1996], [1997], [1998]
FROM (
    SELECT
        MONTH(O.OrderDate) AS Month,
        YEAR(O.OrderDate) AS Year,
        SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
    FROM
        Orders O
    JOIN
        [Order Details] OD ON O.OrderID = OD.OrderID
    GROUP BY
        MONTH(O.OrderDate), YEAR(O.OrderDate)
) AS SalesData
PIVOT (
    SUM(TotalSales)
    FOR Year IN ([1996], [1997], [1998])
) AS PivotTable
ORDER BY
    Month;

--	mon         1996                  1997                  1998
--	----------- --------------------- --------------------- ---------------------
--	1           NULL                  66692,80              100854,72
--	2           NULL                  41207,20              104561,95
--	3           NULL                  39979,90              109825,45
--	4           NULL                  55699,39              134630,56
--	5           NULL                  56823,70              19898,66
--	6           NULL                  39088,00              NULL
--	7           30192,10              55464,93              NULL
--	8           26609,40              49981,69              NULL
--	9           27636,00              59733,02              NULL
--	10          41203,60              70328,50              NULL
--	11          49704,00              45913,36              NULL
--	12          50953,40              77476,26              NULL

--25. Chcemy otrzymaæ sprzeda¿, w ka¿dym roku dla kolejnych miesiêcy z wykorzystaniem operatora PIVOT
	SELECT
    Year,[1] ,[2] ,[3] ,[4] , [5] ,[6] ,[7] ,[8] ,[9] ,[10] ,[11],[12] 
FROM (
    SELECT
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        SUM(Quantity * UnitPrice) AS TotalSales
    FROM
        Orders
    JOIN
        [Order Details] ON Orders.OrderID = [Order Details].OrderID
    GROUP BY
        YEAR(OrderDate), MONTH(OrderDate)
) AS SalesData
PIVOT (
    SUM(TotalSales)
    FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS PivotTable
ORDER BY
    Year;

--	Rok         1                     2                     3                     4                     5                     6                     7                     8                     9                     10                    11                    12
--	----------- --------------------- --------------------- --------------------- --------------------- --------------------- --------------------- --------------------- --------------------- --------------------- --------------------- --------------------- ---------------------
--	1996        NULL                  NULL                  NULL                  NULL                  NULL                  NULL                  30192,10              26609,40              27636,00              41203,60              49704,00              50953,40
--	1997        66692,80              41207,20              39979,90              55699,39              56823,70              39088,00              55464,93              49981,69              59733,02              70328,50              45913,36              77476,26
--	1998        100854,72             104561,95             109825,45             134630,56             19898,66              NULL                  NULL                  NULL                  NULL                  NULL                  NULL                  NULL

--26. Wyniki powy¿szych dwóch zapytañ zapisujemy w tabelach tymczasowych #tab1 i #tab2. 
   -- Tabele te nale¿y przedstawiæ w postaci jak przed modyfikacj¹ wykorzystuj¹c operator UNPIVOT 
 

--27. Chcemy otrzymaæ sprzeda¿, w ka¿dej kategorii dla kolejnych lat z wykorzystaniem operatora PIVOT
	--Pierwsza kolumna Nazwa_Kategorii, druga kolumna 1996 i dalej nastêpne lata.

--28. Instrukcja MERGE pozwala jednoczeœnie wykonaæ operacje wstawiania, usuwania lub aktualizacji
-- ró¿nych wierszy, czyli ³¹czy instrukcje INSERT, DELETE i UPDATE. Pozwala to szybko
-- zsynchronizowaæ dane zapisane w ró¿nych tabelach lub wykonaæ operacjê warunkowego
-- wstawiania wierszy nieistniej¹cych w tabeli docelowej i aktualizacji danych, które ju¿ s¹ w tej tabeli. 
USE Northwind
-- Tworzymy tabelê Ÿród³ow¹ Products_source (72 rekordy)
drop table if exists Products_source
select * into Products_source from Products where ProductID>=6
update Products_source set ProductName= 'Ikura1' where ProductName='Ikura'
-- w tabeli Ÿród³owej rekord id = 10 ma zmienion¹ nazwê
select * from Products_source
-- Tworzymy tabelê docelow¹ Products_target (10 rekordów)
drop table if exists Products_target
select * into Products_target from Products where ProductID<=10
update Products_target set ProductName= 'Chai1' where ProductName='Chai'
select * from Products_target
GO
-- Na podstawie tabeli Ÿród³owej chcemy zaktualizowaæ dane w tabeli docelowej 
-- W tabeli docelowej brakuje rekordów od id >= 11, a tak¿e zmodyfikowany jest id = 1.
-- Dodatkowo w tabeli docelowej jest 5 rekordów, których nie ma w tabeli Ÿród³owej, które nale¿y skasowaæ z tabeli docelowej.
-- Nale¿y wykonaæ wszystkie polecenia po kolei z wykorzystaniem instrukcji
-- INSERT ----------------------
SET IDENTITY_INSERT dbo.Products_target ON
GO
insert into Products_target (productid, productname, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock,
UnitsOnOrder, ReorderLevel, Discontinued)
select * from Products_source where ProductID NOT IN (select ProductID from Products_target)
GO
SET IDENTITY_INSERT dbo.Products_target OFF
GO
--select * from Products_target
--UPADTE -----------------------
update Products_target set Products_target.ProductName = ps.ProductName 
FROM Products_target pt inner join Products_source ps 
on pt.ProductID = ps.ProductID
where  pt.ProductName<>ps.ProductName

--DELETE -----------------------
-- SQL-2003 Standard subquery
DELETE FROM Products_target where ProductID NOT IN (select ProductID from Products_source)
--lub Transact-SQL extension
--DELETE Products_target 
--FROM Products_target AS pt  
--full JOIN Products_source AS ps  
--ON ps.ProductID = pt.ProductID  
--WHERE ps.ProductID IS NULL;  

-- Zadanie - wykorzystaæ jedn¹ instrukcjê MERGE do wykonania powy¿szych czynnoœci