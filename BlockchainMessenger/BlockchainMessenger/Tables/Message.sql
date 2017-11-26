CREATE TABLE [dbo].[Message]
(
	MessageID INT NOT NULL CONSTRAINT PK_Message PRIMARY KEY CONSTRAINT DF_Message_MessageID DEFAULT(NEXT VALUE FOR dbo.MessageID)
	,FromUserID INT NOT NULL CONSTRAINT FK_Message_FromUserID REFERENCES dbo.[User](UserID)
	,ToUserID INT NOT NULL CONSTRAINT FK_Message_ToUserID REFERENCES dbo.[User](UserID)
	,[Subject] NVARCHAR(100) NOT NULL
	,Body NVARCHAR(1000) NOT NULL
	,ReadDateTime DATETIMEOFFSET(2) CONSTRAINT CK_ReadDateTime CHECK (ReadDateTime IS NULL OR ReadDateTime > CreatedDateTime)
	,CreatedDateTime DATETIMEOFFSET(2) NOT NULL CONSTRAINT DF_Message_CreatedDateTime DEFAULT(SYSDATETIMEOFFSET())
	/* blockchain fields */
	,MessageHash BINARY(32) NOT NULL
	,HashVersion INT NOT NULL
	,PrevMessageID INT NULL CONSTRAINT FK_Message_PrevMessageID REFERENCES dbo.[Message](MessageID)
	,PrevMessageHash BINARY(32) NULL
)
GO
/* this will ensure only 1 child per parent and only 1 genesis message (PrevMessageID IS NULL) */
CREATE UNIQUE INDEX U_PrevMessageID on dbo.[Message]
(
	PrevMessageID
)
GO
ALTER TABLE dbo.[Message] ADD CONSTRAINT CK_PreviousFieldsNullTogether CHECK (
	(PrevMessageID IS NULL and PrevMessageHash IS NULL) 
	OR (PrevMessageID IS NOT NULL and PrevMessageHash IS NOT NULL)
)
GO

