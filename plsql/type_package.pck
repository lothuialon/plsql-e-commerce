create or replace package type_package is

  -- Author  : CAN
  -- Created : 1/4/2024 9:35:42 PM
  -- Purpose : defines table types for using them accross all packages
  
  type t_favorite is table of favorites%rowtype;
  
  type t_cart_id is table of number;
  
  type t_cart_item is table of cart_item%rowtype;
  
  type t_totals is table of number;
  
  type r_order_export is record (
    order_id number,
    total_price number,
    tracking_id number,
    purchase_date date,
    product_id number,
    quantity number,
    item_total_price number
  );
  
   type r_order_record is record (
    order_id number,
    total_price number,
    purchase_date date,
    product_id number,
    quantity number,
    item_total_price number
  );
  

end type_package;
/
create or replace package body type_package is


end type_package;
/
