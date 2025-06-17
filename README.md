### 🕵️‍♂️ Deadlock Detective: A SQL Server Investigation
>This repository is a hands-on lab where you'll become a master detective in the world of SQL Server concurrency.

*🗺️ Our Investigation Workflow:*
* 🛠️ Check the Kit ➡️ 
* 💣 Set the Trap ➡️ 
* 📸 Capture the Evidence ➡️ 
* 📈 Analyze the Report ➡️ 
* ✅ Crack the Case ➡️


**PART 1: OUR KIT**
> * Installation Check of SSMS21 (0r2016+)
> * Database Check (In this case we are using adventworks22)

**PART 2: 💣 Setting the Trap - Creating the Deadlock**
>📸 Step 1: Create the Extended Events Session
This T-SQL script creates a new XEvents session named DeadlockDetectiveSession. It will start automatically with the server and capture any deadlock reports to a file.
Generated sql
-- Create a dedicated session to capture ONLY deadlock reports
CREATE EVENT SESSION [DeadlockDetectiveSession] ON SERVER
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file
>(we can use with statement as per the instruction needed)

-- Start the session
ALTER EVENT SESSION [DeadlockDetectiveSession] ON SERVER STATE = START;
GO
Use code with caution.
SQL
[!NOTE]
If you prefer not to create a new session, you can use the default system_health session which also captures deadlocks.
💥 Step 2: Reproduce the Deadlock
Now, we'll cause the deadlock by updating two tables (Product and WorkOrder) in a conflicting order from two different sessions.
Open a NEW Query Window in SSMS (Session 1).
Open a SECOND Query Window in SSMS (Session 2).
Execution Order:
[!WARNING]
The timing and order of these steps are critical. Follow them precisely.
In Session 1, highlight and execute the first code block (the BEGIN TRANSACTION and the UPDATE Production.Product).
Immediately switch to Session 2 and execute its first code block.
Switch back to Session 1 and execute its second code block. It will appear to hang while Executing query.... This is expected; it's now waiting for Session 2.
Switch back to Session 2 and execute its second code block. This completes the deadly embrace.
Result:
After a few seconds (the deadlock monitor runs every 5 seconds), one session will fail. It has been chosen as the deadlock victim.
Msg 1205, Level 13, State 51, Line X
Transaction (Process ID XX) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.
Part 2: 🔎 The Investigation - Finding the Evidence
The error confirms a deadlock, but the deadlock report contains the crucial evidence we need to understand why.
In SSMS Object Explorer, navigate to Management -> Extended Events -> Sessions.
Expand your DeadlockDetectiveSession (or system_health) and right-click package0.event_file. Select View Target Data....
Click on the deadlock event in the top pane. In the details pane below, select the Deadlock tab.
This shows the graphical representation of the deadlock.
How to Read the Deadlock Graph:
🔵 Ovals (Processes): These are our two sessions. The one with the "X" is the deadlock victim.
📦 Rectangles (Resources): These are the database objects being locked (e.g., a KEY lock on an index).
➡️ Arrows (Dependencies):
An arrow from a resource to a process means: "This process owns a lock on this resource."
An arrow from a process to a resource means: "This process is waiting to acquire a lock on this resource."
[!TIP]
Save the Evidence!
You can save the deadlock graph for later analysis. Right-click in the deadlock graph view and select Export to -> .xdl File. This .xdl file can be opened by SSMS at any time.
Part 3: 🔑 Cracking the Case - The Solution
The investigation clearly shows the problem: the two processes lock the same tables but in a different order. The most common solution is to enforce a consistent resource access order.
Here is the fixed code for Session 2, where we now access Product first, then WorkOrder, just like Session 1.
Generated sql
-- FIXED SESSION 2: Accessing tables in the same order as Session 1.

BEGIN TRANSACTION;

-- Step 1: Lock the Product table first.
PRINT 'Fixed Session 2: Attempting to update Product table...';
UPDATE Production.Product
SET ReorderPoint = ReorderPoint + 5
WHERE ProductID = 798;
PRINT 'Fixed Session 2: Product table update complete.';

-- Step 2: Now lock the WorkOrder table.
PRINT 'Fixed Session 2: Attempting to update WorkOrder table...';
UPDATE Production.WorkOrder
SET DueDate = DATEADD(day, 1, DueDate)
WHERE ProductID = 798;
PRINT 'Fixed Session 2: WorkOrder table update complete.';

COMMIT TRANSACTION;
PRINT 'Fixed Session 2: Transaction committed.';
Use code with caution.
SQL
With this change, a deadlock will no longer occur. Case closed.
💡 Key Takeaways
Deadlocks occur when two or more processes have a circular dependency on locked resources.
You can reliably reproduce deadlocks by using multiple sessions and controlling the execution order of statements within transactions.
The xml_deadlock_report from Extended Events is your primary tool for investigating deadlocks.
The deadlock graph provides an invaluable visual representation of the conflict.
The most common prevention strategy is to enforce a consistent resource access order across all processes.
