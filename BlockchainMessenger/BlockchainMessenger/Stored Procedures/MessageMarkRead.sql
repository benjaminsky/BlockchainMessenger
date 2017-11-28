CREATE PROCEDURE [dbo].[MessageMarkRead]
	@MessageID INT
AS
SET XACT_ABORT ON
SET NOCOUNT ON

DECLARE @TransactionHash BINARY(32) 
	,@HashVersion INT = 1 --Just hardcoding for now...
	,@ReadDateTime DATETIMEOFFSET(2) = SYSDATETIMEOFFSET()
	
/* Compute hash */
SET @TransactionHash = dbo.MessageReadComputeHash(
	@MessageID
	,@ReadDateTime
	,@HashVersion)

BEGIN TRAN
	/* INSERT/UPDATE */
	UPDATE [Message]
	SET ReadDateTime = @ReadDateTime
	WHERE MessageID = @MessageID
	
	INSERT INTO dbo.[Transaction] (TransactionTypeID, MessageID,TransactionHash,HashVersion, TransactionDateTime)
	VALUES (2,@MessageID,@TransactionHash,@HashVersion, @ReadDateTime)
COMMIT
