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
public class UserFavoriteService {

    private final JdbcTemplate jdbcTemplate;

    public UserFavoriteService(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public void addFavorite(String token, int productId) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("USER_FAVORITE_PACKAGE")
                .withProcedureName("ADD_FAVORITE")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR),
                        new SqlParameter("v_product_id", Types.NUMERIC)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_TOKEN", token);
        inParams.put("V_PRODUCT_ID", productId);

        simpleJdbcCall.execute(inParams);
    }

    public void removeFavorite(String token, int productId) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("USER_FAVORITE_PACKAGE")
                .withProcedureName("REMOVE_FAVORITE")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR),
                        new SqlParameter("v_product_id", Types.NUMERIC)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_TOKEN", token);
        inParams.put("V_PRODUCT_ID", productId);

        simpleJdbcCall.execute(inParams);
    }

    public List<Map<String, Object>> getFavorites(String token) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("USER_FAVORITE_PACKAGE")
                .withFunctionName("GET_FAVORITES")
                .returningResultSet("GET_FAVORITES", (ResultSet rs, int rowNum) -> {
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
        return (List<Map<String, Object>>) result.get("GET_FAVORITES");
    }
}
