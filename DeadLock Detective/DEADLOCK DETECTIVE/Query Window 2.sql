USE AdventureWorks2022;

--2nd person

GO
BEGIN TRANSACTION;

--Using red pen

UPDATE Production.Product
SET NAME = 'HL Road Pedal - Red'
WHERE ProductID = 711;

--wait for deadlock happen

WAITFOR DELAY '00:00:05';

--need blue pen but 2nd person has it 

UPDATE Production.Product
SET NAME = 'HL Mountain Pedal - BlUE'
WHERE ProductID = 710;

COMMIT TRANSACTION;
GO

--WHAT HAPPENED ?
--Query 1 locks product 710, then tries to get product 711.
--Query 2 locks product 711, then tries to get product 710.
--Both stuck (here is our DEADLOCK ) waiting for each other.
