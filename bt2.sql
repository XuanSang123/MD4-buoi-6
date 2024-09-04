create database buoi6_bt2;
use buoi6_bt2;
drop database buoi6_bt2;

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
    user_id INT,
    product_id INT,
    quantity INT,
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
INSERT INTO shopping_cart(user_id, product_id, quantity, amount)
VALUES
( 1,1, 2, 20000),
( 2,2, 1, 30000),
( 3,3, 1, 50000);

select * from user;
select * from products;
select * from shopping_cart;
CALL addtocart(1, 1, 2);


-- Tạo Transaction khi thêm sản phẩm vào giỏ hàng thì kiểm tra xem stock của products có đủ số lượng không nếu không thì rollback
DELIMITER $$

CREATE PROCEDURE addtocart(
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    -- Bắt đầu giao dịch
   

    -- Cập nhật kho sản phẩm nếu đủ số lượng, đồng thời tính toán tổng số tiền và thêm sản phẩm vào giỏ hàng
    IF EXISTS (SELECT 1 FROM products WHERE id = p_product_id AND stock >= p_quantity) THEN
        -- Trừ số lượng từ kho hàng
        UPDATE products 
        SET stock = stock - p_quantity
        WHERE id = p_product_id;

        -- Thêm vào bảng giỏ hàng
        INSERT INTO shopping_cart(user_id, product_id, quantity, amount)
        SELECT p_user_id, p_product_id, p_quantity, (p_quantity * price)
        FROM products
        WHERE id = p_product_id;

        -- Xác nhận giao dịch
        COMMIT;
    ELSE
        -- Hủy bỏ nếu không đủ số lượng trong kho
        ROLLBACK;
    END IF;
END$$

DELIMITER ;

drop PROCEDURE addtocart;
DELIMITER $$
CREATE PROCEDURE addtocart(
     p_user_id INT,
     p_product_id INT,
    p_quantity INT
)
begin
 START TRANSACTION;
if exists (select * from products where id = p_product_id and stock>=p_quantity) then
update products 
set stock = stock - p_quantity
where id = p_product_id;

insert into shopping_cart(user_id, product_id, quantity, amount) 
select p_user_id,p_product_id,p_quantity,(p_quantity*price) 
from products 
where id = p_product_id;

commit;

ELSE 

rollback;

END IF;

end$$

DELIMITER;

select * from user;
select * from products;
select * from shopping_cart;
CALL addtocart(3, 3, 5);

-- Tạo Transaction khi xóa sản phẩm trong giỏ hàng thì trả lại số lượng cho products

CALL delete_product(1);

DELIMITER //
create PROCEDURE remove_product(
d_product_id int
);
begin
update products p 
join shopping_cart s
on s.product_id = p.id 
set p.stock = p.stock + s.quantity
where s.id = d_product_id

delete from shopping_cart where id = d_product_id;
commit;

end;
DELIMITER;






DELIMITER //
CREATE PROCEDURE delete_product(
    IN p_cart_id INT
   )
begin
declare v_product_id int;
declare v_quantity int;

START TRANSACTION;

SELECT 
    product_id, quantity
INTO v_product_id , v_quantity FROM
    shopping_cart
WHERE
    id = p_cart_id
FOR UPDATE;

UPDATE products 
SET 
    stock = stock + v_quantity
WHERE
    id = v_product_id;

DELETE FROM shopping_cart 
WHERE
    id = p_cart_id;
commit;
end //
DELIMITER ;