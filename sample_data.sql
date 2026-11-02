-- Small deterministic demo dataset. Safe to run after schema.sql.
INSERT INTO customers (customer_id, first_name, last_name, email, city, state, signup_date, customer_segment) VALUES
(1,'Aarav','Shah','aarav.shah@example.com','Pune','Maharashtra','2025-01-05','Gold'),
(2,'Meera','Patil','meera.patil@example.com','Mumbai','Maharashtra','2025-02-11','Silver'),
(3,'Kabir','Joshi','kabir.joshi@example.com','Nashik','Maharashtra','2025-03-20','Platinum'),
(4,'Anaya','Deshmukh','anaya.deshmukh@example.com','Pune','Maharashtra','2025-05-17','Standard'),
(5,'Ishaan','Kulkarni','ishaan.kulkarni@example.com','Nagpur','Maharashtra','2025-06-02','Silver'),
(6,'Sara','Khan','sara.khan@example.com','Thane','Maharashtra','2025-08-09','Standard');

INSERT INTO products (product_id, product_name, category, unit_price, active) VALUES
(1,'Wireless Mouse','Electronics',799.00,TRUE),
(2,'Mechanical Keyboard','Electronics',2499.00,TRUE),
(3,'Water Bottle','Lifestyle',499.00,TRUE),
(4,'Backpack','Lifestyle',1599.00,TRUE),
(5,'Notebook Pack','Stationery',299.00,TRUE),
(6,'Desk Lamp','Home Office',1299.00,TRUE);

INSERT INTO employees (employee_id, first_name, last_name, department, job_title, hire_date, termination_date, annual_salary, employment_status) VALUES
(1,'Rohan','Mehta','Sales','Sales Executive','2022-04-01',NULL,650000,'Active'),
(2,'Priya','Nair','Sales','Sales Manager','2021-08-15',NULL,1100000,'Active'),
(3,'Dev','Rao','Technology','Data Analyst','2023-02-10',NULL,900000,'Active'),
(4,'Nisha','More','Technology','QA Engineer','2022-11-01','2025-09-30',750000,'Terminated'),
(5,'Vikram','Singh','Operations','Operations Associate','2024-01-08',NULL,580000,'Active'),
(6,'Tara','Iyer','Operations','Operations Analyst','2020-06-22','2025-12-15',820000,'Terminated');

INSERT INTO orders (order_id, customer_id, order_date, order_status, sales_channel) VALUES
(1001,1,'2025-01-12','Completed','Online'),
(1002,2,'2025-01-25','Completed','Store'),
(1003,1,'2025-02-05','Completed','Online'),
(1004,3,'2025-02-18','Completed','Online'),
(1005,4,'2025-03-03','Completed','Phone'),
(1006,2,'2025-03-16','Completed','Store'),
(1007,3,'2025-03-27','Completed','Online'),
(1008,5,'2025-04-09','Completed','Online'),
(1009,1,'2025-04-21','Completed','Store'),
(1010,4,'2025-05-11','Completed','Online'),
(1011,5,'2025-05-19','Cancelled','Online'),
(1012,2,'2025-06-04','Completed','Phone'),
(1013,3,'2025-06-22','Completed','Online'),
(1014,6,'2025-07-07','Completed','Store'),
(1015,1,'2025-07-28','Completed','Online');

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(1001,1,2,799,0),(1001,3,1,499,0),
(1002,5,3,299,0),(1002,4,1,1599,5),
(1003,2,1,2499,10),(1003,1,1,799,0),
(1004,4,2,1599,0),(1004,6,1,1299,5),
(1005,3,2,499,0),(1005,5,4,299,0),
(1006,2,1,2499,0),(1006,3,1,499,0),
(1007,6,2,1299,10),(1007,1,1,799,0),
(1008,4,1,1599,0),(1008,5,2,299,0),
(1009,2,1,2499,5),(1009,6,1,1299,0),
(1010,1,2,799,0),(1010,3,2,499,0),
(1011,4,1,1599,0),
(1012,5,5,299,0),(1012,3,1,499,0),
(1013,2,1,2499,0),(1013,4,1,1599,5),
(1014,6,1,1299,0),(1014,5,2,299,0),
(1015,1,1,799,0),(1015,2,1,2499,0);

INSERT INTO employee_status_history (employee_id, status, effective_date, notes) VALUES
(1,'Active','2022-04-01','Joined company'),
(2,'Active','2021-08-15','Joined company'),
(3,'Active','2023-02-10','Joined company'),
(4,'Active','2022-11-01','Joined company'),
(4,'Terminated','2025-09-30','Resigned'),
(5,'Active','2024-01-08','Joined company'),
(6,'Active','2020-06-22','Joined company'),
(6,'Terminated','2025-12-15','Resigned');

-- Keep identity sequences aligned after inserting explicit IDs.
SELECT setval(pg_get_serial_sequence('customers','customer_id'), (SELECT MAX(customer_id) FROM customers));
SELECT setval(pg_get_serial_sequence('products','product_id'), (SELECT MAX(product_id) FROM products));
SELECT setval(pg_get_serial_sequence('employees','employee_id'), (SELECT MAX(employee_id) FROM employees));
SELECT setval(pg_get_serial_sequence('orders','order_id'), (SELECT MAX(order_id) FROM orders));
SELECT setval(pg_get_serial_sequence('order_items','order_item_id'), (SELECT MAX(order_item_id) FROM order_items));
