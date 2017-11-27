PRINT 'Populating Lookup Table [dbo].[TransactionType]'

MERGE INTO [dbo].[TransactionType] as t
    USING (
        VALUES(1,'Message Send')
             ,(2,'Message Mark Read')
             ,(3,'Message Mark Unread')
             /* Enter Additional Data Here */
    ) s ([TransactionTypeID],[TransactionTypeDesc])
        ON t.[TransactionTypeID] = s.[TransactionTypeID]
WHEN MATCHED AND (
        s.[TransactionTypeDesc] <> t.[TransactionTypeDesc]
    )
    THEN 
        UPDATE
            SET [TransactionTypeDesc] = s.[TransactionTypeDesc]
WHEN NOT MATCHED BY TARGET
    THEN
        INSERT 
        (
            [TransactionTypeID]
            ,[TransactionTypeDesc]
        )
        VALUES 
        (
            [TransactionTypeID]
            ,[TransactionTypeDesc]
        )
WHEN NOT MATCHED BY SOURCE 
   THEN 
       DELETE;

GO