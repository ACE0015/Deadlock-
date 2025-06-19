# 🕵️‍♂️ Deadlock Detective: A SQL Server Investigation
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

**PART 2: Setting the Trap - Creating the Deadlock**
> 
*📸 Step 1: Create the Extended Events Session*
* This T-SQL script creates a new XEvents session named DeadlockDetectiveSession. It will start automatically with the server and capture any deadlock reports to a file.
Generated sql
* -- Create a dedicated session to capture ONLY deadlock reports
* CREATE EVENT SESSION [DeadlockDetectiveSession] ON SERVER
* ADD EVENT sqlserver.xml_deadlock_report
* ADD TARGET package0.event_file
>(we can use *WITH* statement as per the instruction needed)

*💥 Step 2: Reproduce the Deadlock*
* Now, we'll cause the deadlock by updating a table (Production.Product) in a conflicting order from two different sessions. (we can also join other table on our need by using *JOIN*)
* Opened a NEW Query Window in SSMS (Session 1).
* Open a SECOND Query Window in SSMS (Session 2).
* Execution: The timing and order of these steps are critical. Also run time between should be specific.
* 🕙(In Our Query delay time is 00:00:05)
>*Result: After a few seconds (the deadlock monitor runs every 5 seconds), one session will fail. It has been chosen as the deadlock victim.

**PART 3: The Investigation - Capturing the Evidence**
* The error confirms a deadlock, but the deadlock report contains the crucial evidence we need to understand why.
* In SSMS Object Explorer, navigate to Management -> Extended Events -> Sessions.
* Expanding our DeadlockDetectiveSession (or system_health) and right-click package0.event_file. Select View Target Data....
* Click on the deadlock event in the top pane. In the details pane below, select the Deadlock tab.
* This shows the graphical representation of the deadlock.
> Some cases won't show our graph like in my case so we can use '.xdl' case here & also the '.xdl file' can be opened in SSMS anytime.

**PART 4: Deadlock Graph - Analyzing our report**
* 🔵 Ovals (Processes): These are our two sessions. The one with the "X" is the deadlock victim.
* 📦 Rectangles (Resources): These are the database objects being locked (e.g., a KEY lock on an index).
* ➡️ Arrows (Dependencies):
   > * An arrow from a process to a resource means: "This process is waiting to acquire a lock on this resource."
   > * An arrow from a resource to a process means: "This process owns a lock on this resource."

**PART 5: Cracking the Case - The Solution**
>The investigation clearly shows the problem: the two processes lock the same tables but in a different order. The most common solution is to enforce a consistent resource access order.

* -- FIXED SESSION 2: Accessing tables in the same order as Session 1.

BEGIN TRANSACTION;

-- Step 1: Lock the Product Table First.
PRINT 'Fixed Session 2: Attempting to update Product table...';
UPDATE Production.Product
SET  =
WHERE ProductID = 711;
PRINT 'Fixed Session 2: Product table update complete.';

-- Step 2: Table Second.
PRINT 'Fixed Session 2: Attempting to update WorkOrder table...';
UPDATE Production.Product
SET  = 
WHERE ProductID = 710;
PRINT 'Fixed Session 2: Product table update complete.';

COMMIT TRANSACTION;
PRINT 'Fixed Session 2: Transaction committed.';

* With this change, a deadlock will no longer occur. Case closed.
# 💡 Key Takeaways
* Deadlocks occur when two or more processes have a circular dependency on locked resources.
* You can reliably reproduce deadlocks by using multiple sessions and controlling the execution order of statements within transactions.
* The xml_deadlock_report from Extended Events is your primary tool for investigating deadlocks.
* The deadlock graph provides an invaluable visual representation of the conflict.
* The most common prevention strategy is to enforce a consistent resource access order across all processes.
