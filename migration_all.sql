-- =============================================================
-- migration_all.sql — GOM tat ca 20 file migration_*.sql (tru migration_topping_category_product_category.sql,
-- thiet ke 1-1 CU da bi thay the boi migration_topping_category_multi_product_category.sql) thanh 1 file
-- duy nhat, chay theo dung thu tu phu thuoc, de tien chay 1 lenh thay vi 21 lenh rieng.
-- (2026-08-01: gom them migration_shipper_verification.sql + migration_shipper_doc_front_back.sql
-- - 2 file nay truoc day bi bo sot khi tao migration_all.sql, khien DB moi hoan toan neu chi chay
-- migration_all.sql se thieu cac cot anh CCCD/GPLX mat truoc/sau + verification_status cua Shipper_Profiles.)
-- Tat ca deu idempotent (IF NOT EXISTS / COLUMNPROPERTY check) nen chay lai nhieu lan khong sao,
-- KHONG xoa du lieu cu. Xem migration_verify_all.sql de kiem tra ket qua sau khi chay.
-- Cac file goc (migration_*.sql) van duoc giu lai lam tai lieu lich su tung thay doi rieng le.
-- =============================================================


-- =============================================================
-- Nguon: migration_user_addresses.sql
-- =============================================================
USE POB;
GO

-- =============================================
-- Migration: Tạo bảng User_Addresses
-- Chạy 1 lần trên SQL Server
-- =============================================

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='User_Addresses' AND xtype='U')
CREATE TABLE User_Addresses (
    id             BIGINT IDENTITY(1,1) PRIMARY KEY,
    account_id     BIGINT        NOT NULL,
    label          NVARCHAR(50)  NOT NULL DEFAULT N'Nhà',   -- 'Nhà', 'Công ty', 'Trường học', 'Khác'
    full_address   NVARCHAR(500) NOT NULL,
    receiver_name  NVARCHAR(100) NOT NULL,
    receiver_phone VARCHAR(15)   NOT NULL,
    is_default     BIT           NOT NULL DEFAULT 0,
    created_at     DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_UserAddresses_Account FOREIGN KEY (account_id) REFERENCES Accounts(id)
);

-- =============================================================
-- Nguon: migration_user_addresses_location.sql
-- =============================================================
USE POB;
GO

-- =============================================
-- Migration: Thêm cột locationX/locationY vào User_Addresses
-- (tọa độ GPS của địa chỉ giao hàng, dùng cho tính năng
-- theo dõi shipper realtime và chọn vị trí trên bản đồ)
-- Chạy 1 lần trên SQL Server
-- =============================================

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID('User_Addresses') AND name = 'locationX'
)
ALTER TABLE User_Addresses ADD locationX FLOAT NULL;

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID('User_Addresses') AND name = 'locationY'
)
ALTER TABLE User_Addresses ADD locationY FLOAT NULL;

-- =============================================================
-- Nguon: migration_user_profiles.sql
-- =============================================================
USE POB;
GO

-- =============================================
-- Migration: Tạo bảng User_Profiles
-- Chạy 1 lần trên SQL Server
-- =============================================

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='User_Profiles' AND xtype='U')
CREATE TABLE User_Profiles (
    id                  BIGINT IDENTITY(1,1) PRIMARY KEY,
    account_id          BIGINT NOT NULL UNIQUE,   -- FK → Accounts.id
    date_of_birth       DATE,
    gender              NVARCHAR(10) CHECK (gender IN ('MALE','FEMALE','OTHER')),
    default_address_id  BIGINT,                   -- FK → User_Addresses.id (nullable)
    created_at          DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_UserProfiles_Account  FOREIGN KEY (account_id)         REFERENCES Accounts(id),
    CONSTRAINT FK_UserProfiles_Address  FOREIGN KEY (default_address_id) REFERENCES User_Addresses(id)
);

-- =============================================================
-- Nguon: migration_shipper_profiles.sql
-- =============================================================
USE POB;
GO

-- Tạo bảng Shipper_Profiles lưu thông tin phương tiện của tài xế
-- Chạy 1 lần duy nhất trên DB thực tế
--
-- LƯU Ý (sửa 2026-07-23): bản gốc gộp CREATE TABLE + CREATE TRIGGER trong cùng 1 batch (cùng
-- 1 khối GO) -- SQL Server bắt buộc CREATE TRIGGER phải là câu lệnh DUY NHẤT trong batch của nó,
-- nên toàn bộ script bị lỗi cú pháp ngay khi PARSE (Msg 156 "Incorrect syntax near TRIGGER"),
-- chặn luôn cả nhánh ELSE (thêm cột còn thiếu) không chạy được dù bảng đã tồn tại. Phát hiện khi
-- chạy thực tế trên DB thật (14.225.217.109) lúc chuẩn bị bảo vệ đồ án -- audit code tĩnh không
-- bắt được lỗi loại này. Đã tách CREATE TRIGGER ra 1 batch riêng bằng GO.
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Shipper_Profiles'
)
BEGIN
    CREATE TABLE Shipper_Profiles (
        id             BIGINT        PRIMARY KEY IDENTITY(1,1),
        account_id     BIGINT        NOT NULL UNIQUE,
        cccd           VARCHAR(20)   NULL,   -- Số CCCD/CMND
        license_number VARCHAR(20)   NULL,   -- Số bằng lái xe
        vehicle_type   NVARCHAR(50)  NULL,   -- 'Xe máy', 'Ô tô', 'Xe đạp điện'
        vehicle_plate  VARCHAR(20)   NULL,   -- Biển số xe
        vehicle_model  NVARCHAR(100) NULL,   -- Nhãn hiệu / model xe
        bank_account   VARCHAR(30)   NULL,   -- Số tài khoản ngân hàng
        bank_name      NVARCHAR(100) NULL,   -- Tên ngân hàng
        id_card_image_url NVARCHAR(500) NULL, -- Anh chup CCCD/CMND (URL Cloudinary)
        created_at     DATETIME2     DEFAULT GETDATE(),
        updated_at     DATETIME2     DEFAULT GETDATE(),
        CONSTRAINT FK_ShipperProfile_Account FOREIGN KEY (account_id) REFERENCES Accounts(id)
    );
END
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shipper_Profiles')
   AND NOT EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'TR_ShipperProfiles_UpdatedAt')
BEGIN
    EXEC('CREATE TRIGGER TR_ShipperProfiles_UpdatedAt ON Shipper_Profiles AFTER UPDATE AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE Shipper_Profiles SET updated_at = GETDATE()
        WHERE id IN (SELECT id FROM inserted);
    END');
END
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shipper_Profiles')
BEGIN
    -- Thêm cột còn thiếu nếu bảng đã tồn tại nhưng chưa có các cột mới
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Shipper_Profiles' AND COLUMN_NAME = 'cccd')
        ALTER TABLE Shipper_Profiles ADD cccd VARCHAR(20) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Shipper_Profiles' AND COLUMN_NAME = 'license_number')
        ALTER TABLE Shipper_Profiles ADD license_number VARCHAR(20) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Shipper_Profiles' AND COLUMN_NAME = 'bank_account')
        ALTER TABLE Shipper_Profiles ADD bank_account VARCHAR(30) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Shipper_Profiles' AND COLUMN_NAME = 'bank_name')
        ALTER TABLE Shipper_Profiles ADD bank_name NVARCHAR(100) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Shipper_Profiles' AND COLUMN_NAME = 'id_card_image_url')
        ALTER TABLE Shipper_Profiles ADD id_card_image_url NVARCHAR(500) NULL;
END
GO

-- =============================================================
-- Nguon: migration_shipper_verification.sql
-- =============================================================
-- Them anh GPLX + trang thai duyet giay to (CCCD/GPLX) cho Shipper (cot id_card_image_url
-- da co san tu truoc nhung chua co noi nao ghi/doc trang thai duyet; migration nay bo sung
-- anh GPLX + co verification_status de SuperAdmin doi chieu & duyet cho Shipper truoc khi
-- hoat dong chinh thuc). Phai chay TRUOC migration_shipper_doc_front_back.sql vi script do
-- se DROP cot license_image_url duoc tao o day.

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'license_image_url'
)
ALTER TABLE Shipper_Profiles ADD license_image_url NVARCHAR(500) NULL; -- Ảnh chụp GPLX (URL Cloudinary)
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'verification_status'
)
ALTER TABLE Shipper_Profiles ADD verification_status NVARCHAR(20) NOT NULL DEFAULT 'PENDING';
GO

IF NOT EXISTS (
    SELECT * FROM sys.check_constraints WHERE name = 'CK_ShipperProfile_VerificationStatus'
)
ALTER TABLE Shipper_Profiles ADD CONSTRAINT CK_ShipperProfile_VerificationStatus
    CHECK (verification_status IN ('PENDING', 'APPROVED', 'REJECTED'));
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'rejection_reason'
)
ALTER TABLE Shipper_Profiles ADD rejection_reason NVARCHAR(500) NULL; -- Lý do khi SuperAdmin từ chối giấy tờ
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'verified_by'
)
ALTER TABLE Shipper_Profiles ADD verified_by BIGINT NULL; -- account_id SuperAdmin đã duyệt/từ chối
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'verified_at'
)
ALTER TABLE Shipper_Profiles ADD verified_at DATETIME2 NULL;
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'bank_account_holder'
)
ALTER TABLE Shipper_Profiles ADD bank_account_holder NVARCHAR(100) NULL; -- Ten chu tai khoan ngan hang (nhap tay, xem migration_shipper_bank_holder.sql)
GO

IF NOT EXISTS (
    SELECT * FROM sys.foreign_keys WHERE name = 'FK_ShipperProfile_VerifiedBy'
)
ALTER TABLE Shipper_Profiles ADD CONSTRAINT FK_ShipperProfile_VerifiedBy
    FOREIGN KEY (verified_by) REFERENCES Accounts(id);
GO

-- =============================================================
-- Nguon: migration_shipper_doc_front_back.sql
-- =============================================================
-- Tach anh CCCD/GPLX thanh mat truoc + mat sau (thay cho 1 anh duy nhat/loai giay to).
-- Bat buoc Shipper phai nop du 4 anh (CCCD truoc/sau, GPLX truoc/sau) de SuperAdmin doi chieu.
-- LUU Y: xoa 2 cot anh don cu (id_card_image_url, license_image_url) -- du lieu anh cu (neu co)
-- trong 2 cot nay se mat, Shipper can upload lai theo dung 2 mat.

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'id_card_front_url'
)
ALTER TABLE Shipper_Profiles ADD id_card_front_url NVARCHAR(500) NULL; -- Ảnh CCCD/CMND mặt trước (URL Cloudinary)
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'id_card_back_url'
)
ALTER TABLE Shipper_Profiles ADD id_card_back_url NVARCHAR(500) NULL; -- Ảnh CCCD/CMND mặt sau
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'license_front_url'
)
ALTER TABLE Shipper_Profiles ADD license_front_url NVARCHAR(500) NULL; -- Ảnh GPLX mặt trước
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'license_back_url'
)
ALTER TABLE Shipper_Profiles ADD license_back_url NVARCHAR(500) NULL; -- Ảnh GPLX mặt sau
GO

IF EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'id_card_image_url'
)
ALTER TABLE Shipper_Profiles DROP COLUMN id_card_image_url;
GO

IF EXISTS (
    SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Shipper_Profiles') AND name = 'license_image_url'
)
ALTER TABLE Shipper_Profiles DROP COLUMN license_image_url;
GO

-- =============================================================
-- Nguon: migration_shipper_is_online.sql
-- =============================================================
USE POB;
GO

-- Thêm cột is_online vào bảng Accounts (dùng cho tài xế bật/tắt chế độ sẵn sàng nhận đơn)
-- Chạy 1 lần duy nhất trên DB thực tế
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Accounts' AND COLUMN_NAME = 'is_online'
)
BEGIN
    ALTER TABLE Accounts ADD is_online BIT NOT NULL DEFAULT 0;
END
GO

-- =============================================================
-- Nguon: migration_shipper_withdrawals.sql
-- =============================================================
USE POB;
GO

-- Tạo bảng Shipper_Wallets (số dư ví tài xế) và Shipper_Withdrawals (yêu cầu rút tiền)
-- Chạy 1 lần duy nhất trên DB thực tế
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shipper_Wallets'
)
BEGIN
    CREATE TABLE Shipper_Wallets (
        id                 BIGINT        PRIMARY KEY IDENTITY(1,1),
        shipper_account_id BIGINT        NOT NULL UNIQUE,
        balance            DECIMAL(14,2) NOT NULL DEFAULT 0,
        updated_at         DATETIME2     NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_ShipperWallet_Account FOREIGN KEY (shipper_account_id) REFERENCES Accounts(id)
    );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shipper_Withdrawals'
)
BEGIN
    CREATE TABLE Shipper_Withdrawals (
        id                   BIGINT        PRIMARY KEY IDENTITY(1,1),
        shipper_account_id   BIGINT        NOT NULL,
        amount               DECIMAL(14,2) NOT NULL,
        bank_name            NVARCHAR(100) NOT NULL,
        bank_account_number  VARCHAR(30)   NOT NULL,
        bank_account_holder  NVARCHAR(100) NOT NULL,
        status               VARCHAR(20)   NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
        reject_reason        NVARCHAR(255) NULL,
        requested_at         DATETIME2     NOT NULL DEFAULT GETDATE(),
        processed_at         DATETIME2     NULL,
        processed_by         BIGINT        NULL,
        CONSTRAINT FK_ShipperWithdrawal_Account FOREIGN KEY (shipper_account_id) REFERENCES Accounts(id),
        CONSTRAINT FK_ShipperWithdrawal_ProcessedBy FOREIGN KEY (processed_by) REFERENCES Accounts(id)
    );

    CREATE INDEX IDX_ShipperWithdrawal_Status ON Shipper_Withdrawals(status);
    CREATE INDEX IDX_ShipperWithdrawal_Shipper ON Shipper_Withdrawals(shipper_account_id);
END
GO

-- =============================================================
-- Nguon: migration_shop_settlements.sql
-- =============================================================
USE POB;
GO

-- Migration: bảng lưu trạng thái đối soát/thanh toán doanh thu cho Shop theo từng kỳ (khoảng ngày) mà Super Admin đã xác nhận chi trả.
-- Mỗi dòng ứng với 1 lần Admin bấm "Xác nhận thanh toán" cho 1 Shop trong 1 khoảng [period_start, period_end] cụ thể.
--
-- LUU Y (sua 2026-07-23): ban goc KHONG co IF NOT EXISTS -> chay lan 2 (vd khi gop chung vao
-- migration_all.sql) se bao loi "already an object named 'Shop_Settlements'". Da boc dieu kien.

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shop_Settlements')
BEGIN
    CREATE TABLE Shop_Settlements (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        shop_id BIGINT NOT NULL,
        period_start DATE NOT NULL,
        period_end DATE NOT NULL,
        gross_revenue DECIMAL(14,2) NOT NULL,
        platform_fee DECIMAL(14,2) NOT NULL,
        net_payout DECIMAL(14,2) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID')),
        confirmed_by BIGINT NULL,
        confirmed_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_ShopSettlement_Period UNIQUE (shop_id, period_start, period_end),
        CONSTRAINT FK_ShopSettlement_Shop FOREIGN KEY (shop_id) REFERENCES Shops(id),
        CONSTRAINT FK_ShopSettlement_Account FOREIGN KEY (confirmed_by) REFERENCES Accounts(id)
    );

    CREATE INDEX IDX_ShopSettlement_Shop ON Shop_Settlements(shop_id);
END

-- =============================================================
-- Nguon: migration_suspend_reason.sql
-- =============================================================
USE POB;
GO

-- Thêm cột lý do đình chỉ tài khoản (dùng cho soft delete)
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Accounts' AND COLUMN_NAME = 'suspend_reason'
)
BEGIN
    ALTER TABLE Accounts ADD suspend_reason NVARCHAR(500) NULL;
END

-- =============================================================
-- Nguon: migration_order_cancel_reason.sql
-- =============================================================
-- Chạy 1 lần trên database POB đã có sẵn (không xóa dữ liệu cũ).
-- Bổ sung cột cancel_reason vào Orders để lưu lý do hủy đơn, phục vụ biểu đồ
-- "Thống kê lý do hủy đơn" (GROUP BY) trong trang Báo cáo vận hành (Super Admin).
USE POB;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Orders') AND name = 'cancel_reason'
)
BEGIN
    ALTER TABLE Orders ADD cancel_reason NVARCHAR(255) NULL;
END
GO

-- =============================================================
-- Nguon: migration_payment_method_payos.sql
-- =============================================================
-- Chạy 1 lần trên database POB đã có sẵn (không xóa dữ liệu cũ).
-- CHECK constraint cũ trên Orders.payment_method chỉ cho phép 'MOMO'/'BANK'/'COD',
-- chưa có 'PAYOS' -> insert Order với paymentMethod=PAYOS bị lỗi
-- "The INSERT statement conflicted with the CHECK constraint".
-- Thêm 'PAYOS' vào danh sách giá trị hợp lệ (giữ nguyên 'MOMO' để không phá dữ liệu cũ).
--
-- LƯU Ý (sửa 2026-07-23): bản gốc của file này DROP constraint cũ bằng tên cứng
-- 'CK__Orders__payment___690797E6' — đây là tên do SQL Server TỰ SINH khi tạo bảng bằng
-- CHECK không đặt tên, và hậu tố hash khác nhau giữa từng lần tạo DB/từng máy. Nếu tên không
-- khớp, khối DROP không chạy (bị bọc trong IF EXISTS) nhưng KHÔNG báo lỗi gì -> constraint cũ
-- vẫn tồn tại song song với constraint mới, để lại 2 CHECK constraint chồng nhau trên cùng 1 cột
-- (phát hiện khi audit bảo mật/DB chuẩn bị bảo vệ đồ án). Bản sửa dưới đây dò tên constraint cũ
-- động qua sys.check_constraints (theo định nghĩa, không theo tên) nên chạy đúng trên mọi DB.
USE POB;
GO

DECLARE @oldConstraintName NVARCHAR(128);
SELECT @oldConstraintName = cc.name
FROM sys.check_constraints cc
WHERE cc.parent_object_id = OBJECT_ID('Orders')
  AND cc.parent_column_id = COLUMNPROPERTY(OBJECT_ID('Orders'), 'payment_method', 'ColumnId')
  AND cc.name <> 'CK_Orders_PaymentMethod';

IF @oldConstraintName IS NOT NULL
BEGIN
    DECLARE @sql NVARCHAR(300) = N'ALTER TABLE Orders DROP CONSTRAINT ' + QUOTENAME(@oldConstraintName);
    EXEC sp_executesql @sql;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_Orders_PaymentMethod' AND parent_object_id = OBJECT_ID('Orders')
)
BEGIN
    ALTER TABLE Orders ADD CONSTRAINT CK_Orders_PaymentMethod
        CHECK ([payment_method] = 'MOMO' OR [payment_method] = 'BANK' OR [payment_method] = 'COD' OR [payment_method] = 'PAYOS');
END
GO

-- Kiểm tra sau khi chạy: chỉ còn đúng 1 CHECK constraint trên Orders.payment_method.
-- SELECT cc.name, cc.definition FROM sys.check_constraints cc
-- WHERE cc.parent_object_id = OBJECT_ID('Orders')
--   AND cc.parent_column_id = COLUMNPROPERTY(OBJECT_ID('Orders'), 'payment_method', 'ColumnId');

-- =============================================================
-- Nguon: migration_payment_status.sql
-- =============================================================
-- Chạy 1 lần trên database POB đã có sẵn (không xóa dữ liệu cũ).
-- Thêm cột payment_status cho bảng Orders để phục vụ tính năng "Bấm Bill" (POS).
USE POB;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Orders') AND name = 'payment_status'
)
BEGIN
    ALTER TABLE Orders ADD payment_status VARCHAR(20) NOT NULL
        CONSTRAINT DF_Order_PaymentStatus DEFAULT 'UNPAID';

    ALTER TABLE Orders ADD CONSTRAINT CHK_Order_PaymentStatus
        CHECK (payment_status IN ('UNPAID', 'PENDING', 'PAID'));
END
GO

-- =============================================================
-- Nguon: migration_payos_order_code.sql
-- =============================================================
-- Chạy 1 lần trên database POB đã có sẵn (không xóa dữ liệu cũ).
-- Thêm cột payos_order_code cho bảng Orders để liên kết 1 Order với 1 link thanh toán PayOS
-- (orderCode PayOS gửi lên khi redirect về returnUrl / gọi webhook).
USE POB;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Orders') AND name = 'payos_order_code'
)
BEGIN
    ALTER TABLE Orders ADD payos_order_code BIGINT NULL;
END
GO

-- =============================================================
-- Nguon: migration_product_status_pending_review.sql
-- =============================================================
-- Chạy 1 lần trên database POB đã có sẵn (không xóa dữ liệu cũ).
-- CHECK constraint cũ trên Products.status chỉ cho phép 'ACTIVE'/'OUT_OF_STOCK'/'HIDDEN',
-- chưa có 'PENDING_REVIEW' -> insert/update Product với status=PENDING_REVIEW bị lỗi
-- "The INSERT statement conflicted with the CHECK constraint".
-- Thêm 'PENDING_REVIEW' vào danh sách giá trị hợp lệ (giữ nguyên 3 giá trị cũ để không phá dữ liệu).
USE POB;
GO

IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK__Products__status__43A1090D' AND parent_object_id = OBJECT_ID('Products')
)
BEGIN
    ALTER TABLE Products DROP CONSTRAINT CK__Products__status__43A1090D;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_Products_Status' AND parent_object_id = OBJECT_ID('Products')
)
BEGIN
    ALTER TABLE Products ADD CONSTRAINT CK_Products_Status
        CHECK ([status] = 'ACTIVE' OR [status] = 'OUT_OF_STOCK' OR [status] = 'HIDDEN' OR [status] = 'PENDING_REVIEW');
END
GO

-- =============================================================
-- Nguon: migration_topping_category_multi_product_category.sql
-- =============================================================
USE POB;
GO

-- Nang cap "Loai Topping ap dung cho Loai San Pham" tu 1-1 (cot category_id) sang NHIEU-NHIEU
-- (1 loai topping co the ap dung cho nhieu loai san pham cung luc, vd "Topping tra sua" +
-- "Topping ca phe"). Thay the cho migration_topping_category_product_category.sql truoc do.
-- Chay 1 lan duy nhat tren DB thuc te.

-- 1. Bang trung gian nhieu-nhieu
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ToppingCategory_ProductCategories'
)
BEGIN
    CREATE TABLE ToppingCategory_ProductCategories (
        topping_category_id BIGINT NOT NULL,
        category_id          BIGINT NOT NULL,
        PRIMARY KEY (topping_category_id, category_id),
        CONSTRAINT FK_TCPC_ToppingCategory FOREIGN KEY (topping_category_id) REFERENCES ToppingCategories(id) ON DELETE CASCADE,
        CONSTRAINT FK_TCPC_Category        FOREIGN KEY (category_id)         REFERENCES Categories(id)
    );
END
GO

-- 2. Chuyen du lieu cu (neu ToppingCategories.category_id da ton tai va co gia tri) sang bang moi
--
-- LUU Y (sua 2026-07-23): ban goc dung SELECT/INSERT TINH (khong qua EXEC) tham chieu thang cot
-- category_id. SQL Server bind ten cot luc BIEN DICH ca batch (khong "deferred" cho cot cua bang
-- da ton tai, chi deferred cho BANG chua ton tai), nen du IF EXISTS o ngoai tra ve false, cau
-- SELECT/INSERT ben trong van bi loi "Invalid column name 'category_id'" ngay luc parse neu cot
-- da bi xoa boi 1 lan chay truoc do (vd khi chay lai file nay lan 2, hoac gop vao
-- migration_all.sql). Da boc toan bo logic dong trong EXEC(N'...') de chi bind/kiem tra cot luc
-- CHAY (runtime), khong phai luc bien dich.
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('ToppingCategories') AND name = 'category_id'
)
BEGIN
    EXEC(N'
        INSERT INTO ToppingCategory_ProductCategories (topping_category_id, category_id)
        SELECT id, category_id FROM ToppingCategories
        WHERE category_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM ToppingCategory_ProductCategories tcpc
              WHERE tcpc.topping_category_id = ToppingCategories.id AND tcpc.category_id = ToppingCategories.category_id
          );
    ');

    -- 3. Bo cot cu (khong con dung, da thay bang bang trung gian)
    DECLARE @fkName NVARCHAR(200);
    SELECT @fkName = name FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID('ToppingCategories')
      AND referenced_object_id = OBJECT_ID('Categories');
    IF @fkName IS NOT NULL
        EXEC('ALTER TABLE ToppingCategories DROP CONSTRAINT ' + @fkName);

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IDX_ToppingCategory_Category' AND object_id = OBJECT_ID('ToppingCategories'))
        DROP INDEX IDX_ToppingCategory_Category ON ToppingCategories;

    EXEC('ALTER TABLE ToppingCategories DROP COLUMN category_id');
END
GO

-- =============================================================
-- Nguon: migration_feedbacks.sql
-- =============================================================
USE POB;
GO

-- =============================================
-- Migration: Feedbacks + bom_count cho User
-- =============================================

-- 1. Tạo bảng Feedbacks
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Feedbacks' AND xtype='U')
CREATE TABLE Feedbacks (
    id            BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id      BIGINT        NOT NULL,
    reviewer_type NVARCHAR(10)  NOT NULL CHECK (reviewer_type IN ('USER','SHIPPER')),
    reviewer_id   BIGINT        NOT NULL,   -- account_id của người đánh giá
    target_type   NVARCHAR(10)  NOT NULL CHECK (target_type IN ('SHOP','SHIPPER')),
    target_id     BIGINT        NOT NULL,   -- shop_id hoặc account_id shipper
    rating        INT           NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       NVARCHAR(1000),
    is_anonymous  BIT           NOT NULL DEFAULT 0,
    created_at    DATETIME      NOT NULL DEFAULT GETDATE(),

    -- Mỗi order chỉ được feedback 1 lần với reviewer_type + target_type cụ thể
    CONSTRAINT UQ_Feedback_Once UNIQUE (order_id, reviewer_type, target_type)
);

-- 2. Thêm cột bom_count vào Accounts (đếm số lần user bom hàng)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Accounts' AND COLUMN_NAME = 'bom_count'
)
    ALTER TABLE Accounts ADD bom_count INT NOT NULL DEFAULT 0;

-- =============================================================
-- Nguon: migration_feedback_moderation.sql
-- =============================================================
-- Chạy 1 lần trên database POB đã có sẵn (không xóa dữ liệu cũ).
-- Phục vụ tính năng "Kiểm duyệt bình luận" (Super Admin):
--   1) Thêm cột status vào Feedbacks để đánh dấu bình luận VISIBLE / PENDING_REVIEW / REMOVED.
--   2) Tạo bảng BannedWords chứa danh sách từ ngữ nhạy cảm để FeedbackDAO.checkBadWords() quét.
USE POB;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('Feedbacks') AND name = 'status'
)
BEGIN
    ALTER TABLE Feedbacks ADD status NVARCHAR(20) NOT NULL CONSTRAINT DF_Feedbacks_status DEFAULT 'VISIBLE';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables WHERE name = 'BannedWords'
)
BEGIN
    CREATE TABLE BannedWords (
        id INT IDENTITY(1,1) PRIMARY KEY,
        word NVARCHAR(100) NOT NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE()
    );

    INSERT INTO BannedWords (word) VALUES
        (N'lừa đảo'),
        (N'ngu'),
        (N'chửi'),
        (N'địt'),
        (N'đéo');
END
GO

-- =============================================================
-- Nguon: migration_notifications.sql
-- =============================================================
USE POB;
GO

-- Tạo bảng Notifications cho hệ thống thông báo Shipper
-- Chạy 1 lần duy nhất trên DB thực tế
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Notifications'
)
BEGIN
    CREATE TABLE Notifications (
        id         BIGINT        PRIMARY KEY IDENTITY(1,1),
        account_id BIGINT        NOT NULL,           -- Người nhận thông báo
        title      NVARCHAR(255) NOT NULL,
        message    NVARCHAR(MAX) NOT NULL,
        is_read    BIT           NOT NULL DEFAULT 0,
        created_at DATETIME2     DEFAULT GETDATE(),
        CONSTRAINT FK_Notification_Account FOREIGN KEY (account_id) REFERENCES Accounts(id) ON DELETE CASCADE
    );

    CREATE INDEX IDX_Notification_Account ON Notifications(account_id);
END
GO

-- =============================================================
-- Nguon: migration_account_appeals.sql
-- =============================================================
USE POB;
GO

-- Bảng kháng nghị tài khoản bị đình chỉ
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Account_Appeals'
)
BEGIN
    CREATE TABLE Account_Appeals (
        id          BIGINT IDENTITY(1,1) PRIMARY KEY,
        account_id  BIGINT NOT NULL,
        message     NVARCHAR(1000) NOT NULL,
        status      NVARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING | APPROVED | REJECTED
        admin_note  NVARCHAR(500) NULL,
        created_at  DATETIME DEFAULT GETDATE(),
        reviewed_at DATETIME NULL,
        FOREIGN KEY (account_id) REFERENCES Accounts(id)
    );
END

-- =============================================================
-- Nguon: migration_complaints.sql
-- =============================================================
USE POB;
GO

-- Tao bang Complaints cho tinh nang khach hang khieu nai don hang
-- Chay 1 lan duy nhat tren DB thuc te
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'Complaints'
)
BEGIN
    CREATE TABLE Complaints (
        id         BIGINT        PRIMARY KEY IDENTITY(1,1),
        order_id   BIGINT        NOT NULL,
        account_id BIGINT        NOT NULL,          -- khach gui khieu nai (Orders.user_id)
        subject    NVARCHAR(255) NOT NULL,
        content    NVARCHAR(MAX) NOT NULL,
        status     VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                       CHECK (status IN ('PENDING', 'PROCESSING', 'RESOLVED', 'REJECTED')),
        admin_reply NVARCHAR(MAX) NULL,
        resolved_by BIGINT NULL,                    -- Accounts.id cua admin xu ly
        created_at DATETIME2     DEFAULT GETDATE(),
        updated_at DATETIME2     DEFAULT GETDATE(),
        CONSTRAINT FK_Complaint_Order   FOREIGN KEY (order_id)   REFERENCES Orders(id)   ON DELETE CASCADE,
        CONSTRAINT FK_Complaint_Account FOREIGN KEY (account_id) REFERENCES Accounts(id)
    );

    CREATE INDEX IDX_Complaint_Order   ON Complaints(order_id);
    CREATE INDEX IDX_Complaint_Account ON Complaints(account_id);
    CREATE INDEX IDX_Complaint_Status  ON Complaints(status);
END
GO

-- =============================================
-- Migration: Them cot scheduled_at vao Orders
-- (thoi diem giao hang theo yeu cau cua nguoi dung, NULL = giao ngay)
-- =============================================
IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID('Orders') AND name = 'scheduled_at'
)
BEGIN
    ALTER TABLE Orders ADD scheduled_at DATETIME2 NULL;
END
GO

-- =============================================
-- Migration: Tao bang Feedback_Images
-- (luu URL anh dinh kem cua danh gia)
-- =============================================
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Feedback_Images'
)
BEGIN
    CREATE TABLE Feedback_Images (
        id          BIGINT        PRIMARY KEY IDENTITY(1,1),
        feedback_id BIGINT        NOT NULL,
        image_url   NVARCHAR(500) NOT NULL,
        created_at  DATETIME2     DEFAULT GETDATE(),
        CONSTRAINT FK_FeedbackImage_Feedback FOREIGN KEY (feedback_id) REFERENCES Feedbacks(id) ON DELETE CASCADE
    );
    CREATE INDEX IDX_FeedbackImage_Feedback ON Feedback_Images(feedback_id);
END
GO

-- =============================================
-- Migration: Tao bang Combos, Combo_Items, Flash_Sales
-- =============================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Combos')
BEGIN
    CREATE TABLE Combos (
        id          BIGINT        PRIMARY KEY IDENTITY(1,1),
        shop_id     BIGINT        NOT NULL,
        name        NVARCHAR(200) NOT NULL,
        description NVARCHAR(500) NULL,
        combo_price DECIMAL(12,2) NOT NULL,
        is_active   BIT           NOT NULL DEFAULT 1,
        created_at  DATETIME2     DEFAULT GETDATE(),
        updated_at  DATETIME2     DEFAULT GETDATE(),
        CONSTRAINT FK_Combo_Shop FOREIGN KEY (shop_id) REFERENCES Shops(id) ON DELETE CASCADE
    );
    CREATE INDEX IDX_Combo_Shop ON Combos(shop_id);
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Combo_Items')
BEGIN
    CREATE TABLE Combo_Items (
        id              BIGINT PRIMARY KEY IDENTITY(1,1),
        combo_id        BIGINT NOT NULL,
        product_id      BIGINT NOT NULL,
        product_size_id BIGINT NOT NULL,
        quantity        INT    NOT NULL DEFAULT 1,
        CONSTRAINT FK_ComboItem_Combo   FOREIGN KEY (combo_id)        REFERENCES Combos(id)        ON DELETE CASCADE,
        CONSTRAINT FK_ComboItem_Product FOREIGN KEY (product_id)      REFERENCES Products(id),
        CONSTRAINT FK_ComboItem_Size    FOREIGN KEY (product_size_id) REFERENCES Product_Sizes(id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Flash_Sales')
BEGIN
    CREATE TABLE Flash_Sales (
        id              BIGINT        PRIMARY KEY IDENTITY(1,1),
        shop_id         BIGINT        NOT NULL,
        product_size_id BIGINT        NOT NULL,
        sale_price      DECIMAL(12,2) NOT NULL,
        start_time      DATETIME2     NOT NULL,
        end_time        DATETIME2     NOT NULL,
        is_active       BIT           NOT NULL DEFAULT 1,
        created_at      DATETIME2     DEFAULT GETDATE(),
        CONSTRAINT FK_FlashSale_Shop FOREIGN KEY (shop_id)         REFERENCES Shops(id),
        CONSTRAINT FK_FlashSale_Size FOREIGN KEY (product_size_id) REFERENCES Product_Sizes(id)
    );
    CREATE INDEX IDX_FlashSale_Shop ON Flash_Sales(shop_id);
    CREATE INDEX IDX_FlashSale_Size ON Flash_Sales(product_size_id);
END
GO

-- =============================================
-- Migration: Shop Wallet System
-- Shop_Wallets, Shop_Wallet_Transactions, Shop_Withdrawals
-- =============================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shop_Wallets')
BEGIN
    CREATE TABLE Shop_Wallets (
        id           BIGINT        PRIMARY KEY IDENTITY(1,1),
        shop_id      BIGINT        NOT NULL UNIQUE,
        balance      DECIMAL(14,2) NOT NULL DEFAULT 0,
        total_earned DECIMAL(14,2) NOT NULL DEFAULT 0,
        total_withdrawn DECIMAL(14,2) NOT NULL DEFAULT 0,
        updated_at   DATETIME2     DEFAULT GETDATE(),
        CONSTRAINT FK_ShopWallet_Shop FOREIGN KEY (shop_id) REFERENCES Shops(id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shop_Wallet_Transactions')
BEGIN
    CREATE TABLE Shop_Wallet_Transactions (
        id          BIGINT        PRIMARY KEY IDENTITY(1,1),
        shop_id     BIGINT        NOT NULL,
        type        VARCHAR(20)   NOT NULL CHECK (type IN ('EARNING','WITHDRAWAL','REFUND')),
        amount      DECIMAL(14,2) NOT NULL,
        order_id    BIGINT        NULL,
        description NVARCHAR(500) NOT NULL,
        created_at  DATETIME2     DEFAULT GETDATE(),
        CONSTRAINT FK_ShopWalletTx_Shop  FOREIGN KEY (shop_id)  REFERENCES Shops(id),
        CONSTRAINT FK_ShopWalletTx_Order FOREIGN KEY (order_id) REFERENCES Orders(id) ON DELETE SET NULL
    );
    CREATE INDEX IDX_ShopWalletTx_Shop ON Shop_Wallet_Transactions(shop_id);
    CREATE INDEX IDX_ShopWalletTx_Order ON Shop_Wallet_Transactions(order_id);
END
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Shop_Withdrawals')
BEGIN
    CREATE TABLE Shop_Withdrawals (
        id                  BIGINT        PRIMARY KEY IDENTITY(1,1),
        shop_id             BIGINT        NOT NULL,
        amount              DECIMAL(14,2) NOT NULL,
        bank_name           NVARCHAR(100) NOT NULL,
        bank_account_number VARCHAR(50)   NOT NULL,
        bank_account_holder NVARCHAR(200) NOT NULL,
        status              VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                                CHECK (status IN ('PENDING','APPROVED','REJECTED')),
        reject_reason       NVARCHAR(500) NULL,
        requested_at        DATETIME2     DEFAULT GETDATE(),
        processed_at        DATETIME2     NULL,
        processed_by        BIGINT        NULL,
        CONSTRAINT FK_ShopWithdrawal_Shop FOREIGN KEY (shop_id) REFERENCES Shops(id),
        CONSTRAINT FK_ShopWithdrawal_Admin FOREIGN KEY (processed_by) REFERENCES Accounts(id)
    );
    CREATE INDEX IDX_ShopWithdrawal_Shop   ON Shop_Withdrawals(shop_id);
    CREATE INDEX IDX_ShopWithdrawal_Status ON Shop_Withdrawals(status);
END
GO

-- Them cot payment_status vao Orders neu chua co (idempotent)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'cancel_reason')
    ALTER TABLE Orders ADD cancel_reason NVARCHAR(500) NULL;
GO

-- =============================================
-- Migration: Refund Requests (hoàn tiền cho khách)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Refund_Requests')
BEGIN
    CREATE TABLE Refund_Requests (
        id                  BIGINT        PRIMARY KEY IDENTITY(1,1),
        order_id            BIGINT        NOT NULL UNIQUE,
        account_id          BIGINT        NOT NULL,
        amount              DECIMAL(14,2) NOT NULL,
        bank_name           NVARCHAR(100) NOT NULL,
        bank_account_number VARCHAR(50)   NOT NULL,
        bank_account_holder NVARCHAR(200) NOT NULL,
        note                NVARCHAR(500) NULL,
        status              VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                                CHECK (status IN ('PENDING','COMPLETED','REJECTED')),
        reject_reason       NVARCHAR(500) NULL,
        requested_at        DATETIME2     DEFAULT GETDATE(),
        processed_at        DATETIME2     NULL,
        processed_by        BIGINT        NULL,
        CONSTRAINT FK_RefundReq_Order   FOREIGN KEY (order_id)    REFERENCES Orders(id),
        CONSTRAINT FK_RefundReq_Account FOREIGN KEY (account_id)  REFERENCES Accounts(id),
        CONSTRAINT FK_RefundReq_Admin   FOREIGN KEY (processed_by) REFERENCES Accounts(id)
    );
    CREATE INDEX IDX_RefundReq_Account ON Refund_Requests(account_id);
    CREATE INDEX IDX_RefundReq_Status  ON Refund_Requests(status);
END
GO

-- =============================================================
-- Nguon: migration_orders_status_constraint.sql
-- Drop CHECK constraint cũ trên Orders.status và tạo lại cho phép
-- tất cả status values mà application sử dụng.
-- =============================================================
USE POB;
GO

DECLARE @constraintName NVARCHAR(256);
DECLARE @sql NVARCHAR(MAX);

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
    SELECT cc.name
    FROM sys.check_constraints cc
    INNER JOIN sys.columns c
        ON cc.parent_object_id = c.object_id
        AND cc.parent_column_id = c.column_id
    WHERE cc.parent_object_id = OBJECT_ID('Orders')
      AND c.name = 'status';

OPEN cur;
FETCH NEXT FROM cur INTO @constraintName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'ALTER TABLE [Orders] DROP CONSTRAINT [' + @constraintName + ']';
    EXEC sp_executesql @sql;
    FETCH NEXT FROM cur INTO @constraintName;
END

CLOSE cur;
DEALLOCATE cur;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_Orders_Status' AND parent_object_id = OBJECT_ID('Orders')
)
ALTER TABLE [Orders] ADD CONSTRAINT CK_Orders_Status
    CHECK ([status] IN (
        'PENDING',
        'CONFIRMED',
        'READY_FOR_PICKUP',
        'WAITING_FOR_SHIPPER',
        'ACCEPTED',
        'SHIPPING',
        'DONE',
        'CANCELLED'
    ));
GO

-- =============================================================
-- Nguon: migration_database_performance.sql
-- =============================================================
-- Chay script migration_database_performance.sql rieng de tao bo chi muc toi uu toan he thong.
-- Khong lap lai o day: file migration_all duoc dung cho khoi tao schema, con chi muc nen duoc
-- ap dung co chu dong tren DB dang van hanh de co the theo doi thoi gian va dung luong.
-- Sau khi khoi tao/cap nhat schema, chay them migration_relationship_integrity.sql de bat buoc
-- cac lien ket du lieu va trigger kiem tra quan he nghiep vu.

-- =============================================================
-- Nguon: migration_shipper_review_performance.sql
-- =============================================================
-- Toi uu /shipper/danh-gia: loc don DONE cua mot shipper, sap xep moi nhat.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.Orders')
      AND name = N'IX_Orders_Shipper_Status_UpdatedAt'
)
BEGIN
    CREATE INDEX IX_Orders_Shipper_Status_UpdatedAt
        ON dbo.Orders (shipper_id, status, updated_at DESC)
        INCLUDE (shop_id, receiver_name, receiver_phone, shipping_address, total_price);
END
GO
