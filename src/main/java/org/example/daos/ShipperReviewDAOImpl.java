package org.example.daos;

import org.example.models.ShipperReviewOrder;
import org.example.utils.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ShipperReviewDAOImpl implements ShipperReviewDAO {
    private static final String FIND_COMPLETED_ORDERS =
            "SELECT o.id, o.shop_id, o.receiver_name, o.receiver_phone, o.shipping_address, o.total_price, " +
            "       COALESCE(s.shop_name, CONCAT(N'Shop #', o.shop_id)) AS shop_name, " +
            "       CAST(CASE WHEN EXISTS (SELECT 1 FROM Feedbacks f " +
            "           WHERE f.order_id = o.id AND f.reviewer_type = N'SHIPPER' AND f.target_type = N'SHOP') " +
            "       THEN 1 ELSE 0 END AS BIT) AS feedback_shop " +
            "FROM Orders o LEFT JOIN Shops s ON s.id = o.shop_id " +
            "WHERE o.shipper_id = ? AND o.status = 'DONE' " +
            "ORDER BY o.updated_at DESC, o.id DESC";

    @Override
    public List<ShipperReviewOrder> findCompletedOrders(long shipperId) {
        List<ShipperReviewOrder> orders = new ArrayList<>();
        try (Connection connection = DBUtil.getConnection();
             PreparedStatement statement = connection.prepareStatement(FIND_COMPLETED_ORDERS)) {
            statement.setLong(1, shipperId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    ShipperReviewOrder order = new ShipperReviewOrder();
                    order.setId(resultSet.getLong("id"));
                    order.setShopId(resultSet.getLong("shop_id"));
                    order.setShopName(resultSet.getString("shop_name"));
                    order.setReceiverName(resultSet.getString("receiver_name"));
                    order.setReceiverPhone(resultSet.getString("receiver_phone"));
                    order.setShippingAddress(resultSet.getString("shipping_address"));
                    order.setTotalPrice(resultSet.getDouble("total_price"));
                    order.setFeedbackShop(resultSet.getBoolean("feedback_shop"));
                    orders.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }
}
