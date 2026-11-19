/* Xóa đúng sáu hóa đơn demo ngày 15–20/04/2026.
   Hóa đơn khác được giữ nguyên. Chạy trong database AnPhatDB_Final. */
USE [AnPhatDB_Final];
GO

-- Dọn transaction dở dang nếu lần chạy trước lỗi trong cùng cửa sổ SSMS.
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
GO

SET XACT_ABORT ON;
IF OBJECT_ID('tempdb..#SampleInvoices') IS NOT NULL DROP TABLE #SampleInvoices;
CREATE TABLE #SampleInvoices
(
    CreatedAt DATETIME2(0) NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL,
    DiscountAmount DECIMAL(18,2) NOT NULL
);

INSERT INTO #SampleInvoices (CreatedAt, TotalAmount, DiscountAmount) VALUES
('2026-04-15T10:20:00', 11060000, 553000),
('2026-04-15T15:45:00', 2490000, 0),
('2026-04-16T09:10:00', 13960000, 698000),
('2026-04-17T11:30:00', 9680000, 0),
('2026-04-18T16:05:00', 2570000, 0),
('2026-04-20T14:00:00', 24470000, 1223500);

BEGIN TRY
    BEGIN TRANSACTION;

    -- Bảng chi tiết không có ở một số phiên bản cũ; xóa chi tiết nếu bảng tồn tại.
    IF OBJECT_ID(N'dbo.tblInvoiceDetail', N'U') IS NOT NULL
    BEGIN
        EXEC sys.sp_executesql N'
            DELETE detail
            FROM dbo.tblInvoiceDetail AS detail
            INNER JOIN dbo.tblInvoice AS invoice ON invoice.invoice_id = detail.invoice_id
            INNER JOIN #SampleInvoices AS sample
                ON invoice.created_at = sample.CreatedAt
               AND invoice.total_amount = sample.TotalAmount
               AND invoice.discount_amount = sample.DiscountAmount;';
    END;

    DELETE invoice
    FROM dbo.tblInvoice AS invoice
    INNER JOIN #SampleInvoices AS sample
        ON invoice.created_at = sample.CreatedAt
       AND invoice.total_amount = sample.TotalAmount
       AND invoice.discount_amount = sample.DiscountAmount;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

DROP TABLE #SampleInvoices;
