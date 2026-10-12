USE TechStore;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/*
    Chạy một lần cho database đã được tạo trước giai đoạn quản lý tài khoản.
    Script có thể chạy lại an toàn: bảng và index chỉ được tạo khi chưa tồn tại.
*/

IF OBJECT_ID('dbo.PasswordResetTokens', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordResetTokens (
        PasswordResetTokenId BIGINT IDENTITY(1,1) PRIMARY KEY,
        UserId               BIGINT NOT NULL,
        TokenHash            VARCHAR(64) NOT NULL,
        ExpiresAt            DATETIME2 NOT NULL,
        UsedAt               DATETIME2 NULL,
        CreatedAt            DATETIME2 NOT NULL
                             CONSTRAINT DF_PasswordResetTokens_CreatedAt DEFAULT SYSUTCDATETIME(),

        CONSTRAINT FK_PasswordResetTokens_Users
            FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
    );
END
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
           WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PasswordResetTokens'
             AND COLUMN_NAME = 'TokenHash' AND DATA_TYPE = 'char')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_PasswordResetTokens_TokenHash'
                 AND object_id = OBJECT_ID('dbo.PasswordResetTokens'))
        DROP INDEX UX_PasswordResetTokens_TokenHash ON dbo.PasswordResetTokens;

    ALTER TABLE dbo.PasswordResetTokens ALTER COLUMN TokenHash VARCHAR(64) NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_PasswordResetTokens_TokenHash'
                 AND object_id = OBJECT_ID('dbo.PasswordResetTokens'))
    CREATE UNIQUE INDEX UX_PasswordResetTokens_TokenHash
        ON dbo.PasswordResetTokens(TokenHash);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_PasswordResetTokens_UserCreated'
                 AND object_id = OBJECT_ID('dbo.PasswordResetTokens'))
    CREATE INDEX IX_PasswordResetTokens_UserCreated
        ON dbo.PasswordResetTokens(UserId, CreatedAt DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'IX_PasswordResetTokens_Expiry'
                 AND object_id = OBJECT_ID('dbo.PasswordResetTokens'))
    CREATE INDEX IX_PasswordResetTokens_Expiry
        ON dbo.PasswordResetTokens(ExpiresAt) WHERE UsedAt IS NULL;
GO
