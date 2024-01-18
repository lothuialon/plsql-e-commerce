create or replace package utility_package is

  -- Author  : CAN
  -- Created : 12/31/2023 4:00:41 PM
  -- Purpose : defining functions for common checks for user, product etc

  --checks if an user with given id exists
  function user_exists(v_user_id number) return boolean result_cache;

  --checks if an user with given email exists
  function user_exists(v_user_email varchar2) return boolean result_cache;

  --checks if a product with given id exists
  function product_exists(v_product_id number) return boolean result_cache;

  --checks if a category with given id exists
  function category_exists(v_category_id number) return boolean result_cache;

  --checks if an order with given id exists
  function order_exists(v_order_id number) return boolean result_cache;

  --checks if user has favorited the given item 
  function is_favorite(v_user_id number, v_product_id number) return boolean;

  --return the status of an order
  function get_order_status(v_order_id number) return varchar2;

  --checks if a payment option exists for the user                                  
  function payment_option_exists(v_user_id           number,
                                 v_payment_option_id number) return boolean result_cache;

  --checks if a product with given id exists and active
  function product_exists_and_active(v_product_id number) return boolean;

  --checks if the given product is inside the given cart 
  function product_inside_cart(v_cart_id number, v_product_id number)
    return boolean;

  --checks if the given cart is empty or not 
  function is_cart_empty(v_cart_id number) return boolean;

  --checks if a product with given title and description exists
  function product_duplicate_exists(v_title       varchar2,
                                    v_description varchar2) return boolean result_cache;

  --returns the cart id of the given user                                  
  function get_cart_id(v_user_id number) return number result_cache;

  --returns the cart data of the given user                                  
  function get_cart_data(v_user_id number) return cart%rowtype;

end utility_package;
/
create or replace package body utility_package is

  --used result caching
  function user_exists(v_user_id number) return boolean result_cache is
  
    v_count number;
  begin
  
    select count(*) into v_count from users where user_id = v_user_id;
  
    if v_count = 0 then
      return false;
    else
      return true;
    
    end if;
  
  end user_exists;

  --used result caching
  function user_exists(v_user_email varchar2) return boolean result_cache is
  
    v_count number;
  begin
  
    select count(*) into v_count from users where email = v_user_email;
  
    if v_count = 0 then
      return false;
    else
      return true;
    
    end if;
  
  end user_exists;
  
  --used result caching
  function product_exists(v_product_id number) return boolean result_cache is
    v_count number;
  begin
  
    select count(*)
      into v_count
      from products
     where product_id = v_product_id;
  
    if v_count = 1 then
      return true;
    else
      return false;
    end if;
  
  end product_exists;
  
  --used result caching
  function category_exists(v_category_id number) return boolean result_cache is
    v_count number;
  begin
  
    select count(*)
      into v_count
      from product_categories
     where category_id = v_category_id;
  
    if v_count = 0 then
      return false;
    else
      return true;
    end if;
  
  end category_exists;

  --used result caching
  function order_exists(v_order_id number) return boolean result_cache is
    v_count number;
  begin
  
    select count(*) into v_count from orders where order_id = v_order_id;
  
    if v_count = 0 then
      return false;
    else
      return true;
    end if;
  
  end order_exists;

  --checks if user has favorited the given item 
  function is_favorite(v_user_id number, v_product_id number) return boolean is
  
    v_count number;
  begin
  
    select count(*)
      into v_count
      from favorites
     where v_user_id = user_id
       and v_product_id = product_id;
  
    if v_count = 0 then
      return false;
    else
      return true;
    end if;
  
  end is_favorite;

  function get_order_status(v_order_id number) return varchar2 is
    v_order_status varchar2(30);
  begin
  
    select os.order_status_name
      into v_order_status
      from orders o, order_status os
     where o.order_status_id = os.order_status_id
       and o.order_id = v_order_id;
  
    return v_order_status;
  
  end get_order_status;

  function product_exists_and_active(v_product_id number) return boolean is
  
    v_count number;
  begin
  
    select count(*)
      into v_count
      from products
     where product_id = v_product_id
       and is_active = 1;
  
    if v_count = 0 then
      return false;
    else
      return true;
    end if;
  
  end product_exists_and_active;

  function product_inside_cart(v_cart_id number, v_product_id number)
    return boolean is
    v_count number;
  begin
  
    select count(*)
      into v_count
      from cart_item
     where cart_id = v_cart_id
       and product_id = v_product_id;
  
    if v_count = 0 then
      return false;
    else
      return true;
    end if;
  end product_inside_cart;

  --used result caching
  function product_duplicate_exists(v_title       varchar2,
                                    v_description varchar2) return boolean result_cache is
    v_count number;
  begin
    select count(*)
      into v_count
      from products
     where title = v_title
       and description = v_description
       and is_Active = 1; --todo 
  
    if v_count = 0 then
      return false;
    else
      return true;
    end if;
  
  end product_duplicate_exists;

  --returns the cart id of the given user  
  --used result caching                                
  function get_cart_id(v_user_id number) return number result_cache is
    v_cart_id number;
  begin
  
    select cart_id into v_cart_id from cart where user_id = v_user_id;
  
    return v_cart_id;
  
  end get_cart_id;

  --returns the cart data of the given user                                  
  function get_cart_data(v_user_id number) return cart%rowtype is
    r_cart cart%rowtype;
  begin
  
    select * into r_cart from cart where user_id = v_user_id;
  
    return r_cart;
  
  end get_cart_data;

  --checks if the given cart is empty or not 
  function is_cart_empty(v_cart_id number) return boolean is
    v_count number;
  begin
  
    select count(*) into v_count from cart_item where cart_id = v_cart_id;
  
    if v_count = 0 then
      return true;
    else
      return false;
    end if;
  
  end is_cart_empty;

  --checks if a payment option exists for the user 
  --used result caching        
  --todo test                         
  function payment_option_exists(v_user_id           number,
                                 v_payment_option_id number) return boolean result_cache is
    v_count number;
  begin
  
    select count(*)
      into v_count
      from users u, payment_option po
     where u.user_id = po.user_id
       and po.payment_option_id = v_payment_option_id
       and u.user_id = v_user_id;
  
    if v_count = 0 then
      return false;
    else
      return true;
    end if;
  
  end payment_option_exists;

end utility_package;
/
