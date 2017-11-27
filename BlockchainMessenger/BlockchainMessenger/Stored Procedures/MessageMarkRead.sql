CREATE PROCEDURE [dbo].[MessageMarkRead]
	@MessageID INT
AS
SET XACT_ABORT ON

/* Hash section */
DECLARE @TransactionHash BINARY(32) 
	,@PrevTransactionID INT
	,@PrevTransactionHash BINARY(32)
	,@HashVersion INT = 1 --Just hardcoding for now...
	,@ReadDateTime DATETIMEOFFSET(2) = SYSDATETIMEOFFSET()
	
BEGIN TRAN
	SELECT TOP 1
		 @PrevTransactionID = TransactionID
		 ,@PrevTransactionHash = TransactionHash
	FROM dbo.[Transaction]
	ORDER BY TransactionID DESC

	SET @TransactionHash = dbo.MessageReadComputeHash(
		@MessageID
		,@ReadDateTime
		,@HashVersion)

	/* INSERT/UPDATE */
	UPDATE [Message]
	SET ReadDateTime = @ReadDateTime
	WHERE MessageID = @MessageID
	
	INSERT INTO dbo.[Transaction] (TransactionTypeID, MessageID,TransactionHash,HashVersion, TransactionDateTime)
	VALUES (2,@MessageID,@TransactionHash,@HashVersion, @ReadDateTime)
COMMIT
