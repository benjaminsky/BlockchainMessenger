/****************
I know scalar functions are generally poor performers in SQL Server. For this demo they make readability better
*****************/
CREATE FUNCTION [dbo].BlockVerifySignature
(
	@BlockID INT
	,@PrevBlockID INT
	,@TransactionCount INT
	,@Nonce INT
	,@MerkleRoot BINARY(32)
	,@PrevBlockSignature VARBINARY(256)
	,@CreatedDateTime DATETIMEOFFSET(2)
	,@SignatureVersion INT
	,@SignatureToVerify VARBINARY(256)
)
RETURNS BIT
AS
BEGIN
	RETURN CAST(
		VerifySignedByCert(Cert_Id('BlockChainCert'),
			dbo.BlockPlaintextForSignature(
				@BlockID
				,@PrevBlockID
				,@TransactionCount
				,@Nonce
				,@MerkleRoot
				,@PrevBlockSignature
				,@CreatedDateTime
				,@SignatureVersion)
			,@SignatureToVerify
		) AS BIT)
END