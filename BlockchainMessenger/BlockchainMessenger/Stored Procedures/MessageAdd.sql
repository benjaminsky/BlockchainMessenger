CREATE PROCEDURE [dbo].[MessageAdd]
	@FromUserID INT
	,@ToUserID INT
	,@Subject NVARCHAR(100)
	,@Body NVARCHAR(1000)
	,@MessageID INT = NULL
AS
DECLARE @InternalMessageID INT

IF @MessageID IS NULL
	SET @InternalMessageID = NEXT VALUE FOR dbo.MessageID
ELSE
	SET @InternalMessageID = @MessageID


INSERT INTO dbo.[Message] (MessageID, ToUserID,FromUserID, [Subject], Body)
VALUES (@InternalMessageID, @ToUserID,@FromUserID,@Subject,@Body)

RETURN @InternalMessageID