CREATE PROCEDURE [dbo].[TransactionCreateMerkleTree]
	@BlockID int
	,@MerkleRoot BINARY(32) OUTPUT
AS
SET NOCOUNT ON

DECLARE @HashVersion INT = 1 --Just hardcoding for now...

DECLARE @MerkleNodes TABLE(ID INT IDENTITY(1,1) PRIMARY KEY, Depth INT,NodeHash BINARY(32))	
INSERT INTO @MerkleNodes (Depth,NodeHash)
SELECT 0,TransactionHash
FROM dbo.[Transaction]
WHERE BlockID = @BlockID


DECLARE @RC INT = 99999 --Arbitrary > 2 value	
WHILE @RC > 1
BEGIN
	INSERT INTO @MerkleNodes (Depth,NodeHash)
	select t1.Depth + 1,HASHBYTES('SHA2_256',t1.NodeHash + ISNULL(t2.NodeHash,t1.NodeHash))
	from @MerkleNodes t1
	OUTER APPLY (
		SELECT TOP 1 NodeHash
		FROM @MerkleNodes t2
		WHERE t2.ID > t1.ID
	) t2
	WHERE t1.ID % 2 = (SELECT MAX(ID) % 2 FROM @MerkleNodes)
		AND Depth = (SELECT MAX(Depth) FROM @MerkleNodes)

	SET @RC = @@ROWCOUNT
END


DECLARE @MerkleRootID INT
SELECT TOP 1 @MerkleRootID = ID, @MerkleRoot = NodeHash
FROM @MerkleNodes
ORDER BY ID DESC

INSERT INTO dbo.[Transaction] (TransactionTypeID,TransactionHash, TransactionDateTime, BlockID, HashVersion)
SELECT 4,NodeHash, SYSDATETIMEOFFSET(), @BlockID, @HashVersion
FROM @MerkleNodes
WHERE Depth >= 1 --Ditch the original transactions
	AND ID <> @MerkleRootID