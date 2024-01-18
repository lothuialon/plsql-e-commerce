create or replace package user_package is

  -- Author  : CAN
  -- Created : 12/28/2023 10:47:25 PM
  -- Purpose : defining user login, and session functionalities

  --defining absolute variables to be used
  v_LOGIN_ATTEMPTS constant number := 3;

  --function for checking if given password correct for user and returns a token if correct
  function authenticate_user(v_email in varchar2, v_password in varchar2)
    return varchar2;

  --procedure for creating a user
  procedure register_user(v_first_name varchar2,
                          v_last_name  varchar2,
                          v_email      varchar2,
                          v_password   varchar2);

  --removes user and its token from session table         
  procedure logout(v_token in varchar2);

  --function that verifies the token 
  function verify_token(v_token in varchar2) return number;

  --function for creating a session token for user if there isn't any valid token 
  function generate_token(v_user_id in number) return varchar2;

  --function to randomly generate salt
  function generate_salt return varchar2;

  --procedure that checks and updates user status if necessary
  procedure check_status(v_user_id in number);

  --procedure for adding payment option
  procedure add_payment_option(v_token        in varchar2,
                               v_payment_name varchar2);

end user_package;
/
create or replace package body user_package is

  function authenticate_user(v_email in varchar2, v_password in varchar2)
    return varchar2 is
    v_token             varchar2(30);
    v_user_id           number;
    v_hashed_password   varchar2(256);
    v_password_salt     varchar2(30);
    v_hashing_algorithm varchar2(10);
    v_status            varchar2(30);
  begin
  
    --check the inputs for null values
    if trim(v_email) is null then
      raise_application_error(-20215, 'Email is empty');
    end if;
  
    if trim(v_password) is null then
      raise_application_error(-20216, 'Password is empty');
    end if;
  
    --check if a user exists for given email
    if not utility_package.user_exists(v_user_email => v_email) then
      raise_application_error(-20202,
                              'User not found for given email: ' || v_email);
    end if;
  
    --gets information related authentication from the tables for given email
    select u.user_id,
           p.hashed_password,
           p.password_salt,
           p.hashing_algorithm,
           us.status
      into v_user_id,
           v_hashed_password,
           v_password_salt,
           v_hashing_algorithm,
           v_status
      from users u, passwords p, user_status us
     where u.password_id = p.password_id
       and u.email = v_email
       and u.status_id = us.status_id;
  
    --check if account is blocked
    if v_status = 'BLOCKED' then
      raise_application_error(-20236,
                              'User is blocked for user id: ' || v_user_id);
    end if;
  
    --check if hashed password password matches to the stored password
    --and returns a token if it is correct
    if (dbms_crypto.hash(utl_raw.cast_to_raw(v_password || v_password_salt),
                         dbms_crypto.HASH_SH256) = v_hashed_password) then
    
      v_token := generate_token(v_user_id);
      return v_token;
    
    else
      --updates the user status if the authentication fails
      update_status(v_user_id);
    
      --raise error to avoid returning a null value
      raise_application_error(-20220,
                              'Password is wrong for given user: ' ||
                              v_email);
    end if;
  
  exception
  
    when error_package.e_user_not_found_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, authenticate_user');
    
    when error_package.e_wrong_password_exception then
    
      --update the user status if the authentication fails
      update_status(v_user_id);
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, authenticate_user');
    
    when error_package.e_null_email_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, authenticate_user');
    when error_package.e_null_password_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, authenticate_user');
    
    when error_package.e_user_blocked_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, authenticate_user');
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_package, authenticate_user');
  end authenticate_user;

  --procedure for creating a user
  procedure register_user(v_first_name varchar2,
                          v_last_name  varchar2,
                          v_email      varchar2,
                          v_password   varchar2) is
  
    v_password_id   number;
    v_password_salt varchar2(30);
  begin
  
    --check the inputs for null values
    if trim(v_first_name) is null or trim(v_last_name) is null then
      raise_application_error(-20234, 'Name is empty');
    end if;
  
    if trim(v_email) is null then
      raise_application_error(-20215, 'Email is empty');
    end if;
  
    if trim(v_password) is null then
      raise_application_error(-20216, 'Password is empty');
    end if;
  
    if utility_package.user_exists(v_user_email => v_email) then
      raise_application_error(-20235,
                              'User already exists for this email: ' ||
                              v_email);
    end if;
  
    --insert the password if there is no problem
    v_password_id   := seq_password_id.nextval;
    v_password_salt := generate_salt();
  
    insert into passwords
      (password_id, password_salt, hashed_password)
    values
      (v_password_id,
       v_password_salt,
       dbms_crypto.hash(utl_raw.cast_to_raw(v_password || v_password_salt),
                        dbms_crypto.HASH_SH256));
  
    --insert the user into user table
    insert into users
      (user_id,
       password_id,
       status_id,
       first_name,
       last_name,
       email,
       create_date,
       update_date)
    values
      (seq_user_id.nextval,
       v_password_id,
       seq_status_id.nextval,
       v_first_name,
       v_last_name,
       v_email,
       sysdate,
       sysdate);
  
    commit;
  
  exception
  
    when error_package.e_null_name_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, register_user');
    
    when error_package.e_duplicate_email_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, register_user');
    
    when error_package.e_null_email_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, register_user');
    when error_package.e_null_password_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, register_user');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_package, register_user');
      rollback;
    
  end register_user;

  --removes user and its token from session table
  procedure logout(v_token in varchar2) is
    v_user_id number;
  begin
  
    --verify the token. assigns user id if it is successfull
    --user exists if the assign operation is succesfull
    v_user_id := user_package.verify_token(v_token => v_token);
  
    --remove from user session table
    delete from user_session where user_id = v_user_id;
  
    commit;
  
  exception
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_package, logout');
      rollback;
    
  end logout;

  --function that verifies the token and returns user_id if successful
  function verify_token(v_token in varchar2) return number is
    v_user_id number;
  begin
  
    if trim(v_token) is null then
      raise_application_error(-20217, 'Token is null');
    end if;
  
    --continue if token is not null
    select u.user_id
      into v_user_id
      from users u, user_session us
     where u.user_id = us.user_id
       and us.token = v_token
       and us.expire_date > trunc(sysdate);
    --no data found exception is used to handle invalid token request
  
    --return the user_id if there is no problem
    return v_user_id;
  
  exception
    when no_data_found then
      return null;
      raise_application_error(-20219, 'Token is invalid: ' || v_token);
    
    when error_package.e_invalid_token_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, verify_token');
    
    when error_package.e_null_token_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, verify_token');
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_package, verify_token');
    
  end verify_token;

  function generate_token(v_user_id in number) return varchar2 is
    v_token       varchar2(30);
    v_expire_date date;
  begin
  
    --get the token information if it exists
    --handled the no_data_found situation in the exception part
    select us.token, us.expire_date
      into v_token, v_expire_date
      from users u, user_session us
     where u.user_id = us.user_id
       and u.user_id = v_user_id;
  
    --continue if token exists
    --check token expire data and generate new one if current token is expired
    if v_expire_date < trunc(sysdate) then
    
      v_token := dbms_random.string('A', 30);
      update user_session
         set token       = v_token,
             create_date = trunc(sysdate),
             expire_date = trunc(sysdate) + 3
       where user_id = v_user_id;
    
      commit;
      return v_token;
    else
    
      --return current token if it is still valid
      return v_token;
    
    end if;
  
  exception
    --used to handle the no token found situation
    when no_data_found then
    
      --if there is no token in the database, insert it
      v_token := dbms_random.string('A', 30);
    
      insert into user_session
        (user_id, token, create_date, expire_date)
      values
        (v_user_id, v_token, trunc(sysdate), trunc(sysdate) + 3);
    
      commit;
      return v_token;
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_package, generate_token');
      rollback;
    
  end generate_token;

  --function that returns a randomly generated salt
  function generate_salt return varchar2 is
  begin
    return dbms_random.string('A', 30);
  
  exception
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_package, generate_salt');
    
  end generate_salt;

  --procedure to check and update user status when a failed login occurs
  procedure update_status(v_user_id in number) is
    pragma autonomous_transaction;
  
    v_status_id      number;
    v_login_attempts number;
  
  begin
  
    --get the status information of the user
    select us.status_id, us.login_attempts
      into v_status_id, v_login_attempts
      from user_status us, users u
     where us.status_id = u.status_id
       and u.user_id = v_user_id;
  
    --update status based on login attempts
    v_login_attempts := v_login_attempts + 1;
  
    --block the account if there are 3 login attemps 
    if v_login_attempts = v_LOGIN_ATTEMPTS then
      update user_status
         set status = 'BLOCKED', login_attempts = v_LOGIN_ATTEMPTS
       where status_id = v_status_id;
    
      --remove token of the user from user sessions 
      delete from user_session where user_id = v_user_id;
    
      --increase login attempts if threshhold is not reached
    else
      update user_status
         set login_attempts = v_login_attempts
       where status_id = v_status_id;
    end if;
  
    commit;
  
  exception
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_package, update_status');
      rollback;
    
  end check_status;

  --procedure for adding payment option
  procedure add_payment_option(v_token varchar2, v_payment_name varchar2) is
    v_user_id number;
  begin
  
    if trim(v_payment_name) is null then
      raise_application_error(-20237, 'Payment name is null!');
    end if;
  
    --verify the token, assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
  
    --check if user is valid --todo check if this is needed
    if not utility_package.user_exists(v_user_id => v_user_id) then
      raise_application_error(-20202, 'User not found!');
    end if;
  
    --insert into table
    insert into payment_option
      (user_id, payment_option_id, payment_name)
    values
      (v_user_id, seq_payment_option_id.nextval, v_payment_name);
  
    commit;
  
  exception
    when error_package.e_user_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, add_payment_option');
    
    when error_package.e_payment_is_null_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_package, add_payment_option');
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_package, add_payment_option');
      rollback;
  end;

end user_package;
/
