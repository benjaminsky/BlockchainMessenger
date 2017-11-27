/* clear */
DELETE [Transaction]
DELETE [Message]
DELETE [User]

ALTER SEQUENCE dbo.MessageID RESTART
ALTER SEQUENCE dbo.UserID RESTART
ALTER SEQUENCE dbo.TransactionID RESTART


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

select * from [User]
select * from [Message]
select * from [Transaction]

SELECT HASHBYTES('SHA2_256',N'10000<bcfield>2017-11-26 17:24:01.40 -08:00<bcfield>2017-11-26 17:24:01.40 -08:00<bcfield>0x412632EA5D535712AD71648EB5048ED6A882819D428F59AF7957422CD469C854')
