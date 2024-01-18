create or replace package product_package is

  -- Author  : CAN
  -- Created : 12/29/2023 12:52:13 AM
  -- Purpose : defining product insert, delete, filter and pagination functionalities

  --insert a new product
  procedure insert_product(v_category_id number,
                           v_title       varchar2,
                           v_description varchar2,
                           v_quantity    number,
                           v_price       number);

  --deletes product and removes them from user carts as well                       
  procedure delete_product(v_product_id number);

  --function for filtering products by category(get all products under the requested category, subcategories included),
  --order products by price or sales count and returns a sys_refcursor
  function filter_product(v_category_id number default 1,
                          v_order_by    varchar2 default 'asc',
                          v_page_size   number default 10,
                          v_page_number number default 1,
                          v_sort        varchar2 default 'PRICE')
    return sys_refcursor;

end product_package;
/
create or replace package body product_package is

  --inserts a product and checks if there is a duplicate product
  procedure insert_product(v_category_id number,
                           v_title       varchar2,
                           v_description varchar2,
                           v_quantity    number,
                           v_price       number) is
  begin
  
    --check if category exists, price and quantity not zero, title and description not empty
  
    if not utility_package.category_exists(v_category_id => v_category_id) then
      raise_application_error(-20205,
                              'Category not found: ' || v_category_id);
    end if;
  
    if v_price <= 0 then
      raise_application_error(-20222, 'Invalid price!');
    end if;
  
    if v_quantity <= 0 then
      raise_application_error(-20214, 'Invalid quantity!');
    end if;
  
    if trim(v_title) is null then
      raise_application_error(-20223, 'Title is null!');
    end if;
  
    if trim(v_description) is null then
      raise_application_error(-20224, 'Description is null!');
    end if;
  
    --raise error if a duplicate product exists
    if utility_package.product_duplicate_exists(v_title       => v_title,
                                                v_description => v_description) then
      raise_application_error(-20206, 'Duplicate products are not allowed');
    end if;
  
    --continue if there is no error
    insert into products
      (product_id,
       category_id,
       title,
       description,
       quantity,
       price,
       is_active)
    values
      (seq_product_id.nextval,
       v_category_id,
       v_title,
       v_description,
       v_quantity,
       v_price,
       1);
  
    commit;
  
  exception
    when error_package.e_duplicate_product_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, insert_product');
    
    when error_package.e_category_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, insert_product');
    
    when error_package.e_illegal_quantity_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, insert_product');
    
    when error_package.e_illegal_price_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, insert_product');
    
    when error_package.e_null_title_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, insert_product');
    
    when error_package.e_null_description_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, insert_product');
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'product_package, insert_product');
      rollback;
    
  end insert_product;

  --deletes product and removes them from user carts as well, todo remove from cart
  procedure delete_product(v_product_id number) is
  
    t_cart_id type_package.t_cart_id;
  begin
  
    --check if given product exists
    if not utility_package.product_exists(v_product_id => v_product_id) then
      raise_application_error(-20204, 'Product not found');
    end if;
  
    --get all carts with to be deleted product 
    select cart_id
      bulk collect
      into t_cart_id
      from cart_item
     where product_id = v_product_id;
  
    --delete product and remove it from user carts
    delete from product_sales where product_id = v_product_id;
    delete from products where product_id = v_product_id;
    delete from cart_item where product_id = v_product_id;
  
    --refresh the affected carts
    cart_package.refresh_carts(t_cart_id);
    commit;
  
  exception
    when error_package.e_product_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, delete_product');
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'product_package, delete_product');
      rollback;
    
  end delete_product;

  --filters products and returns a syscursor
  function filter_product(v_category_id number default 1,
                          v_order_by    varchar2 default 'asc',
                          v_page_size   number default 10,
                          v_page_number number default 1,
                          v_sort        varchar2 default 'PRICE')
    return sys_refcursor is
  
    v_sql             varchar2(1000);
    c_products_cursor sys_refcursor;
  begin
  
    --check the inputs
    if v_category_id < 0 then
      raise_application_error(-20208, 'Category id cannot be less than 0');
    end if;
  
    if not utility_package.category_exists(v_category_id => v_category_id) then
      raise_application_error(-20205,
                              'Category not found ' || v_category_id);
    
    end if;
  
    if upper(v_order_by) != 'ASC' and upper(v_order_by) != 'DESC' then
      raise_application_error(-20209, 'Invalid order value: ' || v_order_by);
    end if;
  
    if upper(v_sort) != 'PRICE' and upper(v_sort) != 'SALES' then
      raise_application_error(-20225, 'Invalid sort value: ' || v_sort);
    end if;
  
    if v_page_number <= 0 then
      raise_application_error(-20210, 'Page number cannot be less than 0');
    end if;
  
    if v_page_size <= 0 then
      raise_application_error(-20210, 'Page size cannot be less than 0');
    end if;
  
    if upper(v_sort) = 'PRICE' then
    
      v_sql := 'select p.*, ps.product_sales
              from products p, product_sales ps
              where
               p.product_id = ps.product_id
               and p.category_id IN (
                select pc.category_id
                from product_categories pc
                start with pc.category_id = ' ||
               v_category_id || '  
                connect by prior pc.category_id = pc.parent_id
              )
              order by p.price ' || v_order_by || ' offset ' ||
               ((v_page_number - 1) * v_page_size) || ' rows fetch first ' ||
               v_page_size || ' rows only';
    
    elsif upper(v_sort) = 'SALES' then
    
      v_sql := 'select p.*, ps.product_sales
              from products p, product_sales ps
              where
               p.product_id = ps.product_id
               and p.category_id IN (
                select pc.category_id
                from product_categories pc
                start with pc.category_id = ' ||
               v_category_id || '  
                connect by prior pc.category_id = pc.parent_id
              )
              order by ps.product_sales ' || v_order_by ||
               ' offset ' || ((v_page_number - 1) * v_page_size) ||
               ' rows fetch first ' || v_page_size || ' rows only';
    
    end if;
    dbms_output.put_line(v_sql);
    
    open c_products_cursor for v_sql;
  
    return c_products_cursor;
  
  exception
    when error_package.e_illegal_category_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, filter_products');
    
    when error_package.e_illegal_orderby_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, filter_products');
    
    when error_package.e_illegal_pagination_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, filter_products');
    
    when error_package.e_category_not_found_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, filter_products');
    
    when error_package.e_invalid_sort_value_exception then
      error_package.log_error(v_error_message  => sqlerrm,
                              v_error_location => 'product_package, filter_products');
    
    when others then
      error_package.log_error(v_error_message  => 'Unexpected error occured: ' ||
                                                  sqlerrm,
                              v_error_location => 'product_package, filter_products');
      close c_products_cursor;
      return null;
  end filter_product;

end product_package;
/
