CREATE TABLE [dbo].[MerkleTreeIntermediateNode]
(
	[MerkleTreeIntermediateNodeID] INT NOT NULL CONSTRAINT PK_MerkleTreeIntermediateNode PRIMARY KEY CONSTRAINT DF_MerkleTreeIntermediateNode_MerkleTreeIntermediateNodeID DEFAULT(NEXT VALUE FOR MerkleTreeIntermediateNodeID)
	,TransactionID1 INT NULL CONSTRAINT FK_MerkleTreeIntermediateNode_TransactionID1 REFERENCES dbo.[Transaction](TransactionID)
	,TransactionID2 INT NULL CONSTRAINT FK_MerkleTreeIntermediateNode_TransactionID2 REFERENCES dbo.[Transaction](TransactionID)
	,MerkleTreeIntermediateNodeID1 INT NULL CONSTRAINT FK_MerkleTreeIntermediateNode_MerkleTreeIntermediateNodeID1 REFERENCES dbo.[MerkleTreeIntermediateNode]([MerkleTreeIntermediateNodeID])
	,MerkleTreeIntermediateNodeID2 INT NULL CONSTRAINT FK_MerkleTreeIntermediateNode_MerkleTreeIntermediateNodeID2 REFERENCES dbo.[MerkleTreeIntermediateNode]([MerkleTreeIntermediateNodeID])
	,Depth TINYINT NOT NULL
	,NodeHash BINARY(32) NOT NULL
	,BlockID INT NOT NULL
)
GO
ALTER TABLE [dbo].[MerkleTreeIntermediateNode] ADD CONSTRAINT CK_NodeReferencesByDepth
CHECK 
(
	(TransactionID1 IS NOT NULL and TransactionID2 IS NOT NULL AND MerkleTreeIntermediateNodeID1 IS NULL and MerkleTreeIntermediateNodeID2 IS NULL and Depth = 1)
	OR (TransactionID1 IS NULL and TransactionID2 IS NULL AND MerkleTreeIntermediateNodeID1 IS NOT NULL and MerkleTreeIntermediateNodeID2 IS NOT NULL and Depth > 1)
)
GO
CREATE INDEX NC_TransactionID1 ON [dbo].[MerkleTreeIntermediateNode]
(
	TransactionID1
)
GO
CREATE INDEX NC_TransactionID2 ON [dbo].[MerkleTreeIntermediateNode]
(
	TransactionID2
)
GO
CREATE INDEX NC_MerkleTreeIntermediateNodeID1 ON [dbo].[MerkleTreeIntermediateNode]
(
	MerkleTreeIntermediateNodeID1
)
GO
CREATE INDEX NC_MerkleTreeIntermediateNodeID2 ON [dbo].[MerkleTreeIntermediateNode]
(
	MerkleTreeIntermediateNodeID2
)
GO