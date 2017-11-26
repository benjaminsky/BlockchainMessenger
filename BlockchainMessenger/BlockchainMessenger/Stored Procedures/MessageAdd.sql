CREATE PROCEDURE [dbo].[MessageAdd]
	@FromUserID INT
	,@ToUserID INT
	,@Subject NVARCHAR(100)
	,@Body NVARCHAR(1000)
	,@MessageID INT = NULL
AS
/* Allow either passing in @MessageID or grabbing next from sequence */
DECLARE @InternalMessageID INT

IF @MessageID IS NULL
	SET @InternalMessageID = NEXT VALUE FOR dbo.MessageID
ELSE
	SET @InternalMessageID = @MessageID

/* Hash section */
DECLARE @MessageHash BINARY(32) 
	,@PrevMessageID INT
	,@PrevMessageHash BINARY(32)
	,@HashVersion INT = 1 --Just hardcoding for now...

SELECT TOP 1
	 @PrevMessageID = MessageID
	 ,@PrevMessageHash = MessageHash
FROM dbo.[Message]
ORDER BY MessageID DESC

SET @MessageHash = dbo.MessageComputeHash(
	@InternalMessageID
	,@FromUserID
	,@ToUserID
	,@Subject
	,@Body
	,@PrevMessageHash
	,@HashVersion)

/* INSERT and RETURN */
INSERT INTO dbo.[Message] (MessageID, ToUserID,FromUserID, [Subject], Body, MessageHash, HashVersion, PrevMessageID, PrevMessageHash)
VALUES (@InternalMessageID, @ToUserID,@FromUserID,@Subject,@Body, @MessageHash, @HashVersion, @PrevMessageID, @PrevMessageHash)

RETURN @InternalMessageID