CREATE PROCEDURE [dbo].UserAdd
	@FullName varchar(200)
	,@UserID INT = NULL
AS
SET NOCOUNT ON

DECLARE @InternalUserID INT

--Allow either passing in a PK or generating the next one without relying on a default
IF @UserID IS NULL
	SET @InternalUserID = NEXT VALUE FOR dbo.UserID
ELSE
	SET @InternalUserID = @UserID


INSERT INTO dbo.[User] (UserID, FullName)
VALUES (@InternalUserID, @FullName)

RETURN @InternalUserID