create or replace package cart_package is

  -- Author  : CAN
  -- Created : 12/31/2023 12:34:28 AM
  -- Purpose : defines functionalities of cart   

  --procedure for adding a product to a cart if it is an active product
  procedure add_product_to_cart(v_token varchar2,
                                v_product_id number,
                                v_quantity   number default 1);

  --procedure for removing a product from the cart with given quantity                        
  procedure remove_product_from_cart(v_token varchar2,
                                     v_product_id number,
                                     v_quantity   number default 1);

  --procedure for removing all products from the cart                         
  procedure remove_all_products_from_cart(v_token varchar2);

  --function for getting all products in cart for given user
  function get_cart_information(v_token varchar2) return sys_refcursor;
  
  --recalculates cart total price                               
  procedure refresh_cart(v_cart_id number);
  
  --recalculates total prices of given carts                               
  procedure refresh_carts(t_cart_id type_package.t_cart_id);

end cart_package;
/
create or replace package body cart_package is

  --check if user, product and quantity is valid then add it to cart_item table and lastly recalculate cart
  procedure add_product_to_cart(v_token    varchar2,
                                v_product_id number,
                                v_quantity   number default 1) is
    v_user_id number;
    v_cart_id number;
    v_price   number;
  begin
  
    --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
    
    --check quantity for negative value                          
    if v_quantity < 1 then
      raise_application_error(-20214, 'Quantity cannot be less than 1');
    end if;
 
  
    --check if product is valid and active
    if not utility_package.product_exists(v_product_id => v_product_id) then
      raise_application_error(-20211, 'Product is not found!');
    end if;

  
    --start adding process
    --get cart id of the user
    v_cart_id := utility_package.get_cart_id(v_user_id => v_user_id);
  
    --get price of the product
    select price
      into v_price
      from products
     where product_id = v_product_id;
  
    --if product is not inside the cart, insert it
    if not utility_package.product_inside_cart(v_cart_id    => v_cart_id,
                                            v_product_id => v_product_id) then
    
      insert into cart_item
        (cart_id, product_id, quantity, item_total_price)
      values
        (v_cart_id, v_product_id, v_quantity, v_price * v_quantity);
    
      --update the quantity otherwise, get the item price by dividing old item total to old quantity
    else
      update cart_item
         set item_total_price = (quantity + v_quantity) * (item_total_price/quantity),
             quantity = quantity + v_quantity
       where cart_id = v_cart_id
         and product_id = v_product_id;
    
    end if;
  
    commit;
  
    --update cart total price
    refresh_cart(v_cart_id);
  
  exception

    when error_package.e_item_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'cart_package, add_product_to_cart');
    when error_package.e_illegal_quantity_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'cart_package, add_product_to_cart');
    when error_package.e_product_not_active_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'cart_package, add_product_to_cart');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' || sqlerrm,
                              v_error_location => 'cart_package, add_product_to_cart');
                              
      rollback;
    
  end add_product_to_cart;

  procedure remove_product_from_cart(v_token varchar2,
                                     v_product_id number,
                                     v_quantity   number default 1) is
    v_user_id number;
    v_cart_item_quantity number;
    v_cart_id            number;
  begin
   
  
   --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);

  
    --input checks
    --check if user is valid
    if not utility_package.user_exists(v_user_id => v_user_id) then
      raise_application_error(-20202, 'User not found!');
    end if;
  
    --check if product is valid and active
    if not utility_package.product_exists(v_product_id => v_product_id) then
      raise_application_error(-20211, 'Product is not found!');
    end if;
  
    if not
        utility_package.product_exists_and_active(v_product_id => v_product_id) then
      raise_application_error(-20212, 'Product not active!');
    end if;
  
    --check and validate quantity
  
    --get cart id and cart item quantity
    v_cart_id := utility_package.get_cart_id(v_user_id => v_user_id);
  
    select quantity
      into v_cart_item_quantity
      from cart_item
     where cart_id = v_cart_id
       and product_id = v_product_id;
  
    --delete from cart item delete quantity is equal or higher than cart item quantity
    if v_quantity > v_cart_item_quantity or
       v_quantity = v_cart_item_quantity then
    
      delete from cart_item
       where cart_id = v_cart_id
         and product_id = v_product_id;
    
      --update it otherwise   
    else
    
      update cart_item
         set item_total_price = (quantity - v_quantity) * (item_total_price/quantity),
             quantity = (v_cart_item_quantity - v_quantity)
       where cart_id = v_cart_id
         and product_id = v_product_id;
    
    end if;
  
    --commit;
    --committed in the refresh cart procedure
    refresh_cart(v_cart_id);
  
    --handle exceptions
  exception
    when error_package.e_user_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'cart_package, remove_product');
    
    when error_package.e_item_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'cart_package, remove_product');
    
    when error_package.e_product_not_active_exception then
    
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'cart_package, remove_product');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'cart_package, remove_product');
      rollback;
    
  end remove_product_from_cart;

  --done---
  procedure remove_all_products_from_cart(v_token varchar2) is
    v_cart_id number;
    v_user_id number;
  begin
    
   --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
  
    -- check the input
    if not utility_package.user_exists(v_user_id => v_user_id) then
    
      raise_application_error(-20202, 'User not found!');
    
    end if;
  
    --commence the operation
    v_cart_id := utility_package.get_cart_id(v_user_id => v_user_id);
  
    delete from cart_item where cart_id = v_cart_id;
    commit;
  
  exception
    when error_package.e_user_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'cart_package, remove_all_products');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' || sqlerrm,
                              v_error_location => 'cart_package, remove_all_product');
  end remove_all_products_from_cart;

  --function for returning cart information with refcursor
  function get_cart_information(v_token varchar2) return sys_refcursor is
    v_sql             varchar2(1000);
    v_user_id         number;
    v_cart_id         number;
    c_products_cursor sys_refcursor;
  begin
  
   --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
    dbms_output.put_line(v_user_id);
    --check user
    if not utility_package.user_exists(v_user_id => v_user_id) then
    
      raise_application_error(-20202, 'User not found!');
    
    end if;
  
    v_cart_id := utility_package.get_cart_id(v_user_id => v_user_id);
    v_sql     := 'select * from cart_item where cart_id =' || v_cart_id;
    dbms_output.put_line(v_sql);
    open c_products_cursor for v_sql;
    return c_products_cursor;
    
  exception
    when error_package.e_user_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'cart_package, get_cart_information');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' || sqlerrm,
                              v_error_location => 'cart_package, get_cart_information');
    
  end get_cart_information;


--procedure that refreshes cart total price
  procedure refresh_cart(v_cart_id number) is
  begin
  
    update cart
       set total_price =
           (select sum(item_total_price)
              from cart_item
             where cart_id = v_cart_id)
     where cart_id = v_cart_id;
  
    commit;
  exception  
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' || sqlerrm,
                              v_error_location => 'cart_package, refresh_cart');
      
  
  end refresh_cart;


  --procedure that refreshes total price of given carts
  procedure refresh_carts(t_cart_id type_package.t_cart_id) is
    
  v_totals type_package.t_totals;
  
  begin
  
  --get sum of all carts that are in t_cart_id
  select sum(item_total_price)
    bulk collect into v_totals
    from cart_item
   where cart_id in (select column_value from table(t_cart_id))
   group by cart_id;
  
  --update all carts that are in t_cart_id
  forall i in 1..t_cart_id.count
    update cart
       set total_price = v_totals(i)
     where cart_id = t_cart_id(i);
  
    commit;
    
  exception  
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' || sqlerrm,
                              v_error_location => 'cart_package, refresh_cart');
      
  
  end refresh_carts;
end cart_package;
/
