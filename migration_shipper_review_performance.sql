-- Supports /shipper/danh-gia: completed orders for one shipper, newest first.
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

-- UQ_Feedback_Once(order_id, reviewer_type, target_type) already indexes the EXISTS predicate.
