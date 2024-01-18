package com.loth.plsql.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.RowMapper;


@Service
public class ProductService {

    private final JdbcTemplate jdbcTemplate;

    public ProductService(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public void insertProduct(int categoryId, String title, String description, int quantity, double price) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PRODUCT_PACKAGE")
                .withProcedureName("INSERT_PRODUCT")
                .declareParameters(
                        new SqlParameter("v_category_id", Types.NUMERIC),
                        new SqlParameter("v_title", Types.VARCHAR),
                        new SqlParameter("v_description", Types.VARCHAR),
                        new SqlParameter("v_quantity", Types.NUMERIC),
                        new SqlParameter("v_price", Types.NUMERIC)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_CATEGORY_ID", categoryId);
        inParams.put("V_TITLE", title);
        inParams.put("V_DESCRIPTION", description);
        inParams.put("V_QUANTITY", quantity);
        inParams.put("V_PRICE", price);

        simpleJdbcCall.execute(inParams);
    }

    public void deleteProduct(int productId) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PRODUCT_PACKAGE")
                .withProcedureName("DELETE_PRODUCT")
                .declareParameters(
                        new SqlParameter("v_product_id", Types.NUMERIC)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_PRODUCT_ID", productId);

        simpleJdbcCall.execute(inParams);
    }

    
    public List<Map<String, Object>> filterProduct(int categoryId, String orderBy, int pageSize, int pageNumber, String sort) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PRODUCT_PACKAGE")
                .withFunctionName("FILTER_PRODUCT")
                .returningResultSet("FILTER_PRODUCT", new RowMapper<Map<String, Object>>() {
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
                .addValue("V_CATEGORY_ID", categoryId)
                .addValue("V_ORDER_BY", orderBy)
                .addValue("V_PAGE_SIZE", pageSize)
                .addValue("V_PAGE_NUMBER", pageNumber)
                .addValue("V_SORT", sort);
    
        Map<String, Object> result = simpleJdbcCall.execute(inParams);
        return (List<Map<String, Object>>) result.get("FILTER_PRODUCT");
    }
    
}
