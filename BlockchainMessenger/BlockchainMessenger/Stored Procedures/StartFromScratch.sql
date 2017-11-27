﻿CREATE PROCEDURE [dbo].[StartFromScratch]
AS
DELETE [MerkleTreeIntermediateNode]
DELETE [Transaction]
DELETE [Block]
DELETE [Message]
DELETE [User]

ALTER SEQUENCE dbo.MerkleTreeIntermediateNodeID RESTART
ALTER SEQUENCE dbo.MessageID RESTART
ALTER SEQUENCE dbo.UserID RESTART
ALTER SEQUENCE dbo.TransactionID RESTART
ALTER SEQUENCE dbo.BlockID RESTART