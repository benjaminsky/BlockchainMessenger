/* delete all data */
EXEC [dbo].[StartFromScratch]

/* create users */
DECLARE @UserID INT
EXEC @UserID = [dbo].[UserAdd] 'Bob'
EXEC @UserID = [dbo].[UserAdd] 'Alice'


/* create message */
DECLARE @MessageID INT
EXEC @MessageID = [dbo].[MessageAdd] 1000,1001,'Hey','Hey Alice! How are you?'
WAITFOR DELAY '00:00:00.300'
EXEC MessageMarkRead @MessageID = 10000
WAITFOR DELAY '00:00:00.300'
EXEC @MessageID = [dbo].[MessageAdd] 1001,1000,'RE: Hey','Hey Bob! I''m doing great!'
WAITFOR DELAY '00:00:00.300'
EXEC MessageMarkRead @MessageID = 10001
WAITFOR DELAY '00:00:00.300'
EXEC @MessageID = [dbo].[MessageAdd] 1000,1001,'RE: RE: Hey','Would you like me to update the schema docs?'
WAITFOR DELAY '00:00:00.300'
EXEC MessageMarkRead @MessageID = 10002
WAITFOR DELAY '00:00:00.300'
EXEC @MessageID = [dbo].[MessageAdd] 1001,1000,'RE: RE: RE: Hey','Please!'
WAITFOR DELAY '00:00:00.300'
EXEC MessageMarkUnread @MessageID = 10002
WAITFOR DELAY '00:00:00.300'
EXEC MessageMarkRead @MessageID = 10003
WAITFOR DELAY '00:00:00.300'


EXEC BlockAdd
EXEC BlockMine 0x07

/* create messages */
EXEC  [dbo].[MessageAdd] 1000,1001,'Hey','Hey Alice! How are you?'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1000,1001,'Hey','Hey Alice! How are you?'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1000,1001,'Hey','Hey Alice! How are you?'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1000,1001,'Hey','Hey Alice! How are you?'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1000,1001,'Hey','Hey Alice! How are you?'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1000,1001,'Hey','Hey Alice! How are you?'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1000,1001,'Hey','Hey Alice! How are you?'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1000,1001,'Hey','Ooof, sorry for the spam. I accidentally kept sending that...'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1001,1000,'RE: Hey','Not a problem Bob. I''ve just added you to my junk mail list ;)'

EXEC BlockAdd
EXEC BlockMine 0x07


EXEC  [dbo].[MessageAdd] 1000,1001,'Followup','Schema docs have been updated.'
WAITFOR DELAY '00:00:00.300'
EXEC  [dbo].[MessageAdd] 1001,1000,'RE: Followup','Thanks! Enjoy your weekend.'
WAITFOR DELAY '00:00:00.300'

EXEC BlockAdd
EXEC BlockMine 0x06

EXEC  [dbo].[MessageAdd] 1000,1001,'Test','This will be a single message block'

EXEC BlockAdd
EXEC BlockMine 0x07

DECLARE @i INT = 0
SET NOCOUNT ON
SET XACT_ABORT ON
begin tran
	while @i < 50000
	begin
		SET @i = @i + 1
		DECLARE @Body VARCHAR(1000) = 'There will be a ton of messages on this block and this is number ' + CAST(@i AS VARCHAR(11))
		EXEC [dbo].[MessageAdd] 1000,1001,'Test', @Body
	end
commit
SET NOCOUNT OFF

EXEC BlockAdd
EXEC BlockMine 0x07

--Mess with something...
UPDATE [Message]
set Body = 'This has been tampered with...'
where MessageID = 10006

EXEC TransactionVerify 20001
EXEC TransactionVerify 20011 --MessageID = 10006
EXEC TransactionVerify 999999

/* Script to verify random 100 transactions
SELECT 'DECLARE @Verifications TABLE (TransactionID INT,IsValid BIT, [Exists] BIT)'
UNION ALL
select * from (
	select top 100 Script = 'INSERT INTO @Verifications EXEC TransactionVerify ' + CAST(TransactionID as varchar(11)) from [Transaction]
	ORDER BY NEWID()
) i
UNION ALL
SELECT 'SELECT * FROM @Verifications'
--*/


select * from [User]
select * from [Message]
select * from [Transaction]
SELECT * FROM [Block]
select * from MerkleTreeIntermediateNode
