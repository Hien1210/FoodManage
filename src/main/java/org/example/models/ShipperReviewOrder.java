package org.example.models;

/** Data projection for the shipper review page. */
public class ShipperReviewOrder {
    private long id;
    private long shopId;
    private String shopName;
    private String receiverName;
    private String receiverPhone;
    private String shippingAddress;
    private Double totalPrice;
    private boolean feedbackShop;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public long getShopId() { return shopId; }
    public void setShopId(long shopId) { this.shopId = shopId; }
    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }
    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }
    public String getReceiverPhone() { return receiverPhone; }
    public void setReceiverPhone(String receiverPhone) { this.receiverPhone = receiverPhone; }
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
    public Double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(Double totalPrice) { this.totalPrice = totalPrice; }
    public boolean isFeedbackShop() { return feedbackShop; }
    public void setFeedbackShop(boolean feedbackShop) { this.feedbackShop = feedbackShop; }
}
