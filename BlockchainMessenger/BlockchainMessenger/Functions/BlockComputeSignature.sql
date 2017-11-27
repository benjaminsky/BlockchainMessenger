/****************
I know scalar functions are generally poor performers in SQL Server. For this demo they make readability better
*****************/
CREATE FUNCTION [dbo].[BlockComputeSignature]
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
RETURNS VARBINARY(256)
AS
BEGIN
	DECLARE @Delimiter NVARCHAR(10) = N'<bcfield>'
	RETURN CAST(
			CASE @SignatureVersion
				WHEN 1 THEN
					SignByCert(Cert_Id('BlockChainCert'),
					CAST(@BlockID AS NVARCHAR(10))
					+ @Delimiter + ISNULL(CAST(@PrevBlockID AS NVARCHAR(10)),N'')
					+ @Delimiter + CAST(@TransactionCount AS NVARCHAR(10))
					+ @Delimiter + CAST(@Nonce AS NVARCHAR(10))
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(66),@MerkleRoot,1),N'')
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(514),@PrevBlockSignature,1),N'')
					+ @Delimiter + ISNULL(CONVERT(NVARCHAR(30),@CreatedDateTime,121),N'')
					)
			END 
		as VARBINARY(256))
END