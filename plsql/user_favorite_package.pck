create or replace package user_favorite_package is

  -- Author  : CAN
  -- Created : 1/4/2024 7:36:43 PM
  -- Purpose : defines functionalities of adding, removing and listing user favorites

  --procedure for favoriting product for user if it is not favorited before
  procedure add_favorite(v_token varchar2, v_product_id number);

  --procedure for defavoriting product for user if it is favorited before
  procedure remove_favorite(v_token varchar2, v_product_id number);

  --function for returning a table of user favorited products using pipelined
  function get_favorites(v_token varchar2) return type_package.t_favorite pipelined;


end user_favorite_package;
/
create or replace package body user_favorite_package is

  --procedure for favoriting product for user if it is not favorited before
  procedure add_favorite(v_token varchar2, v_product_id number) is
  v_user_id number;
  begin
    
   --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
  
    --check the product
    if not utility_package.product_exists(v_product_id => v_product_id) then
      raise_application_error(-20204, 'Product not found for : ' || v_product_id);
    end if;
  
    if utility_package.is_favorite(v_user_id    => v_user_id,
                                   v_product_id => v_product_id) then
      raise_application_error(-20226, 'Product is already favorited: ' || v_product_id);
    end if;
  
    --start the process if there is no error 
    insert into favorites
      (user_id, product_id)
    values
      (v_user_id, v_product_id);
  
    commit;
  
  exception
    
    when error_package.e_product_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_favorite_package, add_favorite');
    
    when error_package.e_already_favorited_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_favorite_package, add_favorite');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_favorite_package, add_favorite');
    
  end add_favorite;

  --procedure for defavoriting product for user if it is favorited before
  procedure remove_favorite(v_token varchar2, v_product_id number) is
    v_user_id number;
  begin
    
     --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);

 
    --check the product
    if not utility_package.product_exists(v_product_id => v_product_id) then
      raise_application_error(-20204, 'Product not found: ' || v_product_id);
    end if;
   
    --check if product in the favorited before by the user
  
    if not utility_package.is_favorite(v_user_id    => v_user_id,
                                       v_product_id => v_product_id) then
      raise_application_error(-20227, 'Product is not favorited: ' || v_product_id);
    end if;
  
    --continue if there is no error
  
    delete from favorites
     where user_id = v_user_id
       and product_id = v_product_id;
  
    commit;
  
  exception
    
    when error_package.e_product_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_favorite_package, remove_favorite');
    
    
    when error_package.e_not_favorited_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_favorite_package, remove_favorite');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_favorite_package, remove_favorite');
    
  end remove_favorite;

  --function for returning a list of user favorited products(refcursor or table of type?)
  function get_favorites(v_token varchar2) return type_package.t_favorite
    pipelined is
  v_user_id number;
  begin
    
   --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);

  
    --check user 
    if not utility_package.user_exists(v_user_id => v_user_id) then
      raise_application_error(-20202, 'User not found!');
    end if;
  
    for r in (select * from favorites where user_id = v_user_id) loop
      pipe row(r);
    end loop;
    return;
  
  exception
  
    when error_package.e_user_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'user_favorite_package, get_favorites');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'user_favorite_package, remove_favorite');
    
  end get_favorites;


end user_favorite_package;
/
