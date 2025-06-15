--Creating a scenario of 2 people - 2 pen for deadlock

USE AdventureWorks2022;

-- 1st person

GO
BEGIN TRANSACTION;

--using a blue pen

UPDATE Production.Product
SET NAME = 'HL Mountain Pedal - Blue'
WHERE
  ProductID = 710;

--wait for deadlock happen

WAITFOR DELAY '00:00:05';

--need red pen but 2nd person has it 

UPDATE Production.Product
SET NAME = 'HL ROAD PEDAL - Red'
WHERE 
  ProductID = 711;

COMMIT TRANSACTION;
GO
