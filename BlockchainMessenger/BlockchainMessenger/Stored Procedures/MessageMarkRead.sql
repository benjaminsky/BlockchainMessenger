CREATE PROCEDURE [dbo].[MessageMarkRead]
	@MessageID INT
AS
UPDATE [Message]
SET ReadDateTime = SYSDATETIMEOFFSET()
WHERE MessageID = @MessageID