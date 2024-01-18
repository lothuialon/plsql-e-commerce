create or replace package error_package is

  -- Author  : CAN
  -- Created : 1/5/2024 12:31:51 AM
  -- Purpose : defines custom errors of the project

  --procedure to log errors into a database with autonomous transaction
  procedure log_error(v_error_message varchar2, v_error_location varchar2);

  --exceptions
  e_user_not_found_exception exception;
  pragma exception_init(e_user_not_found_exception, -20202);
  e_reset_code_not_found_exception exception;
  pragma exception_init(e_reset_code_not_found_exception, -20203);
  e_product_not_found_exception exception;
  pragma exception_init(e_product_not_found_exception, -20204);
  e_category_not_found_exception exception;
  pragma exception_init(e_category_not_found_exception, -20205);
  e_duplicate_product_exception exception;
  pragma exception_init(e_duplicate_product_exception, -20206);
  e_duplicate_category_exception exception;
  pragma exception_init(e_duplicate_category_exception, -20207);
  e_illegal_category_exception exception;
  pragma exception_init(e_illegal_category_exception, -20208);
  e_illegal_orderby_exception exception;
  pragma exception_init(e_illegal_orderby_exception, -20209);
  e_illegal_pagination_exception exception;
  pragma exception_init(e_illegal_pagination_exception, -20210);
  e_item_not_found_exception exception;
  pragma exception_init(e_item_not_found_exception, -20211);
  e_product_not_active_exception exception;
  pragma exception_init(e_product_not_active_exception, -20212);
  e_cart_not_found_exception exception;
  pragma exception_init(e_cart_not_found_exception, -20213);
  e_illegal_quantity_exception exception;
  pragma exception_init(e_illegal_quantity_exception, -20214);
  e_null_email_exception exception;
  pragma exception_init(e_null_email_exception, -20215);
  e_null_password_exception exception;
  pragma exception_init(e_null_password_exception, -20216);
  e_null_token_exception exception;
  pragma exception_init(e_null_token_exception, -20217);
  e_null_reset_code_exception exception;
  pragma exception_init(e_null_reset_code_exception, -20218);
  e_invalid_token_exception exception;
  pragma exception_init(e_invalid_token_exception, -20219);
  e_wrong_password_exception exception;
  pragma exception_init(e_wrong_password_exception, -20220);
  e_invalid_reset_code_exception exception;
  pragma exception_init(e_invalid_reset_code_exception, -20221);
  e_illegal_price_exception exception;
  pragma exception_init(e_illegal_price_exception, -20222);
  e_null_title_exception exception;
  pragma exception_init(e_null_title_exception, -20223);
  e_null_description_exception exception;
  pragma exception_init(e_null_description_exception, -20224);
  e_invalid_sort_value_exception exception;
  pragma exception_init(e_invalid_sort_value_exception, -20225);
  e_already_favorited_exception exception;
  pragma exception_init(e_already_favorited_exception, -20226);
  e_not_favorited_exception exception;
  pragma exception_init(e_not_favorited_exception, -20227);
  e_order_not_found_exception exception;
  pragma exception_init(e_order_not_found_exception, -20228);
  e_null_cart_exception exception;
  pragma exception_init(e_null_cart_exception, -20229);
  e_invalid_payment_option_exception exception;
  pragma exception_init(e_invalid_payment_option_exception, -20230);
  e_null_input_exception exception;
  pragma exception_init(e_null_input_exception, -20231);
  e_invalid_order_cancel_exception exception;
  pragma exception_init(e_invalid_order_cancel_exception, -20232);
  e_invalid_order_status_exception exception;
  pragma exception_init(e_invalid_order_status_exception, -20233);  
  e_null_name_exception exception;
  pragma exception_init(e_null_name_exception, -20234);  
  e_duplicate_email_exception exception;
  pragma exception_init(e_duplicate_email_exception, -20235);  
  e_user_blocked_exception exception;
  pragma exception_init(e_user_blocked_exception, -20236);  
  e_payment_is_null_exception exception;
  pragma exception_init(e_payment_is_null_exception, -20237);  
  
  
  
  
  
end error_package;
/
create or replace package body error_package is

  --procedure to log errors into a database with autonomous transaction
  procedure log_error(v_error_message varchar2, v_error_location varchar2) is
    pragma autonomous_transaction;
  
  begin
  
    insert into error_log
      (error_message, error_location, error_timestamp)
    values
      (v_error_message, v_error_location, systimestamp);
  
    commit;
  
  exception
    when others then
      rollback;
    
  end log_error;

end error_package;
/
