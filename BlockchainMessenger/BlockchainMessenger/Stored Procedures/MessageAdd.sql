CREATE PROCEDURE [dbo].[MessageAdd]
	@FromUserID INT
	,@ToUserID INT
	,@Subject NVARCHAR(100)
	,@Body NVARCHAR(1000)
	,@MessageID INT = NULL
AS
SET XACT_ABORT ON

/* Allow either passing in @MessageID or grabbing next from sequence */
DECLARE @InternalMessageID INT

IF @MessageID IS NULL
	SET @InternalMessageID = NEXT VALUE FOR dbo.MessageID
ELSE
	SET @InternalMessageID = @MessageID

/* Hash section */
DECLARE @TransactionHash BINARY(32) 
	,@PrevTransactionID INT
	,@PrevTransactionHash BINARY(32)
	,@HashVersion INT = 2 --Just hardcoding for now...
	,@TransactionDateTime DATETIMEOFFSET(2) = SYSDATETIMEOFFSET()

BEGIN TRAN
	SELECT TOP 1
		 @PrevTransactionID = TransactionID
		 ,@PrevTransactionHash = TransactionHash
	FROM dbo.[Transaction]
	ORDER BY TransactionID DESC

	SET @TransactionHash = dbo.MessageComputeHash(
		@InternalMessageID
		,@FromUserID
		,@ToUserID
		,@Subject
		,@Body
		,@TransactionDateTime
		,@PrevTransactionHash
		,@HashVersion)

	/* INSERT and RETURN */
	INSERT INTO dbo.[Message] (MessageID, ToUserID,FromUserID, [Subject], Body)
	VALUES (@InternalMessageID, @ToUserID,@FromUserID,@Subject, @Body)

	INSERT INTO dbo.[Transaction] (TransactionTypeID, MessageID,TransactionHash,HashVersion,PrevTransactionID,PrevTransactionHash, TransactionDateTime)
	VALUES (1,@InternalMessageID,@TransactionHash,@HashVersion,@PrevTransactionID, @PrevTransactionHash, @TransactionDateTime)
COMMIT

RETURN @InternalMessageID