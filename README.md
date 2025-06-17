# Deadlock
Checked kit for deadlock, set the trap (creating our deadlock), DEADLOCK Detective camera session (Extended Events), Excute the codes (running deadlock situation), Deadlocked Cracked(xml report analyze)


PART 1 : THE DEADLOCK - creating our own deadlock

Step 1: Create the Extended Events Session
This T-SQL script creates a new XEvents session named DeadlockDetectiveSession. It will start automatically with the server and store its data in a file.

Step 2: Reproduce a Deadlock
To test our session, we need to cause a deadlock. We will do this by updating two tables, in a conflicting order from two different sessions.
Open a NEW Query Window in SSMS (this is Session 1)
Open a SECOND Query Window in SSMS (this is Session 2)

Execution Order:
In Session 1, highlight and execute the first code block (the BEGIN TRANSACTION and the UPDATE Production.Product).
Immediately switch to Session 2 and execute its first code block .
Switch back to Session 1 and execute its second code block. You will see it is Executing query... but appears to hang. This is expected. It's now waiting for Session 2 to release its lock on the WorkOrder table.
Switch back to Session 2 and execute its second code block.

Result: After a few seconds, one of your sessions (most likely Session 1) will fail with the following error, indicating it was chosen as the deadlock victim.


PART 2 : DETECTIVE WORK - Finding the Evidence
The error message tells us what happened, but not why. To find the root cause, we use the system_health Extended Events session, which is running by default on modern SQL Server instances.

In SSMS Object Explorer, navigate to Management -> Extended Events -> Sessions.
Expand system_health and right-click on package0.event_file. Select View Target Data....
A new window will open with a stream of system events. We need to filter this to find our deadlock. 
In the filter dialog, set the following condition:
Field: name
Operator: Equals
Value: xml_deadlock_report
The list will now only show deadlock events. Click on the most recent one.
In the details pane at the bottom, you'll see a deadlock tab with a graphical representation of the deadlock.

How to Read the Deadlock Graph:
Ovals are the processes (our two sessions). The process with the "X" through it is the victim.
Rectangles are the resources being locked (e.g., a KEY lock on the Product or WorkOrder table).
Arrows show the dependency:
An arrow from a resource to a process means "this process owns a lock on this resource."
An arrow from a process to a resource means "this process is waiting for a lock on this resource."
By following the arrows, you can clearly see the circular wait: Session 1 owns a lock on Product and is waiting for WorkOrder, while Session 2 owns a lock on WorkOrder and is waiting for Product.
(Personally I had to make a .xdl file to repersent out graph)

PART 3 : THE SOLUTION - fixing the code

-- FIXED SESSION 2: Accessing tables in the same order as Session 1.

BEGIN TRANSACTION;

-- Step 1: Lock the Product table first.
PRINT 'Fixed Session 2: Attempting to update Product table...';
UPDATE Production.Product
SET ReorderPoint = 
WHERE ProductID = ;
PRINT 'Fixed Session 2: Product table update complete.';

-- Step 2: Now lock the WorkOrder table.
PRINT 'Fixed Session 2: Attempting to update WorkOrder table...';
UPDATE Production.WorkOrder
SET DueDate = 
WHERE ProductID = ;
PRINT 'Fixed Session 2: WorkOrder table update complete.';

COMMIT TRANSACTION;

PRINT 'Fixed Session 2: Transaction committed.';

(MY GIVEN DELAY TIME WAS 00:00:05 )


💡 Key Takeaways
*Deadlocks occur when two or more processes have a circular dependency on locked resources.
*You can reliably reproduce deadlocks for testing by using multiple sessions and controlling the execution order of UPDATE or DELETE statements within transactions.
*The system_health Extended Events session is your primary tool for investigating deadlocks post-mortem.
*The deadlock graph provides an invaluable visual representation of the conflict.
*The most common prevention strategy is to enforce a consistent resource access order across all applications and processes
