/****************
I know scalar functions are generally poor performers in SQL Server. For this demo they make readability better
*****************/
CREATE FUNCTION [dbo].[MessageComputeHash]
(
	@MessageID INT
	,@FromUserID INT
	,@ToUserID INT
	,@Subject NVARCHAR(100)
	,@Body NVARCHAR(1000)
	,@TransactionDateTime DATETIMEOFFSET(2)
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
					+ @Delimiter + CAST(@FromUserID AS NVARCHAR(10))
					+ @Delimiter + CAST(@ToUserID AS NVARCHAR(10))
					+ @Delimiter + REPLACE(@Subject,@Delimiter,N'')
					+ @Delimiter + REPLACE(@Body,@Delimiter,N'')
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(30),@TransactionDateTime,121),N'')
					)
			END 
		as BINARY(32))
END