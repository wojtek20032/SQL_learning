USE NORTHWIND
--1. Wyświetlamy nazwę dostawcy i numer faksu (nie wyświetlamy firm bez numeru faksu (wartość NULL))
select  CompanyName, Fax
from Suppliers 
Where fax is not null
--2. Wyświetlamy nazwę dostawcy i numer faksu (wyświetlamy firmy bez numeru faksu (wartość NULL))
select  CompanyName, Fax
from Suppliers 
Where fax is null
--3. Wyświetlamy nazwę dostawcy i numer faksu. Jeśli numeru faksu nie ma to powinna pojawić się nazwa 'Brak faksu'. 
	-- Korzystamy z funkcji ISNULL (sprawdzamy w dokumentacji)
	Select  CompanyName, ISNULL(Fax, 'Brak faksu')
	from Suppliers
--4. Wyświetlamy nazwę dostawcy, numer faksu, coutry i city, który znajduje się w 'USA' lub 'France' lub w mieście 'London'
SELECT CompanyName, Fax, Country, City
From Suppliers
Where Country = 'USA' OR Country = 'France' OR Country = 'London'
--5. Wyświetlamy nazwę dostawcy, numer faksu, coutry i city, który znajduje się w 'USA', 'France' lub 'Poland' (korzystamy z operatora logicznego IN)
SELECT CompanyName, Fax, Country, City
FROM Suppliers
Where Country  IN ('USA', 'France', 'Poland')
--6. Wyświetlamy nazwę dostawcy, numer faksu, coutry i city, który nie znajduje się w 'USA', 'France' lub 'Poland' (korzystamy z operatora logicznego NOT IN)
SELECT CompanyName, Fax, Country, City
FROM Suppliers
Where Country NOT IN ('USA', 'France', 'Poland')
--7. Wyświetlamy produkty, których cena jest z zakresu od 50 do 100 łącznie z tymi punktami (korzystamy z operatora AND OR NOT >= <= > <)
	SELECT ProductName
	FROM Products
	WHERE UnitPrice <= 100 AND UnitPrice >=50
--8. Wyświetlamy produkty, których cena jest z zakresu do 50 i od 100 bez tych punktów (korzystamy z operatora AND OR NOT >= <= > <)
	SELECT ProductName
	FROM Products
	WHERE UnitPrice < 100 AND UnitPrice >50
--9. Wyświetlamy produkty, których cena jest z zakresu od 50 do 100 łącznie z tymi punktami (korzystamy z operatora BETWEEN AND)
	SELECT ProductName
	FROM Products
	WHERE UnitPrice BETWEEN 50 AND 100
--10. Wyświetlamy produkty, których cena jest z zakresu do 50 i od 100 bez tych punktów (korzystamy z operatora NOT BETWEEN AND)
	SELECT ProductName, UnitPrice
	FROM Products
	WHERE UnitPrice NOT BETWEEN 50 AND 100 AND UnitPrice NOT IN (50,100)
--11. Wyświetlamy produkty, których cena jest z zakresu <20;80) bez punktów {30;40;50;60} - korzystamy tylko z operatorów BETWEEN AND, IN, NOT, AND, OR
	-- Negacja to operatory != <> NOT
	SELECT ProductName
	FROM Products
	WHERE (UnitPrice >=20 AND UnitPrice <80) AND (UnitPrice NOT IN (30,40,50,60))
--12. Znaleźć produkty o nazwie z zakresu od litery a do litery c (stosujemy operator between i funkcję substring - sprawdzamy w dokumentacji)
SELECT ProductName
FROM Products
WHERE SUBSTRING(ProductName,1,1) BETWEEN 'a' AND 'c'
--13. Znaleźć produkty z zakresu od a do c (korzystamy z klauzuli LIKE - sprawdzamy w dokumentacji)
SELECT ProductName
FROM Products
WHERE ProductName LIKE '[a-c]%'
--14. Znaleźć produkty, które zaczynają się na literę a (korzystamy z klauzuli LIKE)
SELECT ProductName
FROM Products
WHERE ProductName LIKE 'a%'
--15. Znaleźć produkty kończące się na literę s (gdzie korzystamy klauzula LIKE)
SELECT ProductName
FROM Products
WHERE ProductName LIKE '%s'
--16. Znaleźć produkty, które w nazwie mają literę a,g,k na miejscu drugim (LIKE)
SELECT ProductName
FROM Products
WHERE SUBSTRING(ProductName, 2,2) LIKE '[agk]%'
--17. Znaleźć produkty, które w środku nazwy (bez pierwszej i ostatniej litery) mają conajmniej jedną literę 'a' (LIKE)
SELECT ProductName
FROM Products
WHERE ProductName LIKE '_%[a]%_'
--18. Znaleźć kategorie, które w kolumnie Description tabeli Categories znajduje się znak %. 
	-- Należy wcześniej wykonać polecenie: 
	-- update Categories set Description = CONCAT(Description,'100%') where CategoryID=8
update Categories set Description = CONCAT(Description,'100%') where CategoryID=8
SELECT CategoryName
FROM Categories
WHERE [Description] LIKE '%[%]%'
--19. Znaleźć produkty nie zaczynające się na litery A, C, G (LIKE)
SELECT ProductName 
FROM Products
WHERE ProductName LIKE '[^Acg]%'
--20. Znaleźć produkty, które zawierają ' (apostrof) (LIKE)
 SELECT ProductName
FROM Products
WHERE ProductName LIKE '%''%'

--21. Znaleźć produkty kończące sie na znaki 'up' (2 znaki)
SELECT ProductName
FROM Products
WHERE ProductName LIKE '%up'
--22. Znaleźć produkty, które w nazwie na miejscu dwudziestym miejscu ma literę S, gdzie długość stringu jest >= 20 znaków (LEN)
SELECT ProductName
FROM Products
WHERE LEN(ProductName) >= 20 AND SUBSTRING(ProductName,20,20) = 's'
--23. Znaleźć produkty zaczynające się na litery od A do S, których cena jest z zakres 15 do 120, które należą do kategorii 1,3,6. 
SELECT ProductName
FROM Products
WHERE UnitPrice <=120 AND UnitPrice >=15 AND ProductName LIKE '[A-S]%' AND CategoryID IN (1,3,6)
--24. Znaleźć produkty, które w nazwie mają słowo New.
SELECT ProductName
FROM Products
WHERE ProductName LIKE '%New%'

--25. Łaczymy Imię, nazwisko i numer pracownika (Employees) w jeden string i wyświetlamy jedną kolumnę.
	--a. wykorzystujemy funkcję CAST (sprawdzamy w dokumentacji)
	SELECT FirstName +' '+ LastName+' ' + CAST(EmployeeID as  varchar) as 'RES'
	FROM Employees 
	
	--b. wykorzystujemy funkcję CONVERT (sprawdzamy w dokumentacji)
	SELECT FirstName +' '+ LastName+' ' + CONVERT(varchar, EmployeeID) as 'RES'
	FROM Employees
	--c. wykorzystujemy funkcję CONCAT (sprawdzamy w dokumentacji)
	SELECT CONCAT(FirstName,' ', LastName,' ', EmployeeID) as 'RES'
	FROM Employees
--26. Nie modyfikując ustawień bazy danych dodajemy rekordy do tabeli Shippers poleceniem
	INSERT INTO Shippers (CompanyName) values ('speedy express'),('SPeedy express'),('speedy expresS');
-- naszym zadaniem jest wybranie nazw firm, której nazwa zaczyna się na małą i dużą literę s
-- oraz w następnym zapytaniu tylko na małą literę s (operujemy w języku polskim - porównujemy w języku polskim)
SELECT CompanyName
FROM Shippers
WHERE LEFT(CompanyName,1) = 's'

SELECT CompanyName
FROM Shippers
WHERE LEFT(CompanyName, 1) = 's' COLLATE Latin1_General_BIN;

--27. Posortuj wszystkie rekordy z tabeli Shippers względem kolumny CompanyName uwzględniając małe i duże litery 
	-- w odpowiediej kolejności (najpierw małe później duże litery)
SELECT CompanyName
FROM Shippers
ORDER BY CompanyName COLLATE Latin1_General_CI_AI;

--28. Wyświetlamy nazwę dostawcy, numer faksu, coutry i city, który znajduje się 
-- w 'USA' lub 'UK'i w mieście zaczynającym się 'L' (wielkość liter nie ma znaczenia oraz nie stosujemy IN, BETWEEN)
SELECT CompanyName, Fax, Country, City
FROM Suppliers
WHERE (Country = 'USA' OR Country ='UK') AND LEFT(City,1) = 'L'