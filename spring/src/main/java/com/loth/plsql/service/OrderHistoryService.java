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
import java.sql.Types;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class OrderHistoryService {

    private final JdbcTemplate jdbcTemplate;

    public OrderHistoryService(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public List<Map<String, Object>> getOrderHistory(String token) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("ORDER_HISTORY_PACKAGE")
                .withFunctionName("GET_ORDER_HISTORY")
                .returningResultSet("GET_ORDER_HISTORY", (ResultSet rs, int rowNum) -> {
                    Map<String, Object> row = new HashMap<>();
                    ResultSetMetaData metaData = rs.getMetaData();
                    int columnCount = metaData.getColumnCount();

                    for (int i = 1; i <= columnCount; i++) {
                        row.put(metaData.getColumnName(i), rs.getObject(i));
                    }

                    return row;
                });

        SqlParameterSource inParams = new MapSqlParameterSource()
                .addValue("V_TOKEN", token);

        Map<String, Object> result = simpleJdbcCall.execute(inParams);
        return (List<Map<String, Object>>) result.get("GET_ORDER_HISTORY");
    }

    public void exportOrderHistory(String token) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("ORDER_HISTORY_PACKAGE")
                .withProcedureName("EXPORT_ORDER_HISTORY")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_TOKEN", token);

        simpleJdbcCall.execute(inParams);
    }
}
