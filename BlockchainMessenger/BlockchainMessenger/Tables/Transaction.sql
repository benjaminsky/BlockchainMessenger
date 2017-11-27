CREATE TABLE [dbo].[Transaction]
(
	[TransactionID] INT NOT NULL CONSTRAINT PK_Transaction PRIMARY KEY CONSTRAINT DF_Transaction_TransactionID DEFAULT(NEXT VALUE FOR dbo.TransactionID)
	,TransactionTypeID SMALLINT NOT NULL CONSTRAINT FK_Transaction_TransactionType REFERENCES dbo.TransactionType(TransactionTypeID)
	,MessageID INT NOT NULL CONSTRAINT FK_Transaction_Message REFERENCES dbo.[Message](MessageID)
	,TransactionHash BINARY(32) NOT NULL
	,HashVersion INT NOT NULL
	,PrevTransactionID INT NULL CONSTRAINT FK_Transaction_PrevTransactionID REFERENCES dbo.[Transaction]([TransactionID])
	,PrevTransactionHash BINARY(32) NULL
	,TransactionDateTime DATETIMEOFFSET(2) NOT NULL CONSTRAINT DF_Transaction_TransactionDateTime DEFAULT(SYSDATETIMEOFFSET())
)
GO
/* this will ensure only 1 child per parent and only 1 genesis Transaction (PrevTransactionID IS NULL) */
CREATE UNIQUE INDEX U_PrevTransactionID on dbo.[Transaction]
(
	PrevTransactionID
)
GO
ALTER TABLE dbo.[Transaction] ADD CONSTRAINT CK_PreviousFieldsNullTogether CHECK (
	(PrevTransactionID IS NULL and PrevTransactionHash IS NULL) 
	OR (PrevTransactionID IS NOT NULL and PrevTransactionHash IS NOT NULL)
)
GO
