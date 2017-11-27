CREATE PROCEDURE [dbo].[TransactionCreateMerkleTree]
	@BlockID int
	,@MerkleRoot BINARY(32) OUTPUT
AS
SET NOCOUNT ON
DECLARE @HashVersion INT = 1 --Just hardcoding for now...

--This table will hold all MerkleNodes but first we prepop it with just the leaves
DECLARE @MerkleNodes TABLE(RN INT IDENTITY(1,1) PRIMARY KEY, ID INT, Depth TINYINT,NodeHash BINARY(32), HashID1 INT, HashID2 INT, BlockID INT)	
INSERT INTO @MerkleNodes (Depth, NodeHash, ID, BlockID)
SELECT 0,TransactionHash,TransactionID, BlockID
FROM dbo.[Transaction]
WHERE BlockID = @BlockID


--Walk down the tree populating @MerkleNodes one depth at a time until we've written the root
DECLARE @RC INT
WHILE @RC > 1 or @RC IS NULL
BEGIN
	INSERT INTO @MerkleNodes (ID,Depth,NodeHash,HashID1,HashID2, BlockID)
	SELECT NEXT VALUE FOR [dbo].[MerkleTreeIntermediateNodeID]
		, t1.Depth + 1
		, HASHBYTES('SHA2_256',t1.NodeHash + ISNULL(t2.NodeHash,t1.NodeHash))
		, t1.ID
		, ISNULL(t2.ID,t1.ID)
		, t1.BlockID
	FROM @MerkleNodes t1
	OUTER APPLY (
		SELECT TOP 1 NodeHash,ID
		FROM @MerkleNodes t2
		WHERE t2.RN > t1.RN
	) t2
	CROSS APPLY (
		SELECT TOP 1 MIN(RN) as MinRN,Depth
		FROM @MerkleNodes
	    GROUP BY Depth
		ORDER BY Depth DESC
	) maxd
	WHERE t1.RN % 2 = maxd.MinRN % 2
		AND t1.Depth = maxd.Depth

	SET @RC = @@ROWCOUNT
END

--Populate our output variable
SELECT TOP 1 
	@MerkleRoot = NodeHash
FROM @MerkleNodes
ORDER BY RN DESC

--Populate physical table
INSERT INTO dbo.MerkleTreeIntermediateNode ([MerkleTreeIntermediateNodeID],TransactionID1,TransactionID2,MerkleTreeIntermediateNodeID1,MerkleTreeIntermediateNodeID2,Depth,NodeHash, BlockID)
SELECT ID
	, CASE WHEN Depth = 1 THEN HashID1 END
	, CASE WHEN Depth = 1 THEN HashID2 END
	, CASE WHEN Depth > 1 THEN HashID1 END
	, CASE WHEN Depth > 1 THEN HashID2 END
	, Depth
	, NodeHash
	, BlockID
FROM @MerkleNodes
WHERE Depth >= 1 --Ditch the original transactions
ORDER BY RN --Order matters when going to the Transaction table. We're using the PK order to determine position in the merkle tree during verification. In the IntermediateNode table order doesn't matter but also doesn't hurt.