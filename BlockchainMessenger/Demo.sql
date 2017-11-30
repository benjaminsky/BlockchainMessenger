/* clear */
EXEC StartFromScratch

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
EXEC @MessageID = [dbo].[MessageAdd] 1001,1000,'RE: RE: RE: Hey','Please!'
WAITFOR DELAY '00:00:00.300'

select * from [User]
select * from [Message]

/* Verify */
select MessageID
	,ComputedMessageHash = [dbo].[MessageComputeHash](MessageID,FromUSerID,ToUserID,[Subject],Body, PrevMessageHash,HashVersion)
	,MessageHash
From [Message]
