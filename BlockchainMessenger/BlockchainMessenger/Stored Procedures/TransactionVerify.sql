CREATE PROCEDURE [dbo].[TransactionVerify]
(
	@TransactionID INT
)
AS
DECLARE @BlockID INT 
SELECT @BlockID = BlockID
FROM [Transaction] 
WHERE TransactionID = @TransactionID

DECLARE @ComputedMerkleRoot BINARY(32) 

;WITH CTENecessaryNodes as (
	--Sibling Transaction
	SELECT MerkleTreeIntermediateNodeID
		,MerkleTreeIntermediateNodeID1
		,MerkleTreeIntermediateNodeID2
		,TransactionID1
		,TransactionID2
		,CASE WHEN TransactionID1 = @TransactionID THEN 1 ELSE 2 END AS ComputeSide
		,NonComputeSideHash = t.TransactionHash
		,Depth
	FROM dbo.MerkleTreeIntermediateNode m
	JOIN dbo.[Transaction] t on t.TransactionID = CASE WHEN m.TransactionID1 = @TransactionID THEN m.TransactionID2 WHEN m.TransactionID2 = @TransactionID THEN m.TransactionID1 END
	WHERE m.BlockID = @BlockID

	UNION ALL

	--Walk down the tree
	SELECT m.MerkleTreeIntermediateNodeID
		,m.MerkleTreeIntermediateNodeID1
		,m.MerkleTreeIntermediateNodeID2
		,NULL
		,NULL
		,CASE WHEN m.MerkleTreeIntermediateNodeID1 = c.MerkleTreeIntermediateNodeID THEN 1 ELSE 2 END
		,NonComputeSideHash = mh.NodeHash
		,m.Depth
	FROM CTENecessaryNodes c
	JOIN dbo.MerkleTreeIntermediateNode m on m.MerkleTreeIntermediateNodeID1 = c.MerkleTreeIntermediateNodeID 
		or m.MerkleTreeIntermediateNodeID2 = c.MerkleTreeIntermediateNodeID
	JOIN dbo.MerkleTreeIntermediateNode mh 
		on mh.MerkleTreeIntermediateNodeID = CASE 
			WHEN m.MerkleTreeIntermediateNodeID1 = c.MerkleTreeIntermediateNodeID THEN m.MerkleTreeIntermediateNodeID2 
			ELSE m.MerkleTreeIntermediateNodeID1 
			END
	WHERE m.BlockID = @BlockID
		and mh.BlockID = @BlockID
)
, CTEComputedHashes as (
	--Compute Transaction Hash
	select c.MerkleTreeIntermediateNodeID
		,c.MerkleTreeIntermediateNodeID1
		,c.MerkleTreeIntermediateNodeID2
		,c.TransactionID1
		,c.TransactionID2
		,c.ComputeSide
		,c.NonComputeSideHash
		,c.Depth
		,ComputedHash = CAST(CASE 
			WHEN t.TransactionTypeID = 1 
				THEN dbo.MessageComputeHash(ms.MessageID,ms.FromUserID,ms.ToUserID,ms.Subject, ms.Body, t.TransactionDateTime, t.HashVersion) 
			WHEN t.TransactionTypeID in (2,3)
				THEN dbo.MessageReadComputeHash(ms.MessageID,t.TransactionDateTime,t.HashVersion)
		END AS BINARY(32))
	from CTENecessaryNodes c
	LEFT JOIN dbo.[Transaction] t on t.TransactionID = CASE WHEN TransactionID1 IS NOT NULL THEN CASE ComputeSide WHEN 1 THEN c.TransactionID1 ELSE c.TransactionID2 END END 
	LEFT JOIN dbo.[Message] ms on ms.MessageID = t.MessageID and t.TransactionID IS NOT NULL
	LEFT JOIN dbo.MerkleTreeIntermediateNode m 
		on m.MerkleTreeIntermediateNodeID = CASE WHEN c.MerkleTreeIntermediateNodeID1 IS NOT NULL THEN CASE ComputeSide WHEN 1 THEN c.MerkleTreeIntermediateNodeID1 ELSE c.MerkleTreeIntermediateNodeID2 END END
		and m.BlockID = @BlockID
	WHERE c.Depth = 1

	UNION ALL
	
	--Compute intermediate node hashes one level at a time recursively
	SELECT c.MerkleTreeIntermediateNodeID
		,c.MerkleTreeIntermediateNodeID1
		,c.MerkleTreeIntermediateNodeID2
		,c.TransactionID1
		,c.TransactionID2
		,c.ComputeSide
		,c.NonComputeSideHash
		,c.Depth
		,ComputedHash = CAST(HASHBYTES('SHA2_256',CASE ch.ComputeSide WHEN 1 THEN ch.ComputedHash + ch.NonComputeSideHash ELSE ch.NonComputeSideHash + ch.ComputedHash END) as BINARY(32))
	FROM CTEComputedHashes ch
	JOIN CTENecessaryNodes c on c.Depth = ch.Depth + 1
	WHERE ch.ComputedHash IS NOT NULL
)
--Compute MerkleRoot
SELECT TOP 1 @ComputedMerkleRoot = CAST(HASHBYTES('SHA2_256',CASE ComputeSide WHEN 1 THEN ComputedHash + NonComputeSideHash ELSE NonComputeSideHash + ComputedHash END) as BINARY(32)) 
FROM CTEComputedHashes h
ORDER BY h.MerkleTreeIntermediateNodeID DESC

SELECT IsInMerkleRoot = CASE WHEN @ComputedMerkleRoot = MerkleRoot THEN 'Yes' ELSE 'No' END
	,SignatureVerified = CASE 
		dbo.BlockVerifySignature(BlockID,PrevBlockID,TransactionCount,Nonce,b.MerkleRoot,PrevBlockSignature,CreatedDateTime,SignatureVersion,b.BlockSignature)
		WHEN 1 THEN 'Yes' ELSE 'No' END
FROM [Block] b
WHERE BlockID = @BlockID 