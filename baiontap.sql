create database quanlybanhang;
use quanlybanhang;
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(255) NULL
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    category VARCHAR(50) NOT NULL
);

CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    birthday DATE NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    revenue DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
-- 3
alter table Customers
add email varchar(100) not null unique;
--
alter table Employees
drop birthday;
-- 4

INSERT INTO Customers (customer_name, phone, address, email) VALUES
('Nguyễn Văn A', '0987654321', 'Hà Nội', 'nguyenvana@example.com'),
('Trần Thị B', '0912345678', 'TP. Hồ Chí Minh', 'tranthib@example.com'),
('Lê Văn C', '0933456789', 'Đà Nẵng', 'levanc@example.com'),
('Phạm Thị D', '0965566778', 'Hải Phòng', 'phamthid@example.com'),
('Hoàng Văn E', '0978899001', 'Cần Thơ', 'hoangvane@example.com');

INSERT INTO Products (product_name, price, quantity, category) VALUES
('Điện thoại iPhone 14', 25000000, 10, 'Điện thoại'),
('Laptop Dell XPS 15', 35000000, 5, 'Laptop'),
('Tai nghe AirPods Pro', 5000000, 20, 'Phụ kiện'),
('Chuột Logitech MX Master 3', 2500000, 15, 'Phụ kiện'),
('Bàn phím cơ Razer', 3000000, 8, 'Phụ kiện');

INSERT INTO Employees (employee_name, position, salary, revenue) VALUES
('Lý Minh H', 'Nhân viên bán hàng', 15000000, 0),
('Đỗ Thu K', 'Quản lý', 20000000, 0),
('Nguyễn Văn M', 'Nhân viên kho', 12000000, 0),
('Bùi Thị N', 'Nhân viên chăm sóc khách hàng', 14000000, 0),
('Trần Văn P', 'Nhân viên kỹ thuật', 16000000, 0);

INSERT INTO Orders (customer_id, employee_id, order_date, total_amount) VALUES
(1, 1, '2024-02-10 10:30:00', 30000000),
(2, 2, '2024-02-11 14:45:00', 5000000),
(3, 3, '2024-02-12 09:15:00', 25000000),
(4, 4, '2024-02-13 16:20:00', 35000000),
(5, 5, '2024-02-14 11:10:00', 8000000);

INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 25000000),
(1, 3, 1, 5000000),
(2, 4, 2, 2500000),
(3, 2, 1, 25000000),
(4, 5, 1, 3000000);
-- 5
-- 5.1
select customer_id, customer_name,email,phone,address  from Customers;
-- 5.2
update Products set product_name = '“Laptop Dell XPS', price = 99.99 where product_id= 1;
-- 5.3
select o.order_id,c.customer_name, e.employee_name, o.total_amount, o.order_date 
from orders o 
join customers c on c.customer_id = o.customer_id
join employees e on e.employee_id = o.employee_id;
-- 6
-- 6.1
select c.customer_id, c.customer_name, count(o.order_id)
from customers c
left join orders o on c.customer_id  = o.customer_id
group by customer_id, customer_name;
-- 6.2
SELECT 
    e.employee_id, 
    e.employee_name, 
   sum(o.total_amount)
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
WHERE YEAR(o.order_date) = YEAR(now())
group by employee_id, employee_name;

-- 6.3
SELECT
	p.product_id,
    p.product_name,
    SUM(odt.quantity) AS "số lượt đặt"
FROM Products p
JOIN OrderDetails odt ON odt.product_id = p.product_id
JOIN Orders o ON o.order_id = odt.order_id
WHERE MONTH(o.order_date) = MONTH(now())
GROUP BY product_id, product_name
HAVING SUM(odt.quantity) > 100
ORDER BY SUM(odt.quantity) DESC;
-- 7
-- 7.1
SELECT c.customer_id, c.customer_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
-- 7.2
SELECT product_id, product_name, price
FROM Products
WHERE price > (SELECT AVG(price) FROM Products);
-- 7.3
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) = (
    SELECT MAX(total_spent)
    FROM (SELECT SUM(total_amount) AS total_spent FROM Orders GROUP BY customer_id) AS subquery
);
-- 8
-- 8.1
CREATE VIEW view_order_list AS
SELECT o.order_id, c.customer_name, e.employee_name, o.total_amount, o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC;
SELECT * FROM view_order_list;

-- 8.2
CREATE VIEW view_order_detail_product AS
SELECT od.order_detail_id, p.product_name, od.quantity, od.unit_price
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
ORDER BY od.quantity DESC;
SELECT * FROM view_order_detail_product;

-- 9
-- 9.1
DELIMITER //
CREATE PROCEDURE proc_insert_employee(
    IN p_employee_name VARCHAR(100),
    IN p_position VARCHAR(50),
    IN p_salary DECIMAL(10,2)
)
BEGIN
    INSERT INTO Employees (employee_name, position, salary)
    VALUES (p_employee_name, p_position, p_salary);
    
    SELECT LAST_INSERT_ID() AS new_employee_id;
END //
DELIMITER ;
CALL proc_insert_employee('John Doe', 'Manager', 5000.00);
SELECT * FROM Employees WHERE employee_name = 'John Doe';
-- 9.2
DELIMITER //
CREATE PROCEDURE proc_get_orderdetails(
    IN p_order_id INT
)
BEGIN
    SELECT od.order_detail_id, p.product_name, od.quantity, od.unit_price
    FROM OrderDetails od
    JOIN Products p ON od.product_id = p.product_id
    WHERE od.order_id = p_order_id;
END //
DELIMITER ;
CALL proc_get_orderdetails(1);
SELECT * FROM OrderDetails WHERE order_id = 1;
-- 9.3
DELIMITER //
CREATE PROCEDURE proc_cal_total_amount_by_order(
    IN p_order_id INT
)
BEGIN
    SELECT COUNT(DISTINCT product_id) AS total_product_types
    FROM OrderDetails
    WHERE order_id = p_order_id;
END //
DELIMITER ;
CALL proc_cal_total_amount_by_order(1);
SELECT COUNT(DISTINCT product_id) AS total_product_types FROM OrderDetails WHERE order_id = 1;
-- 10
DELIMITER //
CREATE TRIGGER trigger_after_insert_order_details
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE stock INT;
    SELECT quantity INTO stock FROM Products WHERE product_id = NEW.product_id;
    
    IF NEW.quantity > stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số lượng sản phẩm trong kho không đủ';
    ELSE
        UPDATE Products
        SET quantity = quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END //
DELIMITER ;
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES (1, 2, 5, 100.00);
SELECT * FROM Products WHERE product_id = 2;
-- 11
DELIMITER //
CREATE PROCEDURE proc_insert_order_details(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_unit_price DECIMAL(10,2)
)
BEGIN
    DECLARE order_exists INT;
    DECLARE total_price DECIMAL(10,2);
    
    SELECT COUNT(*) INTO order_exists FROM Orders WHERE order_id = p_order_id;
    
    IF order_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không tồn tại mã hóa đơn';
    END IF;
    
    START TRANSACTION;
    
    INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price)
    VALUES (p_order_id, p_product_id, p_quantity, p_unit_price);
    
    SELECT SUM(quantity * unit_price) INTO total_price 
    FROM OrderDetails WHERE order_id = p_order_id;
    
    UPDATE Orders
    SET total_amount = total_price
    WHERE order_id = p_order_id;
    
    COMMIT;
    
END //
DELIMITER ;
CALL proc_insert_order_details(1, 3, 2, 150.00);
SELECT total_amount FROM Orders WHERE order_id = 1;


