package com.loth.plsql.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.sql.ResultSetMetaData;
import java.sql.Types;


@Service
public class CartService {

    private final JdbcTemplate jdbcTemplate;

    public CartService(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public void addProductToCart(String token, int productId, int quantity) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("CART_PACKAGE")
                .withProcedureName("ADD_PRODUCT_TO_CART")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR),
                        new SqlParameter("v_product_id", Types.NUMERIC),
                        new SqlParameter("v_quantity", Types.NUMERIC)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_TOKEN", token);
        inParams.put("V_PRODUCT_ID", productId);
        inParams.put("V_QUANTITY", quantity);

        simpleJdbcCall.execute(inParams);
    }

    public void removeProductFromCart(String token, int productId, int quantity) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("CART_PACKAGE")
                .withProcedureName("REMOVE_PRODUCT_FROM_CART")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR),
                        new SqlParameter("v_product_id", Types.NUMERIC),
                        new SqlParameter("v_quantity", Types.NUMERIC)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_TOKEN", token);
        inParams.put("V_PRODUCT_ID", productId);
        inParams.put("V_QUANTITY", quantity);

        simpleJdbcCall.execute(inParams);
    }

    public void removeAllProductsFromCart(String token) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("CART_PACKAGE")
                .withProcedureName("REMOVE_ALL_PRODUCTS_FROM_CART")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_TOKEN", token);

        simpleJdbcCall.execute(inParams);
    }


public List<Map<String, Object>> getCartInformation(String token) {
    SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
            .withCatalogName("CART_PACKAGE")
            .withFunctionName("GET_CART_INFORMATION")
            .returningResultSet("GET_CART_INFORMATION", new RowMapper<Map<String, Object>>() {
                @Override
                public Map<String, Object> mapRow(ResultSet rs, int rowNum) throws SQLException {
                    Map<String, Object> row = new HashMap<>();
                    ResultSetMetaData metaData = rs.getMetaData();
                    int columnCount = metaData.getColumnCount();

                    for (int i = 1; i <= columnCount; i++) {
                        row.put(metaData.getColumnName(i), rs.getObject(i));
                    }

                    return row;
                }
            });

    SqlParameterSource inParams = new MapSqlParameterSource()
            .addValue("V_TOKEN", token);

    Map<String, Object> result = simpleJdbcCall.execute(inParams);
    return (List<Map<String, Object>>) result.get("GET_CART_INFORMATION");
}

}
