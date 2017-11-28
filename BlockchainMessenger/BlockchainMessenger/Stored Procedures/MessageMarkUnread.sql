CREATE PROCEDURE [dbo].[MessageMarkUnread]
	@MessageID INT
AS
SET XACT_ABORT ON
SET NOCOUNT ON

DECLARE @TransactionHash BINARY(32) 
	,@HashVersion INT = 1 --Just hardcoding for now...
	,@TransactionDateTime DATETIMEOFFSET(2) = SYSDATETIMEOFFSET()

/* compute hash */
SET @TransactionHash = dbo.MessageReadComputeHash(
	@MessageID
	,@TransactionDateTime
	,@HashVersion)

BEGIN TRAN
	/* INSERT/UPDATE */
	UPDATE [Message]
	SET ReadDateTime = NULL
	WHERE MessageID = @MessageID

	INSERT INTO dbo.[Transaction] (TransactionTypeID, MessageID,TransactionHash,HashVersion, TransactionDateTime)
	VALUES (3,@MessageID,@TransactionHash,@HashVersion, @TransactionDateTime)
COMMIT
