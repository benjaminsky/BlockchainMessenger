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

DECLARE @Signature VARBINARY(256) = 0xFF
	, @Nonce INT = 0

WHILE CAST(LEFT(@Signature,1) AS BINARY(1)) <> 0x00
BEGIN
	SET @Signature = [dbo].[BlockComputeSignature] (@BlockID, @PrevBlockID, @TransactionCount, @Nonce, @MerkleRoot, @PrevBlockSignature, @CreatedDateTime, 1)
	SET @Nonce = @Nonce + 1
END

UPDATE dbo.[Block]
SET	[BlockSignature] = @Signature
	,Nonce = @Nonce
WHERE BlockID = @BlockID