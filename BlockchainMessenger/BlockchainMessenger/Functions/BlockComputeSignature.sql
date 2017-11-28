/****************
I know scalar functions are generally poor performers in SQL Server. For this demo they make readability better
*****************/
CREATE FUNCTION [dbo].[BlockComputeSignature]
(
	@BlockID INT
	,@PrevBlockID INT
	,@TransactionCount INT
	,@Nonce INT
	,@Difficulty VARBINARY(4)
	,@MerkleRoot BINARY(32)
	,@PrevBlockSignature VARBINARY(256)
	,@CreatedDateTime DATETIMEOFFSET(2)
	,@SignatureVersion INT
)
RETURNS VARBINARY(256)
AS
BEGIN
	RETURN CAST(	
		SignByCert(Cert_Id('BlockChainCert'),
			dbo.BlockPlaintextForSignature(
				@BlockID
				,@PrevBlockID
				,@TransactionCount
				,@Nonce
				,@Difficulty
				,@MerkleRoot
				,@PrevBlockSignature
				,@CreatedDateTime
				,@SignatureVersion
			)
		)
		as VARBINARY(256))
END