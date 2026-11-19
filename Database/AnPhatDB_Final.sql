/* =====================================================================
   AnPhatDB_Final  -  Co so du lieu cho he thong "Quan ly An Phat PC"
   Nguon: demo-clean-version.zip (ASP.NET MVC, .NET Framework 4.7.2)
   He quan tri CSDL: Microsoft SQL Server (2016 tro len)
   Cach chay: mo file nay bang SQL Server Management Studio (SSMS) roi nhan F5.
   Script co the chay lai nhieu lan (se xoa va tao lai cac bang).
   ===================================================================== */

IF DB_ID(N'AnPhatDB_Final') IS NULL
    CREATE DATABASE AnPhatDB_Final;
GO

USE AnPhatDB_Final;
GO

/* ---------- Xoa bang cu (theo thu tu khoa ngoai) ---------- */
IF OBJECT_ID(N'dbo.tblInvoiceDetail',  N'U') IS NOT NULL DROP TABLE dbo.tblInvoiceDetail;
IF OBJECT_ID(N'dbo.tblInvoice',        N'U') IS NOT NULL DROP TABLE dbo.tblInvoice;
IF OBJECT_ID(N'dbo.tblCustomer',       N'U') IS NOT NULL DROP TABLE dbo.tblCustomer;
IF OBJECT_ID(N'dbo.tblWarrantyTicket', N'U') IS NOT NULL DROP TABLE dbo.tblWarrantyTicket;
IF OBJECT_ID(N'dbo.tblProductItem',    N'U') IS NOT NULL DROP TABLE dbo.tblProductItem;
IF OBJECT_ID(N'dbo.tblProduct',        N'U') IS NOT NULL DROP TABLE dbo.tblProduct;
IF OBJECT_ID(N'dbo.tblUser',           N'U') IS NOT NULL DROP TABLE dbo.tblUser;
IF OBJECT_ID(N'dbo.tblRole',           N'U') IS NOT NULL DROP TABLE dbo.tblRole;
GO

/* =====================================================================
   1. TAO BANG
   ===================================================================== */

-- Vai tro nguoi dung (UserRepository.Register mac dinh role_id = 2)
CREATE TABLE dbo.tblRole (
    role_id    INT           NOT NULL CONSTRAINT PK_tblRole PRIMARY KEY,
    role_name  NVARCHAR(50)  NOT NULL CONSTRAINT UQ_tblRole_name UNIQUE
);
GO

-- Nguoi dung / nhan vien (mat khau luu dang MD5 viet HOA, 32 ky tu)
CREATE TABLE dbo.tblUser (
    user_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tblUser PRIMARY KEY,
    username   VARCHAR(50)       NOT NULL CONSTRAINT UQ_tblUser_username UNIQUE,
    [password] CHAR(32)          NOT NULL,
    full_name  NVARCHAR(100)     NOT NULL,
    phone      VARCHAR(15)       NULL,
    role_id    INT               NOT NULL CONSTRAINT DF_tblUser_role DEFAULT (2),
    CONSTRAINT FK_tblUser_tblRole FOREIGN KEY (role_id) REFERENCES dbo.tblRole(role_id)
);
GO

-- Ho so khach hang, tra cuu va cap nhat theo so dien thoai
CREATE TABLE dbo.tblCustomer (
    customer_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tblCustomer PRIMARY KEY,
    full_name   NVARCHAR(100) NOT NULL,
    phone       VARCHAR(15) NOT NULL CONSTRAINT UQ_tblCustomer_phone UNIQUE,
    email       NVARCHAR(100) NULL,
    address     NVARCHAR(255) NULL,
    created_at  DATETIME NOT NULL CONSTRAINT DF_tblCustomer_created DEFAULT (GETDATE()),
    updated_at  DATETIME NULL
);
GO
-- Danh muc linh kien
CREATE TABLE dbo.tblProduct (
    product_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tblProduct PRIMARY KEY,
    product_name  NVARCHAR(200)     NOT NULL,
    price         DECIMAL(18,2)     NOT NULL CONSTRAINT CK_tblProduct_price CHECK (price >= 0),
    category      NVARCHAR(50)      NOT NULL
);
GO

-- Tung linh kien cu the trong kho, quan ly theo ma Serial
CREATE TABLE dbo.tblProductItem (
    item_id        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tblProductItem PRIMARY KEY,
    product_id     INT               NOT NULL,
    serial_number  VARCHAR(50)       NOT NULL CONSTRAINT UQ_tblProductItem_serial UNIQUE,
    [status]       VARCHAR(20)       NOT NULL CONSTRAINT DF_tblProductItem_status DEFAULT ('InStock'),
    import_date    DATETIME          NOT NULL CONSTRAINT DF_tblProductItem_import DEFAULT (GETDATE()),
    CONSTRAINT CK_tblProductItem_status CHECK ([status] IN ('InStock', 'Exported')),
    CONSTRAINT FK_tblProductItem_tblProduct FOREIGN KEY (product_id) REFERENCES dbo.tblProduct(product_id)
);
GO
CREATE INDEX IX_tblProductItem_product ON dbo.tblProductItem(product_id);
GO

-- Hoa don ban hang (ReportRepository: SUM(total_amount - discount_amount) theo ngay created_at)
CREATE TABLE dbo.tblInvoice (
    invoice_id       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tblInvoice PRIMARY KEY,
    user_id          INT               NULL,
    created_at       DATETIME          NOT NULL CONSTRAINT DF_tblInvoice_created DEFAULT (GETDATE()),
    total_amount     DECIMAL(18,2)     NOT NULL CONSTRAINT DF_tblInvoice_total DEFAULT (0),
    discount_amount  DECIMAL(18,2)     NOT NULL CONSTRAINT DF_tblInvoice_discount DEFAULT (0),
    CONSTRAINT CK_tblInvoice_amounts CHECK (total_amount >= 0 AND discount_amount >= 0 AND discount_amount <= total_amount),
    CONSTRAINT FK_tblInvoice_tblUser FOREIGN KEY (user_id) REFERENCES dbo.tblUser(user_id)
);
GO
CREATE INDEX IX_tblInvoice_created ON dbo.tblInvoice(created_at);
GO

-- [Mo rong - code hien tai chua dung] Chi tiet hoa don, de luu duoc gio hang POS
CREATE TABLE dbo.tblInvoiceDetail (
    detail_id   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tblInvoiceDetail PRIMARY KEY,
    invoice_id  INT           NOT NULL,
    product_id  INT           NOT NULL,
    quantity    INT           NOT NULL CONSTRAINT CK_tblInvoiceDetail_qty CHECK (quantity > 0),
    unit_price  DECIMAL(18,2) NOT NULL CONSTRAINT CK_tblInvoiceDetail_price CHECK (unit_price >= 0),
    CONSTRAINT FK_tblInvoiceDetail_tblInvoice FOREIGN KEY (invoice_id) REFERENCES dbo.tblInvoice(invoice_id) ON DELETE CASCADE,
    CONSTRAINT FK_tblInvoiceDetail_tblProduct FOREIGN KEY (product_id) REFERENCES dbo.tblProduct(product_id)
);
GO

-- Phieu bao hanh (trang thai: Dang xu ly / Dang sua chua / Cho linh kien / Hoan thanh / Da tra may)
CREATE TABLE dbo.tblWarrantyTicket (
    ticket_id          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_tblWarrantyTicket PRIMARY KEY,
    serial_number      VARCHAR(50)       NOT NULL,
    customer_phone     VARCHAR(15)       NOT NULL,
    user_id            INT               NOT NULL,
    issue_description  NVARCHAR(500)     NOT NULL,
    [status]           NVARCHAR(50)      NOT NULL CONSTRAINT DF_tblWarrantyTicket_status DEFAULT (N'Đang xử lý'),
    receive_date       DATETIME          NOT NULL CONSTRAINT DF_tblWarrantyTicket_receive DEFAULT (GETDATE()),
    return_date        DATETIME          NULL,
    CONSTRAINT FK_tblWarrantyTicket_serial FOREIGN KEY (serial_number) REFERENCES dbo.tblProductItem(serial_number),
    CONSTRAINT FK_tblWarrantyTicket_tblUser FOREIGN KEY (user_id) REFERENCES dbo.tblUser(user_id)
);
GO
CREATE INDEX IX_tblWarrantyTicket_serial ON dbo.tblWarrantyTicket(serial_number);
GO

/* =====================================================================
   2. DU LIEU MAU
   ===================================================================== */

-- Vai tro
INSERT INTO dbo.tblRole (role_id, role_name) VALUES
    (1, N'Quản trị viên'),
    (2, N'Nhân viên');
GO

-- Nguoi dung (mat khau mau: 123456, da bam MD5). user_id 1 = admin vi Warranty2Controller dang hardcode UserId = 1
INSERT INTO dbo.tblUser (username, [password], full_name, phone, role_id) VALUES
    ('admin', 'E10ADC3949BA59ABBE56E057F20F883E', N'Nguyễn Văn Quản Trị', '0900000001', 1),
    ('nhanvien01', 'E10ADC3949BA59ABBE56E057F20F883E', N'Trần Minh Quang', '0900000002', 2),
    ('nhanvien02', 'E10ADC3949BA59ABBE56E057F20F883E', N'Lê Thị Hoa', '0900000003', 2);
GO

-- Linh kien (product_id 1 va 2 khop voi phan gan ten tam trong WarrantyRepository.CheckWarranty)
INSERT INTO dbo.tblProduct (product_name, price, category) VALUES
    (N'CPU Intel Core i5 13400F', 4590000, N'CPU'),
    (N'Mainboard ASUS PRIME B760M-A', 3290000, N'Mainboard'),
    (N'CPU AMD Ryzen 5 7600X', 5890000, N'CPU'),
    (N'Mainboard MSI B650M GAMING PLUS', 3790000, N'Mainboard'),
    (N'RAM Kingston Fury Beast 16GB DDR5 5600MHz', 1590000, N'RAM'),
    (N'RAM Corsair Vengeance 32GB (2x16GB) DDR4 3200MHz', 2290000, N'RAM'),
    (N'VGA GIGABYTE GeForce RTX 4060 Gaming OC 8GB', 8490000, N'VGA'),
    (N'VGA ASUS Dual RTX 4070 SUPER 12GB', 16990000, N'VGA'),
    (N'SSD Samsung 980 Pro 1TB NVMe', 2490000, N'SSD'),
    (N'SSD Kingston NV2 500GB NVMe', 990000, N'SSD'),
    (N'PSU Corsair CV650 650W 80 Plus Bronze', 1190000, N'PSU'),
    (N'PSU Cooler Master MWE 750W 80 Plus Gold', 1990000, N'PSU'),
    (N'Tản nhiệt khí DeepCool AK400', 590000, N'Khác');
GO

-- Serial linh kien trong kho
INSERT INTO dbo.tblProductItem (product_id, serial_number, [status], import_date) VALUES
    (1, 'CPU-I5-13400F-0001', 'Exported', '2023-06-10 09:15:00'),
    (1, 'CPU-I5-13400F-0002', 'InStock', '2025-03-02 10:00:00'),
    (1, 'CPU-I5-13400F-0003', 'InStock', '2025-03-02 10:00:00'),
    (2, 'MB-B760M-0001', 'Exported', '2024-01-15 14:30:00'),
    (2, 'MB-B760M-0002', 'InStock', '2025-08-20 08:45:00'),
    (3, 'CPU-R5-7600X-0001', 'Exported', '2024-05-12 11:20:00'),
    (3, 'CPU-R5-7600X-0002', 'InStock', '2025-09-05 13:00:00'),
    (4, 'MB-B650M-0001', 'Exported', '2024-05-12 11:25:00'),
    (4, 'MB-B650M-0002', 'InStock', '2025-09-05 13:10:00'),
    (5, 'RAM-KF16-0001', 'Exported', '2025-01-18 15:00:00'),
    (5, 'RAM-KF16-0002', 'InStock', '2025-10-01 09:00:00'),
    (6, 'RAM-CV32-0001', 'InStock', '2025-10-01 09:05:00'),
    (7, 'VGA-4060-0001', 'Exported', '2024-11-22 16:40:00'),
    (7, 'VGA-4060-0002', 'InStock', '2025-11-10 10:30:00'),
    (8, 'VGA-4070S-0001', 'InStock', '2026-02-14 14:00:00'),
    (9, 'SSD-980P-0001', 'Exported', '2024-02-03 09:30:00'),
    (9, 'SSD-980P-0002', 'InStock', '2025-12-08 11:00:00'),
    (10, 'SSD-NV2-0001', 'Exported', '2025-04-25 10:10:00'),
    (10, 'SSD-NV2-0002', 'InStock', '2026-01-12 10:10:00'),
    (11, 'PSU-CV650-0001', 'Exported', '2025-06-30 08:00:00'),
    (12, 'PSU-MWE750-0001', 'InStock', '2026-03-01 08:30:00'),
    (13, 'FAN-AK400-0001', 'InStock', '2026-03-01 08:35:00');
GO

-- Hoa don mau duoc bo qua de trang thong ke doanh thu mac dinh trong.

-- Phieu bao hanh
INSERT INTO dbo.tblWarrantyTicket (serial_number, customer_phone, user_id, issue_description, [status], receive_date, return_date) VALUES
    ('CPU-I5-13400F-0001', '0901234567', 2, N'CPU bị quá nhiệt, máy tự khởi động lại', N'Hoàn thành', '2025-11-03 09:00:00', '2025-11-10 16:00:00'),
    ('MB-B760M-0001', '0912345678', 2, N'Mainboard không nhận khe RAM số 2', N'Đang sửa chữa', '2026-03-15 10:30:00', NULL),
    ('VGA-4060-0001', '0987654321', 2, N'Card màn hình bị sọc ngang, artifact khi chơi game', N'Chờ linh kiện', '2026-04-02 14:20:00', NULL),
    ('SSD-980P-0001', '0933445566', 2, N'SSD báo lỗi SMART, tốc độ ghi giảm mạnh', N'Đang xử lý', '2026-04-18 08:50:00', NULL),
    ('RAM-KF16-0001', '0977889900', 2, N'Máy treo, blue screen liên tục (nghi lỗi RAM)', N'Đã trả máy', '2026-02-10 15:00:00', '2026-02-14 11:00:00');
GO

/* =====================================================================
   3. KIEM TRA NHANH
   ===================================================================== */
SELECT 'tblRole' AS bang, COUNT(*) AS so_dong FROM dbo.tblRole
UNION ALL SELECT 'tblUser',          COUNT(*) FROM dbo.tblUser
UNION ALL SELECT 'tblProduct',       COUNT(*) FROM dbo.tblProduct
UNION ALL SELECT 'tblProductItem',   COUNT(*) FROM dbo.tblProductItem
UNION ALL SELECT 'tblInvoice',       COUNT(*) FROM dbo.tblInvoice
UNION ALL SELECT 'tblInvoiceDetail', COUNT(*) FROM dbo.tblInvoiceDetail
UNION ALL SELECT 'tblWarrantyTicket',COUNT(*) FROM dbo.tblWarrantyTicket;
GO


