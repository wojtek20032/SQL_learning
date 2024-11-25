Use Northwind
--------------------------------------
-- Polecenia INSERT, UPDATE, DELETE --
--------------------------------------

-- Przygotowujemy dane (mogą być nowe dane z poprzednich zajęć)
select * from Categories; 
delete Products where ProductID>=78;
delete Categories where CategoryID >= 9;

-- 1. Wstawiamy nową kategorię o nazwie 'Kat 1' (tylko jedna kolumna jedna podawana) 
	INSERT INTO Categories(CategoryName)
	VALUES('Kat 1')
-- 2. Wstawiamy dwie nowe kategorie o nazwie 'Kat 2' i 'Kat 3' jednym poleceniem INSERT
	INSERT INTO Categories(CategoryName)
	VALUES('Kat 2'),( 'Kat 3')
-- 3. Wstawiamy nową kategorię o nazwie 'Kat 4' łącznie z polem Description 'Opis 4' 
	INSERT INTO Categories(CategoryName, [Description])
	VALUES('Kat 4', 'Opis 4')
-- 4. Wstawiamy nową kategorię o nazwie 'Kat 5' łącznie z polem Description z wartością NULL
	INSERT INTO Categories(CategoryName, [Description])
	VALUES('Kat 5', NULL)
-- 5. Kasujemy rekord gdzie  CategoryName = 'Kat 5' i CategoryID >= 9
	DELETE Categories
	WHERE CategoryName = 'Kat 5' AND CategoryID >=9
-- 6. Modyfikujemy wszystkie kategorie zaczynające się na słowo 'Kat' i ustawiamy aby ich nowa nazwa była pisana dużymi literami oraz Description było wartością NULL
	UPDATE Categories
	SET CategoryName = UPPER(CategoryName), [Description] = NULL
	WHERE CategoryName LIKE 'Kat%'

-- 7. Zmodyfikuj kategorię aby była pisana małymi literami (klauzula WHERE zawiera konkretny numer kategorii)
	UPDATE Categories
	SET CategoryName = LOWER(CategoryName)
	WHERE CategoryID = 9
-- 8. Skasuj daną kategorię (klauzula WHERE zawiera konkretny numer kategorii)
	DELETE Categories
	WHERE CategoryID = 9
--------------------
-- Łączenie tabel --
--------------------

-- 9. Podaj nazwę produktu, jego cenę, numer kategorii i nazwę kategorii z tabel Products i Categories 
	-- (wykorzystujemy klauzulę WHERE)
	SELECT ProductName, UnitPrice, C.CategoryID, CategoryName FROM Products as P, Categories as C
	Where C.CategoryID = P.CategoryID
	
	
--10. Podaj nazwę produktu, jego cenę, numer kategorii i nazwę kategorii z tabel Products i Categories (wykorzystujemy klauzulę WHERE)
	-- dla produktów z categoryid >= 8
	SELECT ProductName, UnitPrice, C.CategoryID, CategoryName FROM Products as P, Categories as C
	Where C.CategoryID = P.CategoryID AND C.CategoryID >=8
--11. Podaj nazwę produktu, jego cenę i nazwę kategorii z tabel Products i Categories (wykorzystujemy klauzulę JOIN ... ON)
	-- dla produktów z categoryid >= 8 oraz posortować malejąco po cenie
	SELECT ProductName, UnitPrice, C.CategoryID, CategoryName 
	FROM Products as P JOIN Categories as C
	ON C.CategoryID = P.CategoryID
	Where  C.CategoryID >=8
	ORDER BY UnitPrice desc
--12.Podaj nazwę produktu, jego cenę i nazwę firmy dostawcy (wykorzystujemy klauzulę INNER JOIN ... ON)
	SELECT ProductName, UnitPrice, CompanyName
	FROM Products as P JOIN Suppliers as S
	ON P.SupplierID = S.SupplierID
	
--13.Podaj nazwę produktu, jego cenę i nazwę dostawcy z tabel Products i Suppliers (wykorzystujemy klauzulę INNER JOIN ... ON)
	-- dla produktów z categoryid >= 8 oraz posortować malejąco po cenie
	SELECT ProductName, UnitPrice, CompanyName
	FROM Products as P JOIN Suppliers as S
	ON P.SupplierID = S.SupplierID
	WHERE P.CategoryID >=8
	ORDER BY UnitPrice desc
--14.Podaj nazwę produktu, jego cenę, nazwę firmy dostawcy i nazwę kategorii do której należy.
	SELECT ProductName, UnitPrice,S.CompanyName, CategoryName 
	FROM Products as P JOIN Categories as C
	ON C.CategoryID = P.CategoryID
	JOIN Suppliers as S
	ON s.SupplierID = P.SupplierID
--15.Dana firma w jakiej kategorii dostarcza produkty (posortować po nazwie firmy i nazwie kategorii)
	SELECT CompanyName, S.SupplierID,  C.CategoryName
	FROM Suppliers as S JOIN Products as P
	ON S.SupplierID = P.SupplierID
	JOIN Categories as C
	ON P.CategoryID = C.CategoryID
	ORDER BY CompanyName, C.CategoryName

--16.Podaj nazwę klienta, datę zamówienia i nazwę pracownika, który go obsługiwał.
SELECT C.ContactName, O.OrderDate, E.FirstName + E.LastName as Employee
FROM Customers as C JOIN Orders as O
ON C.CustomerID = O.CustomerID
JOIN Employees as E
ON E.EmployeeID = O.EmployeeID

--17.Podaj nazwę klienta i nazwy kategorii, w których klient kupował produkty (bez powtórzeń)
SELECT DISTINCT Ca.CategoryName, C.ContactName
FROM Customers as C JOIN Orders as O
ON C.CustomerID = O.CustomerID
JOIN [Order Details] as OD
ON OD.OrderID = O.OrderID
JOIN Products as P
ON P.ProductID = OD.ProductID
JOIN Categories as Ca
ON Ca.CategoryID = P.CategoryID
--18.Podaj numer zamówienia, nazwę produktu i jego cenę na zamówieniu oraz upust.
SELECT OD.OrderID, P.ProductID, OD.UnitPrice, OD.Discount
FROM [Order Details] as OD JOIN Products as P
ON OD.ProductID = P.ProductID


----------------
-- Transakcje --
----------------

----------------------------------------------------------------------------------------------------------------------------
-- Przykład 1. wycofanie transakcji (dla spradzenia działania wykonujemy każde polecenie po kolei)--
----------------------------------------------------------------------------------------------------------------------------
-- po każdym z poleceń można wykonać polecenie - select @@trancount lub print @@trancount --
--------------------------------------------------------------------------------------------
begin tran
	insert  into Categories (CategoryName) values ('Kat t1'),('Kat t2');
	-- Sprawdzamy czy faktycznnie operacja została wykonana czy wycofana
	select * from Categories where CategoryName like 'Kat%'
-- wycofujemy transkacje
rollback tran 
-- Sprawdzamy czy faktycznnie operacja została wykonana czy wycofana
select * from Categories where CategoryName like 'Kat%'
----------------------------------------------------------------------------------------------------------------------------
-- Przykład 2. zatwierdzenie transakcji (dla spradzenia działania wykonujemy każde polecenie po kolei)--
begin tran
	insert  into Categories (CategoryName) values ('Kat t1'),('Kat t2');
	-- Sprawdzamy czy faktycznnie operacja została wykonana czy wycofana
	select * from Categories where CategoryName like 'Kat%'
-- zatwierdzamy transkacje
commit tran 
-- Sprawdzamy czy faktycznnie operacja została wykonana czy wycofana
select * from Categories where CategoryName like 'Kat%'
----------------------------------------------------------------------------------------------------------------------------

--19. Sprawdzić i podać jaki jest ustawiony poziom izolacji transakcji i jak zmienić aktualny poziom. 
	-- Jaki jest aktualny czas oczekwiania na zwolnienie blokady. 
	dbcc useroptions
--20. Otworzyć dwa okna i zaobserwować w drugim okienku blokowanie czytanych danych 
	-- przy nie zakończonej transakcji z pierwszego okienka na danej tabeli np. categories
	-- Jak ustawić czas blokady na 5 sekund po czym zwrócony zostanie komunikat o błędzie (w okienku gdzie czytamy dane).
		--terminal 1
dbcc useroptions
begin tran
	insert  into Categories (CategoryName) values ('Kat t1'),('Kat t2');

	select * from Categories where CategoryName like 'Kat%'
--3
rollback tran 
--terminal 2
dbcc useroptions
--2
select * from Categories 
where CategoryName like 'Kat%'
--21. j.w. tylko w drugim okienku ustawić poziom izolacji transakcji jako 'set transaction isolation level read uncommitted' 
    -- i czytamy dane z tabeli categories (jaka jest różnica?) 
--terminal 1
	dbcc useroptions

begin tran
	insert  into Categories (CategoryName) values ('Kat t1'),('Kat t2');
	select * from Categories where CategoryName like 'Kat%'
--3
rollback tran 

--terminal 2
	dbcc useroptions
	set lock_timeout -1
	set transaction isolation level read uncommitted
	--2
		select * from Categories where CategoryName like 'Kat%'
--22. Dodać nową kategorię o nazwie 'Kategoria 1' a następnie dodać produkt o nazwie 'Produkt 1' należący do kategorii 'Kategoria 1' 
	-- (nie znamy categoryid danej kategorii)(pamiętajmy iż niektóre pola w tabeli są wymagane do wstawienia rekordu)

--23. Dodać produkt 'Produkt 2' do kategorii o numerze 2000 
	-- (jak wynik zapytania podać wygenerowany błąd i poniżej odpowiedzieć na pytanie dlaczego ten błąd wystąpił i co maiało na to wpływ)
		INSERT INTO Products(ProductName ,CategoryID)
		VALUES ('Produkt 2', 2000)
		--Msg 547, Level 16, State 0, Line 178 The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Products_Categories". The conflict occurred in database "Northwind", table "dbo.Categories", column 'CategoryID'.
		--naruszony zostal klucz obcy(wymagane jest aby id_cateogyr istniala w bazie?)
 
--24. Jakie niekorzystne zjawiska występują przy każdym z poziomów izolacji transakcji 
	-- (zakładamy pesymistyczny model współbieżności). 
	-- Dla każdego z poziomów izolacji zdefiniować przykład ilustrujący wystąpienie nieporządanych zjawisk.
	-- a. Tracona modyfikacja (lost updates) (nie może nigdy wystąpić)
	-- b. Odczyt niezatwierdzonych danych (dirty reads)- read uncommitted (przykład pokazany w pkt 21.)
	-- c. Niepowtarzalny odczyt (nonrepeatable reads)
	-- d. Fantomy (phantoms)
	
--25. Zasymulować zakleszczenie (deadlock) - jaki jest czas oczekiwania na rozwiązanie procesu zakleszczenia (czy można zmienić ten czas)
	-- Jaki numer błędu jest zwracany przez system po wycofaniu transakcji związanej z zakleszczeniem.
	--1
set transaction isolation level read committed
BEGIN TRAN
INSERT INTO Categories (CategoryName)
    VALUES('Katy 1')
--3
SELECT * FROM Products

COMMIT TRAN 
--terminal 2
--2
USE Northwind
dbcc useroptions
set transaction isolation level read committed

BEGIN TRAN
INSERT INTO Products(ProductName)
    VALUES('Katy 1')
--4
SELECT * FROM Categories

COMMIT TRAN