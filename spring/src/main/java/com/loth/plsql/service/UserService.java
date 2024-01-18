package com.loth.plsql.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

@Service
public class UserService {

    private final JdbcTemplate jdbcTemplate;

    public UserService(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public String authenticateUser(String email, String password) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("USER_PACKAGE")
                .withFunctionName("AUTHENTICATE_USER")
                .declareParameters(
                        new SqlParameter("v_email", Types.VARCHAR),
                        new SqlParameter("v_password", Types.VARCHAR),
                        new SqlOutParameter("v_token", Types.VARCHAR)
                );
    
        Map<String, Object> inParams = new HashMap<>();
        inParams.put("V_EMAIL", email);
        inParams.put("V_PASSWORD", password);
    
        String token = simpleJdbcCall.executeFunction(String.class, inParams);
        return token;
    }
    
    public void registerUser(String firstName, String lastName, String email, String password) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("USER_PACKAGE")
                .withProcedureName("REGISTER_USER")
                .declareParameters(
                        new SqlParameter("v_first_name", Types.VARCHAR),
                        new SqlParameter("v_last_name", Types.VARCHAR),
                        new SqlParameter("v_email", Types.VARCHAR),
                        new SqlParameter("v_password", Types.VARCHAR)
                );

System.out.println(firstName + lastName + email + password);

                Map<String, Object> inParams = new HashMap<>();
                inParams.put("V_FIRST_NAME", firstName);
                inParams.put("V_LAST_NAME", lastName);
                inParams.put("V_EMAIL", email);
                inParams.put("V_PASSWORD", password);
                
        simpleJdbcCall.execute(inParams);
    }

    public void logout(String token) {
        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withCatalogName("USER_PACKAGE")
                .withProcedureName("LOGOUT")
                .declareParameters(
                        new SqlParameter("v_token", Types.VARCHAR)
                );

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("v_token", token);

        simpleJdbcCall.execute(inParams);
    }
}
