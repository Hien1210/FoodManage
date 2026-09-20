package org.example.models;

import java.time.LocalDateTime;

public class FlashSale {
    private long id;
    private long shopId;
    private long productSizeId;
    private double salePrice;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private boolean active;
    private LocalDateTime createdAt;
    private String productName;
    private String sizeName;
    private double originalPrice;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getShopId() { return shopId; }
    public void setShopId(long shopId) { this.shopId = shopId; }
    public long getProductSizeId() { return productSizeId; }
    public void setProductSizeId(long productSizeId) { this.productSizeId = productSizeId; }
    public double getSalePrice() { return salePrice; }
    public void setSalePrice(double salePrice) { this.salePrice = salePrice; }
    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getSizeName() { return sizeName; }
    public void setSizeName(String sizeName) { this.sizeName = sizeName; }
    public double getOriginalPrice() { return originalPrice; }
    public void setOriginalPrice(double originalPrice) { this.originalPrice = originalPrice; }

    public boolean isCurrentlyActive() {
        if (!active) return false;
        LocalDateTime now = LocalDateTime.now();
        return !now.isBefore(startTime) && !now.isAfter(endTime);
    }

    /** Đang bật nhưng chưa tới giờ bắt đầu (hiển thị nhãn "Sắp diễn ra" ở trang shop). */
    public boolean isUpcoming() {
        return active && startTime != null && LocalDateTime.now().isBefore(startTime);
    }

    /** Đã quá giờ kết thúc. */
    public boolean isEnded() {
        return endTime != null && LocalDateTime.now().isAfter(endTime);
    }
}
