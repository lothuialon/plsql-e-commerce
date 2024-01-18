select 'drop table ', table_name, 'cascade constraints;' from user_tables;

--user part
create table 
"USERS"(
  user_id number primary key,
  password_id number ,
  status_id number,
  first_name varchar2(30),
  last_name varchar2(30),
  email varchar2(30) unique,
  create_date date,
  update_date date
);

create table user_status(
  status_id number primary key,
  login_attempts number,
  status varchar2(30)
);

create table passwords(
  password_id number primary key,
  password_salt varchar2(30),
  hashed_password varchar2(256),
  hashing_algorithm varchar2(10)
);

create table reset_codes(
  password_id number primary key,
  reset_code varchar2(10)
);


create table user_session(
  user_id number,
  token varchar2(30) primary key,
  create_date date,
  expire_date date
);


--product part
create table products(
  product_id number primary key,
  category_id number,
  title varchar2(30),
  description varchar2(500),
  quantity number,
  price number,
  is_active number
);


create table product_categories(
  category_id number primary key,
  parent_id number,
  name varchar2(30)
);


create table product_sales(
product_id number primary key,
product_sales number);


--cart part
create table cart(
  cart_id number primary key,
  user_id number,
  total_price number
);

create table cart_item(
  cart_id number,
  product_id number,
  quantity number,
  item_total_price number,
  
  primary key (cart_id, product_id)
);


--order part
create table orders(
  order_id number primary key,
  user_id number,
  total_price number,
  payment_option_id number, 
  tracking_id number, 
  order_status_id number, 
  purchase_date date
);

create table order_items(
  order_id number,
  product_id number,
  quantity number,
  item_total_price number,
  
  primary key(order_id, product_id)
);


create table order_track(  
  order_id number,
  tracking_id number primary key,
  tracking_status_id number,
  shipping_company_name varchar2(30),
  tracking_number varchar2(30)
  );


create table order_status(
  order_status_id number primary key,
  order_status_name varchar2(30)     
);


create table order_track_status(  
  tracking_status_id number primary key,
  track_status_name varchar2(30) 
  );
  
create table payment_option(
  user_id number,
  payment_option_id number primary key,
  payment_name varchar2(30)
  );
  
create table favorites(
  user_id number,
  product_id number,
  primary key (user_id, product_id));

create table error_log (
  error_message varchar2(200),
  error_location varchar2(200),
  error_timestamp timestamp
);

--address

create table address(
  address_id number primary key,
  user_id number,
  address_name number,
  country_id number,
  city_id number,
  district_id number,
  neighbourhood_id number,
  street_id number,
  remainder varchar2(200),
  postal_code number
);

create table country(  
  country_id number primary key,
  name number);

create table city(
  city_id number primary key,
  name number,
  country_id number
);


create table district(
  district_id number primary key,
  name number,
  city_id number

);

create table neighbourhood(
  neighbourhood_id number primary key,
  name number,
  district_id number
  

);

create table street(
  street_id number primary key,
  name number,
  neighbourhood_id number

);


----------------
--Foreign keys

--users table
alter table "USERS" add constraint fk_users_password_id foreign key (password_id) references passwords(password_id);
alter table "USERS" add constraint fk_users_status_id foreign key (status_id) references user_status(status_id);

--reset_codes table
alter table reset_codes add constraint fk_reset_codes_password_id foreign key (password_id) references passwords(password_id);

--user_session table
alter table user_session add constraint fk_user_session_user_id foreign key (user_id) references "USERS"(user_id);

--products table
alter table products add constraint fk_products_category_id foreign key (category_id) references product_categories(category_id);

--product_sales table
alter table product_sales add constraint fk_product_sales_product_id foreign key (product_id) references products(product_id);

--cart table
alter table cart add constraint fk_cart_user_id foreign key (user_id) references "USERS"(user_id);

--cart_item table
alter table cart_item add constraint fk_cart_item_cart_id foreign key (cart_id) references cart(cart_id);
alter table cart_item add constraint fk_cart_item_product_id foreign key (product_id) references products(product_id);

-- orders Table
alter table orders add constraint fk_orders_user_id foreign key (user_id) references "USERS"(user_id);
alter table orders add constraint fk_orders_order_status_id foreign key (order_status_id) references order_status(order_status_id);
alter table orders add constraint fk_orders_tracking_id foreign key (tracking_id) references order_track(tracking_id);
alter table orders add constraint fk_orders_payment_option_id foreign key (payment_option_id) references payment_option(payment_option_id);

-- order_items Table
alter table order_items add constraint fk_order_items_order_id foreign key (order_id) references orders(order_id);

-- order_track Table
alter table order_track add constraint fk_order_track_order_id foreign key (order_id) references orders(order_id);
alter table order_track add constraint fk_order_track_tracking_status_id foreign key (tracking_status_id) references order_track_status(tracking_status_id);


-- payment_option Table
alter table payment_option add constraint fk_payment_option_user_id foreign key (user_id) references "USERS"(user_id);

--favorites table
alter table favorites add constraint fk_favorites_user_id foreign key (user_id) references "USERS"(user_id);
alter table favorites add constraint fk_favorites_product_id foreign key (product_id) references products(product_id);

--address table
alter table address add constraint fk_address_user_id foreign key (user_id) references "USERS" (user_id);
alter table address add constraint fk_address_country_id foreign key (country_id) references country (country_id);
alter table address add constraint fk_address_city_id foreign key (city_id) references city (city_id);
alter table address add constraint fk_address_district_id foreign key (district_id) references district (district_id);
alter table address add constraint fk_address_neighbourhood_id foreign key (neighbourhood_id) references neighbourhood (neighbourhood_id);
alter table address add constraint fk_address_street_id foreign key (street_id) references street (street_id);


--city table
alter table city add constraint fk_city_country_id foreign key (country_id) references country (country_id);

--district table
alter table district add constraint fk_district_city_id foreign key (city_id) references city (city_id);

--neighbourhood table
alter table neighbourhood add constraint fk_neighbourhood_district_id foreign key (district_id) references district (district_id);

--street table
alter table street add constraint fk_street_neighbourhood_id foreign key (neighbourhood_id) references neighbourhood (neighbourhood_id);


-----------------
--Triggers:

--create password salt for each new user before inserting
create or replace trigger set_salt_before_insert
before insert on users
for each row
begin
  :new.password_salt := user_package.create_salt(:new.user_id);
end;

--sets user status
create or replace trigger trg_create_user_status
after insert on "USERS"
for each row
  
declare

v_user_status_id number;

begin

    --user_status insert
    insert into user_status (status_id, login_attempts, status)
    values (:new.status_id, 0, 'ACTIVE')
    returning status_id into v_user_status_id;

    
exception
  
  when others then
    error_package.log_error(v_error_message => 'Unexpected error occured: ' 
    || sqlerrm, v_error_location => 'trg_create_user_status'); 

end;

---------------------------
--sets user cart
create or replace trigger trg_create_user_cart
after insert on "USERS"
for each row
  
declare


v_cart_id number;

begin

    
    --cart insert
    insert into cart (cart_id, user_id, total_price)
    values (seq_cart_id.nextval, :new.user_id, 0)
    returning cart_id into v_cart_id;
    
exception
  
  when others then
    error_package.log_error(v_error_message => 'Unexpected error occured: ' 
    || sqlerrm, v_error_location => 'trg_create_user_cart'); 

end;

--drop trigger trg_create_product_sales
---------------------------
--sets product sales
create or replace trigger trg_create_product_sales
after insert on products
for each row
  
declare


v_product_id number;

begin

    insert into product_sales 
   (product_id, product_sales) 
    values (:new.product_id, 0);  

exception
  
  when others then
    error_package.log_error(v_error_message => 'Unexpected error occured: ' 
    || sqlerrm, v_error_location => 'trg_create_product_sales'); 

end;

--------------
-- Sequences
create sequence seq_user_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_cart_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_password_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_status_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_product_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_product_category_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_order_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_order_item_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_tracking_id
start with 1
increment by 1
nocycle
nocache;

create sequence seq_payment_option_id
start with 1
increment by 1
nocycle
nocache;















