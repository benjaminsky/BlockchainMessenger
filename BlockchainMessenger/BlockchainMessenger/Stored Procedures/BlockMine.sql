CREATE PROCEDURE [dbo].[BlockMine] (
	@Difficulty VARBINARY(3) = 0xFFFFFF --Defaults to minimum difficulty. Well not exactly, the true minimum would be the max VARBINARY(256) which would be 514 bytes long but I only allow 3 bytes since nonce is 4. Nevertheless the odds of having to run the signature loop more than once with this difficulty setting is approx. 1 in 16 million. There's a possibility that a nonce doesn't exist to satisfy the difficulty value that gets statistically more likely as you set this value lower. There's a 1 in 256 chance that 0x000001 difficulty will not have a valid nonce. If you want that high of difficulty expand the nonce's datatype.  
)
AS
IF @Difficulty = 0x00
	RAISERROR('Difficulty must be greater than zero!',16,1)
ELSE
BEGIN
	DECLARE @BlockID INT
		, @PrevBlockID INT
		, @TransactionCount INT
		, @PrevBlockSignature VARBINARY(256)
		, @CreatedDateTime DATETIMEOFFSET(2)
		, @MerkleRoot BINARY(32)
		, @Signature VARBINARY(256) = 0xFFFFFFFF
		, @Nonce INT = 0

	SELECT @BlockID = BlockID
		, @PrevBlockID = PrevBlockID
		, @TransactionCount = TransactionCount
		, @PrevBlockSignature = PrevBlockSignature
		, @CreatedDateTime = CreatedDateTime
		, @MerkleRoot = MerkleRoot
	FROM dbo.[Block] b
	WHERE BlockSignature IS NULL --There can only be one of these

	WHILE @Signature > @Difficulty
	BEGIN
		SET @Nonce = CAST(CRYPT_GEN_RANDOM(4) as INT)
		SET @Signature = [dbo].[BlockComputeSignature] (@BlockID, @PrevBlockID, @TransactionCount, @Nonce, @Difficulty, @MerkleRoot, @PrevBlockSignature, @CreatedDateTime, 1)
	END

	UPDATE dbo.[Block]
	SET	[BlockSignature] = @Signature
		,Nonce = @Nonce
		,Difficulty = @Difficulty
	WHERE BlockID = @BlockID
END