package com.loth.plsql.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;
import java.sql.Types;

@Service
public class OrderService {

    private final JdbcTemplate jdbcTemplate;

    public OrderService(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public void purchaseCart(String token, int paymentOptionId) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("ORDER_PACKAGE")
                .withProcedureName("PURCHASE_CART")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR),
                        new SqlParameter("v_payment_option_id", Types.NUMERIC)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_TOKEN", token);
        inParams.put("V_PAYMENT_OPTION_ID", paymentOptionId);

        simpleJdbcCall.execute(inParams);
    }

    public void updateTracking(int orderId, String trackingCode, String shippingCompanyName) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("ORDER_PACKAGE")
                .withProcedureName("UPDATE_TRACKING")
                .declareParameters(
                        new SqlParameter("v_order_id", Types.NUMERIC),
                        new SqlParameter("v_tracking_code", Types.VARCHAR),
                        new SqlParameter("v_shipping_company_name", Types.VARCHAR)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_ORDER_ID", orderId);
        inParams.put("V_TRACKING_CODE", trackingCode);
        inParams.put("V_SHIPPING_COMPANY_NAME", shippingCompanyName);

        simpleJdbcCall.execute(inParams);
    }

    public void cancelOrder(String token, int orderId) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("ORDER_PACKAGE")
                .withProcedureName("CANCEL_ORDER")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR),
                        new SqlParameter("v_order_id", Types.NUMERIC)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_TOKEN", token);
        inParams.put("V_ORDER_ID", orderId);

        simpleJdbcCall.execute(inParams);
    }
}
