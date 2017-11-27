/****************
I know scalar functions are generally poor performers in SQL Server. For this demo they make readability better
*****************/
CREATE FUNCTION [dbo].BlockPlaintextForSignature
(
	@BlockID INT
	,@PrevBlockID INT
	,@TransactionCount INT
	,@Nonce INT
	,@MerkleRoot BINARY(32)
	,@PrevBlockSignature VARBINARY(256)
	,@CreatedDateTime DATETIMEOFFSET(2)
	,@SignatureVersion INT
)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @Delimiter NVARCHAR(10) = N'<bcfield>'
	RETURN 
			CASE @SignatureVersion
				WHEN 1 THEN
					CAST(@BlockID AS NVARCHAR(11))
					+ @Delimiter + ISNULL(CAST(@PrevBlockID AS NVARCHAR(11)),N'')
					+ @Delimiter + CAST(@TransactionCount AS NVARCHAR(11))
					+ @Delimiter + CAST(@Nonce AS NVARCHAR(11))
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(66),@MerkleRoot,1),N'')
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(514),@PrevBlockSignature,1),N'')
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(30),@CreatedDateTime,121),N'')
			END 

END