USE Northwind

-----------------------------
-- Łączenie tabel join cd. --
-----------------------------

-- Wykonaj następujące polecenia (aby uporządkować dane)
delete Products where ProductID>=78;
delete Categories where CategoryID >= 9;
insert into Categories (CategoryName) values ('A1');
insert into Products (ProductName) values ('P1');
insert into Products (ProductName, SupplierID) values ('P2',1);
-- czy wykonując zapytanie widzimy wprowadzone rekordy ? :(NIE)
select ProductName, UnitPrice, CategoryName
	from (Categories c inner join Products p
	on c.CategoryID = p.CategoryID)

-- 1. Podaj nazwę produktu, jego cenę i nazwę kategorii z tabel Products i Categories.
	-- chcemy także wyświetlić wszystkie nazwy kategorii nawet te przez przypisanych produktów 
	select ProductName, UnitPrice, CategoryName
	from (Categories c left join Products p
	on c.CategoryID = p.CategoryID)
-- 2. Podaj nazwę produktu, jego cenę i nazwę kategorii z tabel Products i Categories.
	-- chcemy także wyświetlić wszystkie produkty nawet bez przypisanej kategorii 
	select ProductName, UnitPrice, CategoryName
	from (Categories c right join Products p
	on c.CategoryID = p.CategoryID)
-- 3. Podaj nazwę produktu, jego cenę i nazwę kategorii z tabel Products i Categories.
	-- chcemy także wyświetlić wszystkie produkty i wszystkie kategorie 
	select ProductName, UnitPrice, CategoryName
	from (Categories c full join Products p
	on c.CategoryID = p.CategoryID)
-- 4.Podaj nazwy kategorii, które nie mają przypisanych produktów.
	select  CategoryName
	from (Categories c LEFT join Products p
	on c.CategoryID = p.CategoryID)	
	WHERE p.ProductID is NULL
-- 5.Podaj nazwy produktów, które nie mają przypisanej kategorii (z wykorzystaniem JOIN'a) 
	select ProductName
	from (Categories c right join Products p
	on c.CategoryID = p.CategoryID)
	WHERE c.CategoryID is nULL
-- 6.Podaj nazwy produktów, które nie mają przypisanej kategorii (bez wykorzystania JOIN'a) 
	SELECT ProductName
	FROM Products
	WHERE CategoryID is nULL
-- 7. Podaj nazwę produktu, jego cenę i nazwę kategorii z tabel Products i Categories.
	-- chcemy wyświetlić tylko produkty bez kategorii oraz kategorie bez produktów
	SELECT C.CategoryName, P.UnitPrice, P.ProductName 
	FROM Categories as C FULL JOIN Products as P
	ON C.CategoryID = P.CategoryID
	WHERE  P.CategoryID  is nULL
	

-- 8. Z tabeli Employees podaj nazwisko pracownika i nazwisko jego szefa (wykorzystać pole ReportsTo) - zależności służbowe
	SELECT e.LastName as 'full name worker',S.LastName as 'boss name' 
	FROM Employees as e JOIN Employees as S
	ON e.ReportsTo = S.EmployeeID
-- 9. Z tabeli Employees podaj nazwiska wszystkich pracowników i nazwisko ich szefa (wykorzystać pole ReportsTo) - zależności służbowe
	SELECT e.LastName as 'full name worker',S.LastName as 'boss name' 
	FROM Employees as e JOIN Employees as S
	ON e.ReportsTo = S.EmployeeID
	
-- 10. Podaj nazwiska pracowników, którzy nie mają szefa
	SELECT LastName
	FROM Employees
	WHERE ReportsTo is null
-- 11. Podaj nazwę klienta i nazwy produktów, które kupował (bez powtórzeń) 
	--dla konkretnego jednego klienta o nazwie 'Wolski  Zajazd' (zapytanie powinno zwrócić kilka rekordów)
	SELECT DISTINCT C.CompanyName as 'full name', P.ProductName
	FROM Customers as C JOIN Orders as O
	ON C.CustomerID = O.CustomerID
	JOIN [Order Details] as OD
	ON O.OrderID = OD.OrderID
	JOIN Products as P 
	ON P.ProductID = OD.ProductID
	WHERE C.CompanyName  Like 'Wolski  Zajazd'
	
-- 12. Podaj nazwę dostwacy(Suppliers) i nazwę spedytorów (Shippers), którzy dostarczają produkty danego dostwcy. Podaj także kraj pochodzenia dostwacy 
	SELECT DISTINCT  S.CompanyName, Sh.CompanyName, S.Country
	FROM Suppliers as S JOIN Products as P
	ON S.SupplierID = P.SupplierID
	JOIN [Order Details] as OD
	ON OD.ProductID = P.ProductID
	JOIN Orders as O 
	ON O.OrderID = OD.OrderID
	JOIN Shippers as Sh
	ON Sh.ShipperID =O.ShipVia
	

-- 13. Podaj numer zamówienia i nazwę towarów sprzedanych na kazdym z nich, w jakiej ilości i po jakiej cenie
	SELECT OD.OrderID, P.ProductName, P.UnitPrice, P.QuantityPerUnit
	FROM Products as P JOIN [Order Details] as OD
	ON P.ProductID = OD.ProductID
-- 14. Podaj nazwisko pracowników, którzy nie są jednocześnie szefami dla innych pracowników (można pominąć to zapytanie)
	-- (może być kłopot z tym zapytaniem bez wykorzystania zapytania z podzapytaniem)
	
	
	--------UGRYZ TO ---

-- 15. Znaleźć pracowników, którzy mają szefa jako samego siebie (dodaj pracownika, który ma szefa jako siebie samego) bez klauzli WHERE
	SELECT S.LastName + E.FirstName 
	FROM Employees as E JOIN Employees as S
	ON S.ReportsTo = E.EmployeeID 
-- 16. Czy są kategorie w których produkty nie były ani razu sprzedane (lub produkty niesprzedane ale bez kategorii)

-----------------------------------------------------------------
-- Operacje na zbiorach (union , union all, intersect, except) --
-----------------------------------------------------------------
	select ProductName, UnitPrice, CategoryName
	from (Categories c full join Products p
	on c.CategoryID = p.CategoryID)
	except
	select ProductName, UnitPrice, CategoryName
	from (Categories c inner join Products p
	on c.CategoryID = p.CategoryID)
-- 17. -- Dodaj trzy zestawy danych i posortuj względem nazwy. Kolumny wynikowe powinny się nazywać 'Name', 'Country', 'Type'
-- pierwszy zbiór - Zawiera nazwę dostawcy, kraj z którego pochodzi oraz informację w kolumnie trzeciej w postaci stringu 'Supplier'
-- drugi zbiór - Zawiera nazwę klienta, kraj z którego pochodzi oraz informację w kolumnie trzeciej w postaci stringu 'Customer' 
-- trzeci zbiór - Zawiera nazwisko pracownika, kraj z którego pochodzi oraz informację w kolumnie trzeciej w postaci stringu 'Employee' 
	SELECT CompanyName, Country, 'Supplier'
	FROM Suppliers
	union
	SELECT CompanyName, Country, 'Customer'
	FROM Customers
	union
	SELECT LastName, Country, 'Employee'
	FROM Employees
-- 18. Sprawdź czy są klienci, którzy są zarazem dostawcami (dodaj odpowiednie rekordy, które zwrócą wynik zapytania z danymi)
	SELECT CompanyName
	FROM Customers
	intersect
	SELECT CompanyName
	FROM Suppliers
	--nie ma
-- 19. Podaj tylko nazwy krajów dostawców i klientów z powtórzeniami
	SELECT Country
	FROM Customers
	union all
	SELECT Country
	FROM Suppliers
	except
	SELECT Country
	FROM Customers
	union 
	SELECT Country
	FROM Suppliers
-- 20. Czy są dostawcy z krajów, w których nie ma klientów w danej bazie danych (podać tylko nazwę kraju)
	SELECT Country
	FROM Suppliers
	except
	SELECT Country
	FROM Customers
-- 21. Czy są klienci z krajów, w których nie ma dostawców w danej bazie danych (podać tylko nazwę kraju)
	SELECT Country
	FROM Customers
	except
	SELECT Country
	FROM Suppliers
	
-----------------------------
-- Funkcje związaną z datą --
-----------------------------

--22. Podaj aktualną datę systemową
	SELECT GetDate()
--23. Jak dodać jedną godzinę do daty systemowej (bez korzystania z żadnych funkcji)
	SELECT GetDate() +1.0/24
--24. Podaj z daty systemowej osobno rok, miesiąc i dzień podany jako typ integer (YEAR, MONTH, DAY)
	SELECT YEAR(Getdate()) as 'YEAR'
	SELECT MONTH(Getdate()) as 'MONTH'
	SELECT DAY(Getdate()) as 'DAY'
--25. Podaj z daty systemowej osobno rok, miesiąc i dzień podany jako typ integer (funkcja DATEPART)
SELECT DATEPART(YEAR, GetDATE())
SELECT DATEPART(MONTH, GetDATE())
SELECT DATEPART(DAY, GetDATE())
--26. Podaj z daty systemowej osobno godzinę, miinuty i sekundy jako typ integer (funkcja DATEPART)
	SELECT DATEPART(HOUR, GETDATE())
	SELECT DATEPART(MINUTE, GETDATE())
	SELECT DATEPART(SECOND, GETDATE())
--27. Podaj z daty systemowej osobno rok, miesiąc i dzień podany jako typ char (funkcja DATENAME)
	SELECT DATENAME(YEAR, '2024/03/27') as rok
	SELECT DATENAME(MONTH, '2024/03/27') as miesiac
	SELECT DATENAME(DAY, '2024/03/27') as dzien
--28. Podaj nazwę aktualnego miesiąca podanego jako nazwa oraz dzień w postaci nazwy (kwiecień, poniedziałek) oraz (april, monday)
   select @@LANGUAGE
  	SELECT DATENAME(MONTH, '2024/03/27') as miesiac
	SELECT DATENAME(DW, '2024/03/27') as dzien
	set language POLISH
	SELECT DATENAME(MONTH, '2024/03/27') as miesiac
	SELECT DATENAME(DW, '2024/03/27') as dzien
   
--29. Ile lat upłyneło od ostatniego zamówienia (funkcja DATEDIFF)	
	SELECT DATEDIFF(YEAR, (SELECT TOP  1  ShippedDate from ORDERS ORDER BY ShippedDate desc), GETDATE())
--30. Ile miesięcy upłyneło od ostatniego zamówienia (funkcja DATEDIFF)
	SELECT DATEDIFF(MONTH, (SELECT TOP  1  ShippedDate from ORDERS ORDER BY ShippedDate desc), GETDATE())
--31. Dodaj do bieżącej daty 3 miesiące (funkcja DATEADD)
	SELECT DATEADD(MONTH, 3, GETDATE())
--32. W jaki dzień obchodzimy w tym roku urodziny (korzystamy z funkcji CONVERT do zamiany naszej daty tekstowej na typ DATETIME lub DATE)
	SELECT(DATENAME(DW,(SELECT CONVERT(datetime, '2024-03-10'))))
--33. W jaki dzień tygodnia przypada w przyszłym roku w ostatni dzień lutego oraz ile dni ma luty w przyszłym roku 
   --(korzystamy z funkcji CONVERT do zamiany naszej daty tekstowej na typ datetime bez korzystania z funkcji EOMONTH()
   --a następnie z korzystamy z funkcji EOMONTH())
  SELECT(DATENAME(DW,(SELECT CONVERT(datetime, '2025-28-02'))))
 SELECT(DATENAME(DW,(SELECT EOMONTH('2025-02-01'))))
  SELECT(DATENAME(DAY,(SELECT EOMONTH('2025-02-01'))))
--34. W jakich kolejnych latach była realizowana sprzedaż w bazie NORTHWIND
(SELECT ShippedDate
FROM Orders
WHERE ShippedDate is not NULL)
--????
	
-------------------------------
-- Zadania dodatkowe - różne --
-------------------------------
-- 35. Znaleźć produkty wycofane ze sprzedaży.
	SELECT ProductName 
	FROM Products
	WHERE Discontinued = 1
-- 36. Znaleźć produkty i określ ich stan magazynowy (wykorzystać składnię case), 
	SELECT	ProductName, UnitsInStock,
	CASE
		WHEN UnitsInStock = 0 THEN 'brak produktu'
		WHEN UnitsInStock BETWEEN 0 AND 10 THEN 'produkt nalezy zamowic'
		WHEN UnitsInStock BETWEEN 10 AND 20 THEN 'produkt w magazynie końcówka'
		ELSE 'OK'
		END
	FROM Products
	-- =0 'brak produktu'
	-- >0 and <= 10 'produkt należy zamówić'
	-- >10 and <= 20 'produkt w magazynie końcówka'
	-- >20 'OK'
-- 37. Czy istnieją produkty, które są aktualnie sprzedawane, dla których stan magazynu + zamówiony towar < Poziomu minimalnego
	SELECT ProductName
	FROM Products
	WHERE UnitsInStock + UnitsOnOrder < ReorderLevel

-- 38. Czy towary wycofne ze sprzedaży znajdują się w magazynie
	SELECT ProductName
	FROM Products
	WHERE Discontinued = 1 AND UnitsInStock <> 0
-- 39. Podać nazwę pracownika i regiony, w których realizuje sprzedaż (podajemy oprócz nazwy regionu także numer regionu)
	SELECT E.FirstName + E.LastName, R.RegionDescription , R.RegionID
	FROM Employees as E JOIN EmployeeTerritories AS ET
	ON e.EmployeeID = ET.EmployeeID
	JOIN Territories as T 
	On T.TerritoryID = ET.TerritoryID
	JOIN Region as R
	On r.RegionID = T.RegionID
-- 40. Czy są produkty, których cena sprzedaży nie zmieniła się w trakcie funkcjonowania firmy

-------------------------------------------------------------------------------------------------------------------------------------------
-- Kolejność join'ów typu outer w zapytaniu ma znaczenie przy zapytaniach ze sprzeżeniami zewnętrznymi, gdy jest więcej niż dwie tabele
-- (z poprzednich ćwiczeń mamy przynajmniej jedną kategorię i produkt nie powiązany ze sobą oraz produkt bez dostawcy)
-- sprawdzić ilość zwracanych rekordów i dane które są zwracane

-- 41. Podaj nazwę kategorii, nazwę produktu oraz nazwę firmy dostawcy 
	-- (chcemy, aby były widziane wszystkie nazwy kategorii nawet te, które nie mają przypisanego żadnego produktu)
		SELECT p.ProductName, S.CompanyName, C.CategoryName
	FROM Products p JOIN Suppliers S
	ON p.SupplierID = S.SupplierID
	Right JOIN Categories C
	ON C.CategoryID = p.CategoryID
-- 42. Podaj nazwę kategorii, nazwę produktu oraz nazwę firmy dostawcy 
	-- (chcemy, aby były widziane wszystkie nazwy produktów nawet te, które nie mają przypisanego żadnej kategorii, 
	-- nie wyświetlamy produktów bez nazwy dostawcy)
	SELECT p.ProductName, S.CompanyName, C.CategoryName
	FROM Products p JOIN Suppliers S
	ON p.SupplierID = S.SupplierID
	LEFT JOIN Categories C
	ON C.CategoryID = p.CategoryID
	
