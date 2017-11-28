CREATE PROCEDURE [dbo].[MessageAdd]
	@FromUserID INT
	,@ToUserID INT
	,@Subject NVARCHAR(100)
	,@Body NVARCHAR(1000)
	,@MessageID INT = NULL
AS
SET XACT_ABORT ON
DECLARE @InternalMessageID INT
	, @TransactionHash BINARY(32) 
	,@HashVersion INT = 1 --Just hardcoding for now...
	,@TransactionDateTime DATETIMEOFFSET(2) = SYSDATETIMEOFFSET()

/* Allow either passing in @MessageID or grabbing next from sequence */
IF @MessageID IS NULL
	SET @InternalMessageID = NEXT VALUE FOR dbo.MessageID
ELSE
	SET @InternalMessageID = @MessageID

/* get hash */
SET @TransactionHash = dbo.MessageComputeHash(
	@InternalMessageID
	,@FromUserID
	,@ToUserID
	,@Subject
	,@Body
	,@TransactionDateTime
	,@HashVersion)

BEGIN TRAN
	/* INSERT */
	INSERT INTO dbo.[Message] (MessageID, ToUserID,FromUserID, [Subject], Body)
	VALUES (@InternalMessageID, @ToUserID,@FromUserID,@Subject, @Body)

	INSERT INTO dbo.[Transaction] (TransactionTypeID, MessageID,TransactionHash, HashVersion, TransactionDateTime)
	VALUES (1,@InternalMessageID,@TransactionHash, @HashVersion, @TransactionDateTime)
COMMIT

RETURN @InternalMessageID