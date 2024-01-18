create or replace package order_package is

  -- Author  : CAN
  -- Created : 1/2/2024 6:46:08 PM
  -- Purpose : defines functionalities of purchasing and tracking an order.   

  --procedure for purchasing a cart with given payment option of the user
  procedure purchase_cart(v_token varchar2, v_payment_option_id number);

  --procedure for updating/assigning the tracking of an accepted order
  procedure update_tracking(v_order_id              number,
                            v_tracking_code         varchar2,
                            v_shipping_company_name varchar2);

  --procedure for cancelling an order if it is not shipped
  procedure cancel_order(v_token varchar2, v_order_id number);


end order_package;
/
create or replace package body order_package is

  --procedure for purchasing a cart with given payment option of the user
  procedure purchase_cart(v_token varchar2, v_payment_option_id number) is
    c_cart_item_cursor sys_refcursor;
    --v_cart_items       type_package.t_cart_item;
    v_cart_item        cart_item%rowtype;
    v_sql              varchar2(1000);
    r_cart             cart%rowtype;
    v_cart_id          number;
    v_order_id         number;
    v_cart_total_price number;
    v_user_id          number;
  begin
  
    --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
  
    --get cart of the user
    r_cart             := utility_package.get_cart_data(v_user_id => v_user_id);
    v_cart_id          := r_cart.cart_id;
    v_cart_total_price := r_cart.total_price;
    
    --check if cart is empty
    if utility_package.is_cart_empty(v_cart_id => v_cart_id) then
      raise_application_error(-20229, 'Cart is empty!');
    end if;
    
    --check if payment option is valid
    if not
        utility_package.payment_option_exists(v_user_id           => v_user_id,
                                              v_payment_option_id => v_payment_option_id) then
    
      raise_application_error(-20230, 'Payment option is invalid: ' || v_payment_option_id );
    end if;
  
    --create the order and insert items
    v_order_id := seq_order_id.nextval;
    insert into orders
      (order_id,
       user_id,
       total_price,
       payment_option_id,
       tracking_id,
       order_status_id,
       purchase_date)
    values
      (v_order_id,
       v_user_id,
       v_cart_total_price,
       v_payment_option_id,
       null, --will be updated after order is given to a shipping company
       1, --PAID
       sysdate);
      
    --after order is created, open a cursor for getting all products of the the user cart
    v_sql := 'select * from cart_item where cart_id =' || v_cart_id;
    open c_cart_item_cursor for v_sql;

    --purchase process
    loop
      fetch c_cart_item_cursor
        into v_cart_item;
      exit when c_cart_item_cursor%notfound;
      --insert cart item into order item
      insert into order_items
        (order_id, product_id, quantity, item_total_price)
      values
        (v_order_id,
         v_cart_item.product_id,
         v_cart_item.quantity,
         v_cart_item.item_total_price);
    
    end loop;

    cart_package.remove_all_products_from_cart(v_token => v_token);
  
    commit;
    close c_cart_item_cursor;
  exception
    when error_package.e_user_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'order_package, purchase_cart');
    when error_package.e_null_cart_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'order_package, purchase_cart');
    when error_package.e_invalid_payment_option_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'order_package, purchase_cart');
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'order_package, purchase_cart');
    
      rollback;
    
  end purchase_cart;

  --procedure for updating/assigning the tracking of an accepted order
  procedure update_tracking(v_order_id              number,
                            v_tracking_code         varchar2,
                            v_shipping_company_name varchar2) is
    v_tracking_id number;
  begin
    --check given inputs. assume tracking code is correct if not null
    if not utility_package.order_exists(v_order_id => v_order_id) then
      raise_application_error(-20228, 'Order not found!');
    end if;
  
    if trim(v_tracking_code) is null then
      raise_application_error(-20231, 'Tracking code is empty!');
    end if;
  
    if trim(v_shipping_company_name) is null then
      raise_application_error(-20231, 'Shipping company name is empty!');
    end if;
    --start the process
    v_tracking_id := seq_tracking_id.nextval;
    --insert a order_track row for the order
    insert into order_track
      (order_id, tracking_id, shipping_company_name, tracking_number)
    values
      (v_order_id, v_tracking_id, v_shipping_company_name, v_tracking_code);
  
    --update the order with tracking id
    update orders
       set tracking_id = v_tracking_id
     where order_id = v_order_id;
  
    commit;
  
  exception
    when error_package.e_order_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'order_package, update_tracking');
    when error_package.e_null_input_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'order_package, update_tracking');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occure: ' ||
                                                  sqlerrm,
                              v_error_location => 'order_package, update_tracking');
      rollback;
    
  end update_tracking;
  -----------------------------------------------------------------
  --todo
  --procedure for cancelling an order if it is not shipped
  procedure cancel_order(v_token varchar2, v_order_id number) is
    v_order_status varchar(30);
    v_user_id      number;
  begin
  
    --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
  
    --check inputs
    if not utility_package.order_exists(v_order_id => v_order_id) then
      raise_application_error(-20228, 'Order not found!');
    end if;
  
    if not utility_package.user_exists(v_user_id => v_user_id) then
      raise_application_error(-20202, 'User not found!');
    end if;
    --get order status and cancel order if not shipped or completed
    v_order_status := utility_package.get_order_status(v_order_id => v_order_id);
  
    if v_order_status = 'COMPLETED' or v_order_status = 'SHIPPED' then
      raise_application_error(-20233, 'Invalid order status!');
    end if;
  
    --commence the operation
    delete from orders where order_id = v_order_id;
  
    commit;
  
  exception
    when error_package.e_order_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'order_package, cancel_order');
    when error_package.e_user_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'order_package, cancel_order');
    when error_package.e_invalid_order_cancel_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'order_package, cancel_order');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occure: ' ||
                                                  sqlerrm,
                              v_error_location => 'order_package, cancel_order');
      rollback;
  end cancel_order;

end order_package;
/
