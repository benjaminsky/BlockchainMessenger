CREATE TABLE [dbo].[Block]
(
	BlockID INT NOT NULL CONSTRAINT PK_Block PRIMARY KEY CONSTRAINT DF_Block_BlockID DEFAULT(NEXT VALUE FOR dbo.BlockID)
	,PrevBlockID INT NULL REFERENCES dbo.[Block](BlockID)
	,TransactionCount INT NULL
	,MerkleRoot BINARY(32) NULL
	,Nonce INT NULL
	,Difficulty VARBINARY(4) NULL
	,BlockSignature VARBINARY(256) NULL
	,SignatureVersion INT NOT NULL
	,PrevBlockSignature VARBINARY(256) NULL
	,CreatedDateTime DATETIMEOFFSET(2) NOT NULL CONSTRAINT DF_Block_CreatedDateTime DEFAULT(SYSDATETIMEOFFSET())
)
GO
/* this will ensure only 1 child per parent and only 1 genesis block (PrevBlockID IS NULL) */
CREATE UNIQUE INDEX U_PrevBlockID on dbo.[Block]
(
	PrevBlockID
)
GO

/* this will ensure we only ever have 1 unsigned block */
CREATE UNIQUE INDEX U_BlockSignature on dbo.[Block]
(
	BlockSignature
)
WHERE (BlockSignature IS NULL)
GO

ALTER TABLE dbo.[Block] ADD CONSTRAINT CK_PreviousFieldsNullTogether CHECK (
	(PrevBlockID IS NULL and PrevBlockSignature IS NULL) 
	OR (PrevBlockID IS NOT NULL and PrevBlockSignature IS NOT NULL)
)
GO
