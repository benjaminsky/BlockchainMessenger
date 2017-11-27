CREATE PROCEDURE [dbo].[BlockAdd]
AS
SET XACT_ABORT ON

DECLARE @BlockID INT = NEXT VALUE FOR dbo.BlockID
DECLARE @PrevBlockID INT 
	,@SignatureVersion INT = 1 --Just hardcoding for now...
	,@PrevBlockSignature VARBINARY(256)
	,@MerkleRoot BINARY(32)
	,@TransactionCount INT

IF EXISTS(SELECT * FROM dbo.[Transaction] WHERE BlockID IS NULL)
BEGIN
	BEGIN TRAN
		SELECT TOP 1
			 @PrevBlockID = BlockID
			 ,@PrevBlockSignature = BlockSignature
		FROM dbo.[Block]
		ORDER BY BlockID DESC

		INSERT INTO dbo.[Block] (BlockID, PrevBlockID, PrevBlockSignature, SignatureVersion)
		VALUES (@BlockID, @PrevBlockID, @PrevBlockSignature, @SignatureVersion)

		UPDATE dbo.[Transaction]
		SET BlockID = @BlockID
		WHERE BlockID IS NULL
	
		SET @TransactionCount = @@ROWCOUNT

		EXEC [dbo].[TransactionCreateMerkleTree] @BlockID, @MerkleRoot OUTPUT

		UPDATE dbo.[Block]
		SET MerkleRoot = @MerkleRoot
			,TransactionCount = @TransactionCount
		WHERE BlockID = @BlockID
	COMMIT
END
