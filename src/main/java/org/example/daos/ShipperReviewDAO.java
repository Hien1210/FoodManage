package org.example.daos;

import org.example.models.ShipperReviewOrder;
import java.util.List;

/** Queries dedicated to the shipper review page. */
public interface ShipperReviewDAO {
    List<ShipperReviewOrder> findCompletedOrders(long shipperId);
}
