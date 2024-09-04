create database buoi6_bt1;
use buoi6_bt1;

CREATE TABLE user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    address VARCHAR(255),
    phone VARCHAR(11),
    dateofbirth DATE,
    status BIT default 1
);

CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    price DOUBLE,
    stock INT,
    status BIT default 1
);

CREATE TABLE shopping_cart (
    id INT PRIMARY KEY AUTO_INCREMENT,
      product_id INT,
    quantyti INT,
    amount DOUBLE
);

alter table shopping_cart add foreign key (user_id) references user(id);
alter table shopping_cart add foreign key (product_id) references products(id);

-- Thêm dữ liệu vào bảng user
INSERT INTO user(name, address, phone, dateofbirth) 
VALUES 
('Sang', 'Hà Nội', '123456789', '2024-10-10'),
('Phát', 'Hà Nội', '123456999', '2024-08-12'),
('Quang', 'TP.HCM', '123451189', '2024-09-11');

-- Thêm dữ liệu vào bảng products
INSERT INTO products(name, price, stock) 
VALUES
('Điện thoại A', 10000, 2),
('Điện thoại B', 30000, 1),
('Điện thoại C', 50000, 5);

-- Thêm dữ liệu vào bảng shopping_cart
INSERT INTO shopping_cart( product_id, quantyti, amount)
VALUES
( 1, 2, 20000),
( 2, 1, 30000),
( 3, 1, 50000);

select * from user;
select * from products;
select * from shopping_cart;

update products set price = 20000 where id = 1;

drop table user;
delete from user;
drop table products;
drop table shopping_cart;


-- Khi thêm một sản phẩm vào shopping_cart với số lượng n thì bên product cũng sẽ phải trừ đi số lượng n
drop trigger before_insert;
delimiter //
create trigger before_insert 
after insert on shopping_cart
for each row
begin 
update products 
set stock = stock-new.quantyti
where id = new.product_id;
end;
//
delimiter;



  -- Tạo trigger khi xóa product thì những dữ liệu ở bảng shopping_cart có chứa product bị xóa thì cũng phải xóa theo;
 drop trigger before_delete_product;
  delete from products where id=1;
delimiter //

create trigger delete_product
after delete on products 
for each row
begin
delete from shopping_cart where product_id = old.id;
end//
delimiter;

-- Tạo Trigger khi thay đổi giá của sản phẩm thì amount (tổng giá) cũng sẽ phải cập nhật lại.
 drop trigger update_amount_after_price_change;
DELIMITER //
 
create trigger update_amount_after_price_change 
after update on products
for each row
BEGIN
    if old.price !=new.price then
    update shopping_cart
    set amount=(quantyti* new.price)
    where product_id=new.id;
    END if;
end//
DELIMITER;

update products set price = 20000 where id = 1;
  
  



  


