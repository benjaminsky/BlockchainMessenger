CREATE PROCEDURE [dbo].[BlockMine]
AS
DECLARE @BlockID INT
	, @PrevBlockID INT
	, @TransactionCount INT
	, @PrevBlockSignature VARBINARY(256)
	, @CreatedDateTime DATETIMEOFFSET(2)
	, @MerkleRoot BINARY(32)

SELECT TOP 1 @BlockID = BlockID
	, @PrevBlockID = PrevBlockID
	, @TransactionCount = TransactionCount
	, @PrevBlockSignature = PrevBlockSignature
	, @CreatedDateTime = CreatedDateTime
	, @MerkleRoot = MerkleRoot
FROM dbo.[Block] b
WHERE BlockSignature IS NULL

DECLARE @Signature VARBINARY(256) = 0xFFFF
	, @Nonce INT = 0

WHILE CAST(LEFT(@Signature,2) AS BINARY(2)) > 0x000F
BEGIN
	SET @Signature = [dbo].[BlockComputeSignature] (@BlockID, @PrevBlockID, @TransactionCount, @Nonce, @MerkleRoot, @PrevBlockSignature, @CreatedDateTime, 1)
	SET @Nonce = CAST(CRYPT_GEN_RANDOM(4) as INT)
END

UPDATE dbo.[Block]
SET	[BlockSignature] = @Signature
	,Nonce = @Nonce
WHERE BlockID = @BlockID