--terminal 1
dbcc useroptions
--1
begin tran
	insert  into Categories (CategoryName) values ('Kat t1'),('Kat t2');

	select * from Categories where CategoryName like 'Kat%'
--3
rollback tran 