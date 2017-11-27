CREATE TABLE [dbo].[Transaction]
(
	[TransactionID] INT NOT NULL CONSTRAINT PK_Transaction PRIMARY KEY CONSTRAINT DF_Transaction_TransactionID DEFAULT(NEXT VALUE FOR dbo.TransactionID)
	,TransactionTypeID SMALLINT NOT NULL CONSTRAINT FK_Transaction_TransactionType REFERENCES dbo.TransactionType(TransactionTypeID)
	,MessageID INT NULL CONSTRAINT FK_Transaction_Message REFERENCES dbo.[Message](MessageID)
	,TransactionHash BINARY(32) NOT NULL
	,HashVersion INT NOT NULL
	,BlockID INT NULL CONSTRAINT FK_Transaction_Block REFERENCES dbo.[Block](BlockID)
	,TransactionDateTime DATETIMEOFFSET(2) NOT NULL CONSTRAINT DF_Transaction_TransactionDateTime DEFAULT(SYSDATETIMEOFFSET())
)
GO
