create or replace package password_reset_package is

  -- Author  : CAN
  -- Created : 12/28/2023 16:39:06 AM
  -- Purpose : defines password reset functionalities

  --procedure to initialize password resetting process, creates a reset code
  procedure reset_password(v_email in varchar2);

  --procedure to check if password reset code is correct
  procedure reset_code_check(v_reset_code   in varchar2,
                             v_new_password in varchar2,
                             v_email        in varchar2);

end password_reset_package;
/
create or replace package body password_reset_package is

  procedure reset_password(v_email in varchar2) is
    v_user_id     number;
    v_password_id number;
    v_reset_code  varchar2(10);
  
  begin
  
    --check if input is null or not
    if trim(v_email) is null then
      dbms_output.put_line(trim(v_email));
      raise_application_error(-20215, 'Email is null!');
    end if;
  
    --check if user exists
    if not utility_package.user_exists(v_user_email => v_email) then
      dbms_output.put_line(trim((v_email)));
      raise_application_error(-20202, 'User not found: ' || v_email);
    end if;
  
    --check if user has a reset code
    --no_data_found will be handled for no reset code situation
    select rc.reset_code, u.user_id, u.password_id
      into v_reset_code, v_user_id, v_password_id
      from users u, reset_codes rc
     where u.email = v_email
       and u.password_id = rc.password_id;
  
    --update the reset code if there is a previous one
    v_reset_code := dbms_random.string('A', 6);
    update reset_codes
       set reset_code = v_reset_code
     where password_id = v_password_id;
  
    commit;
  
  exception
    when no_data_found then
    
      --get data
      select user_id, password_id
        into v_user_id, v_password_id
        from users
       where email = v_email;
    
      --insert the reset code since there is no reset code associated with the user
      v_reset_code := dbms_random.string('A', 6);
      insert into reset_codes
        (password_id, reset_code)
      values
        (v_password_id, v_reset_code);
    
      commit;
    
    when error_package.e_user_not_found_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'password_reset_package, reset_password');
    
    when error_package.e_null_email_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'password_reset_package, reset_password');
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'password_reset_package, reset_password');
  end reset_password;

  --this procedure checks the given reset code and changes 
  --password with given one if reset code is correct
  procedure reset_code_check(v_reset_code   in varchar2,
                             v_new_password in varchar2,
                             v_email        in varchar2) is
    v_user_id          number;
    v_password_id      number;
    v_table_reset_code varchar2(10); --remove this just check it in sql
    v_password_salt    varchar2(30);
    v_hashed_password  varchar2(256);
  begin
  
    --check the inputs
    if trim(v_reset_code) is null then
      raise_application_error(-20218, 'Reset code is empty!');
    end if;
  
    if trim(v_new_password) is null then
      raise_application_error(-20216, 'Password is empty!');
    end if;
  
    if trim(v_email) is null then
      raise_application_error(-20215, 'Email is empty!');
    end if;
  
    if not utility_package.user_exists(v_user_email => v_email) then
      raise_application_error(-20202, 'User not found: ' || v_email);
    end if;
  
    --get user id and password and reset code from the database
    --no_data_found exception will be raised if user dont have a reset code
    select u.user_id, u.password_id, rc.reset_code
      into v_user_id, v_password_id, v_table_reset_code
      from users u, reset_codes rc
     where u.email = v_email
       and u.password_id = rc.password_id;
  
    --if users reset code equals the input, reset the password 
    if v_reset_code = v_table_reset_code then
    
      --generate new salt for new password and hash the new password into the table
      v_password_salt   := user_package.generate_salt();
      v_hashed_password := dbms_crypto.hash(utl_raw.cast_to_raw(v_new_password ||
                                                                v_password_salt),
                                            dbms_crypto.HASH_SH256);
    
      --update the password and password salt                                          
      update passwords
         set password_salt   = v_password_salt,
             hashed_password = v_hashed_password
       where password_id = v_password_id;
    
      --remove the reset code from the table
      delete from reset_codes where password_id = v_password_id;
    
      commit;
    
    else
      --raise error for invalid reset code
      raise_application_error(-20221,
                              'Invalid reset code: ' || v_reset_code);
    end if;
  exception
    when no_data_found then
      raise_application_error(-20203,
                              'Reset code not found:' || v_reset_code);
    
    when error_package.e_user_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'password_reset_package, reset_code_check');
    
    when error_package.e_null_reset_code_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'password_reset_package, reset_code_check');
    
    when error_package.e_null_password_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'password_reset_package, reset_code_check');
    
    when error_package.e_null_email_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'password_reset_package, reset_code_check');
    
    when error_package.e_reset_code_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'password_reset_package, reset_code_check');
    
    when error_package.e_invalid_reset_code_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'password_reset_package, reset_code_check');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'password_reset_package, reset_code_check');
      rollback;
    
  end reset_code_check;

end password_reset_package;
/
