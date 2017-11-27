/****************
I know scalar functions are generally poor performers in SQL Server. For this demo they make readability better
*****************/
CREATE FUNCTION [dbo].[MessageReadComputeHash]
(
	@MessageID INT
	,@TransactionDateTime DATETIMEOFFSET(2)
	,@PrevMessageHash BINARY(32)
	,@HashVersion INT
)
RETURNS BINARY(32)
AS
BEGIN
	DECLARE @Delimiter NVARCHAR(10) = N'<bcfield>'
	RETURN CAST(
			CASE @HashVersion
				WHEN 1 THEN
					HASHBYTES('SHA2_256',
					CAST(@MessageID AS NVARCHAR(10))
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(30),@TransactionDateTime,121),'')
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(66),@PrevMessageHash,1),'')
					)
			END 
		as BINARY(32))
END