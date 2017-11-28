CREATE PROCEDURE [dbo].[TransactionVerify]
(
	@TransactionID INT
)
AS
SET NOCOUNT ON

DECLARE @NextNodeID INT
	,@Hash1 BINARY(32)
	,@Hash2 BINARY(32)
	,@NodeHash BINARY(32)
	,@HashFailures INT = 0
	,@IsDone BIT = 0
	,@IsValid BIT = 0
	,@Exists BIT = 1

--Verify transaction and sibling transaction
;WITH CTEMessageHash as (
	select TransactionID
		,CAST(CASE 
				WHEN t.TransactionTypeID = 1 
					THEN dbo.MessageComputeHash(ms.MessageID,ms.FromUserID,ms.ToUserID,ms.[Subject], ms.Body, t.TransactionDateTime, t.HashVersion) 
				WHEN t.TransactionTypeID in (2,3)
					THEN dbo.MessageReadComputeHash(ms.MessageID,t.TransactionDateTime,t.HashVersion)
			END AS BINARY(32)) as ComputedHash
	FROM dbo.[Transaction] t 
	JOIN dbo.[Message] ms on ms.MessageID = t.MessageID
)
select @NextNodeID = MerkleTreeIntermediateNodeID
	,@Hash1 = CASE WHEN TransactionID1 = @TransactionID THEN (SELECT ComputedHash FROM CTEMessageHash WHERE TransactionID = @TransactionID) ELSE t1.TransactionHash END
	,@Hash2 = CASE WHEN TransactionID2 = @TransactionID THEN (SELECT ComputedHash FROM CTEMessageHash WHERE TransactionID = @TransactionID) ELSE t2.TransactionHash END
	,@NodeHash = n.NodeHash
from MerkleTreeIntermediateNode n
JOIN dbo.[Transaction] t1 on t1.TransactionID = TransactionID1
JOIN dbo.[Transaction] t2 on t2.TransactionID = TransactionID2
where TransactionID1 = @TransactionID or TransactionID2 = @TransactionID

IF @@ROWCOUNT = 0 SET @Exists = 0

IF @NodeHash <> HASHBYTES('SHA2_256',HASHBYTES('SHA2_256',@Hash1 + @Hash2)) SET @HashFailures = @HashFailures + 1

--Verify down the rest of the tree
WHILE @IsDone = 0 and @HashFailures = 0
BEGIN
	select 
		@Hash1 = m1.NodeHash
		,@Hash2 = m2.NodeHash 
		,@NodeHash = n.NodeHash
		,@NextNodeID = n.MerkleTreeIntermediateNodeID
	from MerkleTreeIntermediateNode n
	JOIN dbo.MerkleTreeIntermediateNode m1 on m1.MerkleTreeIntermediateNodeID = n.MerkleTreeIntermediateNodeID1
	JOIN dbo.MerkleTreeIntermediateNode m2 on m2.MerkleTreeIntermediateNodeID = n.MerkleTreeIntermediateNodeID2
	where n.MerkleTreeIntermediateNodeID1 = @NextNodeID or n.MerkleTreeIntermediateNodeID2 = @NextNodeID

	IF @@ROWCOUNT = 0 SET @IsDone = 1

	IF @NodeHash <> HASHBYTES('SHA2_256',HASHBYTES('SHA2_256',@Hash1 + @Hash2)) SET @HashFailures = @HashFailures + 1
END


--Verify MerkleRoot and BlockSignature
IF @HashFailures = 0
BEGIN
	DECLARE @BlockID INT 
	SELECT @BlockID = BlockID
	FROM [Transaction] 
	WHERE TransactionID = @TransactionID

	select @IsValid = CASE WHEN HASHBYTES('SHA2_256',HASHBYTES('SHA2_256',@Hash1 + @Hash2)) = MerkleRoot 
		and dbo.BlockVerifySignature(BlockID,PrevBlockID,TransactionCount,Nonce,Difficulty,b.MerkleRoot,PrevBlockSignature,CreatedDateTime,SignatureVersion,b.BlockSignature) 
			= 1 THEN 1 ELSE 0 END
	from [Block] b
	where BlockID = @BlockID
END

SELECT TransactionID = @TransactionID, IsValid = @IsValid, [Exists] = @Exists
