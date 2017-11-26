CREATE PROCEDURE [dbo].UserAdd
	@FullName varchar(200)
	,@UserID INT = NULL
AS
DECLARE @InternalUserID INT

IF @UserID IS NULL
	SET @InternalUserID = NEXT VALUE FOR dbo.UserID
ELSE
	SET @InternalUserID = @UserID

INSERT INTO dbo.[User] (UserID, FullName)
VALUES (@InternalUserID, @FullName)

RETURN @InternalUserID