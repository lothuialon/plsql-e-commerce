create or replace package order_history_package is

  -- Author  : CAN
  -- Created : 1/4/2024 3:33:38 PM
  -- Purpose : defines functionalities of order history listing and csv exporting 

  --function that returns order history of the user with a sys_refcursor
  function get_order_history(v_token varchar2) return sys_refcursor;

  --procedure for exporting order history of the user into a csv file with utl
  procedure export_order_history(v_token varchar2);

end order_history_package;
/
create or replace package body order_history_package is

  --procedure for getting order history of the user with a sys_refcursor
  function get_order_history(v_token varchar2) return sys_refcursor is
  
    c_order_history sys_refcursor;
    v_sql           varchar2(1000);
    v_user_id       number;
  begin
  
    --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
  
    v_sql := 'select o.order_id, o.total_price, o.purchase_date, oi.product_id, oi.quantity, oi.item_total_price 
  from orders o, order_items oi, order_status os
  where o.user_id = ' || v_user_id || '
  and o.order_id = oi.order_id
  and os.order_status_id = o.order_status_id
  '; --and os.order_status_name = ''COMPLETED''
  
    --data will be fetched outside 
    open c_order_history for v_sql;
  
    return c_order_history;
  
  exception
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occure: ' ||
                                                  sqlerrm,
                              v_error_location => 'order_history_package, get_order_history');
      close c_order_history;
    
  end get_order_history;

  --procedure for exporting order history of the user into a csv file with utl
  procedure export_order_history(v_token varchar2) is
    v_file    utl_file.file_type;
    v_line    varchar2(200);
    v_user_id number;
    c_orders  sys_refcursor;
    v_sql     varchar2(1000);
    r_order   type_package.r_order_export;
  begin
  
    --verify the token. assigns user id if it is successfull
    v_user_id := user_package.verify_token(v_token => v_token);
  
  
    --open file
    v_file := utl_file.fopen('DATA_DIR',
                             'user_' || v_user_id || '_order_history_' ||
                             sysdate || '.csv',
                             'w');
  
    v_sql := 'select o.order_id,
                   o.total_price,
                   o.tracking_id,
                   o.purchase_date,
                   oi.product_id,
                   oi.quantity,
                   oi.item_total_price
            from orders o, order_items oi, order_status os
            where o.user_id = :v_user_id
              and o.order_id = oi.order_id
              and os.order_status_id = o.order_status_id
            order by o.purchase_date desc';
            
            -- and os.order_status_name = ''COMPLETED''
  
    open c_orders for v_sql
      using v_user_id;
  
    v_line := r_order.order_id || ',' || r_order.total_price || ',' ||
              r_order.tracking_id || ',' || r_order.purchase_date || ',' ||
              r_order.product_id || ',' || r_order.quantity || ',' ||
              r_order.item_total_price;
  
    utl_file.put_line(v_file,
                      'Order id, Total Price, Tracing id, Purchase Date, Product id, Quantity, Item Total');
  
    --iterate the cursor and write the lines into csv file
    loop
      fetch c_orders
        into r_order;
      exit when c_orders%notfound;
    
      v_line := r_order.order_id || ',' || r_order.total_price || ',' ||
                r_order.tracking_id || ',' || r_order.purchase_date || ',' ||
                r_order.product_id || ',' || r_order.quantity || ',' ||
                r_order.item_total_price;
    
      utl_file.put_line(v_file, v_line);
    
    end loop;
  
    close c_orders;
    if c_orders%isopen then
      close c_orders;
    end if;
  
    utl_file.fclose(v_file);
  
  exception
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occure: ' ||
                                                  sqlerrm,
                              v_error_location => 'order_history_package, export_order_history');
    
  end export_order_history;

end order_history_package;
/
