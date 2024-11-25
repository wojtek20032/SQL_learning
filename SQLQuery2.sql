--terminal 2
dbcc useroptions
--2
set lock_timeout -1
set transaction isolation level read uncommitted
select * from Categories 
where CategoryName like 'Kat%'