USE [AnPhatDB_Final];
GO

IF OBJECT_ID(N'dbo.tblCustomer', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.tblCustomer (
        customer_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tblCustomer PRIMARY KEY,
        full_name   NVARCHAR(100) NOT NULL,
        phone       VARCHAR(15) NOT NULL,
        email       NVARCHAR(100) NULL,
        address     NVARCHAR(255) NULL,
        created_at  DATETIME NOT NULL CONSTRAINT DF_tblCustomer_created DEFAULT (GETDATE()),
        updated_at  DATETIME NULL,
        CONSTRAINT UQ_tblCustomer_phone UNIQUE (phone)
    );
END;
GO
