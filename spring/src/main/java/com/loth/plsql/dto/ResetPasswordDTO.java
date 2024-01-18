package com.loth.plsql.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ResetPasswordDTO  {

    private String email;
    private String resetCode;
    private String newPassword;

}
