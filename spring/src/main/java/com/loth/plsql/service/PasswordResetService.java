package com.loth.plsql.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;    
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

@Service
public class PasswordResetService {

    private final JdbcTemplate jdbcTemplate;

    public PasswordResetService(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public void resetPassword(String email) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PASSWORD_RESET_PACKAGE")
                .withProcedureName("RESET_PASSWORD")
                .declareParameters(
                        new SqlParameter("v_email", Types.VARCHAR)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_EMAIL", email);

        simpleJdbcCall.execute(inParams);
    }

    public void resetCodeCheck(String resetCode, String newPassword, String email) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("PASSWORD_RESET_PACKAGE")
                .withProcedureName("RESET_CODE_CHECK")
                .declareParameters(
                        new SqlParameter("v_reset_code", Types.VARCHAR),
                        new SqlParameter("v_new_password", Types.VARCHAR),
                        new SqlParameter("v_email", Types.VARCHAR)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_RESET_CODE", resetCode);
        inParams.put("V_NEW_PASSWORD", newPassword);
        inParams.put("V_EMAIL", email);

        simpleJdbcCall.execute(inParams);
    }
}

