/*
 * 02_structured_data.sql
 *
 * Creates the four core retail tables and inserts sample data.
 * Product names match the S3 product manuals for cross-platform demo queries.
 *
 * Run after: 01_setup.sql
 */

USE ROLE RETAIL_DEMO_ROLE;
USE DATABASE RETAIL_DEMO;
USE SCHEMA ECOMMERCE;
USE WAREHOUSE RETAIL_DEMO_WH;

-- ============================================================
-- CUSTOMERS
-- ============================================================
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id     INT,
    name            VARCHAR(100),
    email           VARCHAR(150),
    region          VARCHAR(50),
    loyalty_tier    VARCHAR(20),
    signup_date     DATE
);

INSERT INTO CUSTOMERS VALUES
(1,  'Sarah Johnson',    'sarah.j@email.com',       'North America', 'Gold',     '2022-03-15'),
(2,  'Mike Chen',        'mike.chen@email.com',      'Asia Pacific',  'Silver',   '2022-06-20'),
(3,  'Emily Davis',      'emily.d@email.com',        'North America', 'Premium',  '2021-01-10'),
(4,  'Robert Wilson',    'robert.w@email.com',       'Europe',        'Bronze',   '2023-09-05'),
(5,  'Jennifer Martinez','jennifer.m@email.com',     'North America', 'Gold',     '2022-11-12'),
(6,  'David Thompson',   'david.t@email.com',        'Asia Pacific',  'Premium',  '2021-07-22'),
(7,  'Lisa Anderson',    'lisa.a@email.com',          'Europe',        'Silver',   '2023-02-28'),
(8,  'James Taylor',     'james.t@email.com',         'North America', 'Bronze',   '2023-11-15'),
(9,  'Karen Brown',      'karen.b@email.com',         'Asia Pacific',  'Gold',     '2022-04-03'),
(10, 'Thomas Garcia',    'thomas.g@email.com',        'Europe',        'Silver',   '2023-05-18'),
(11, 'Amanda White',     'amanda.w@email.com',        'North America', 'Premium',  '2021-12-01'),
(12, 'Chris Robinson',   'chris.r@email.com',         'Asia Pacific',  'Bronze',   '2024-01-20'),
(13, 'Patricia Clark',   'patricia.c@email.com',      'Europe',        'Gold',     '2022-08-14'),
(14, 'Steven Lee',       'steven.l@email.com',        'North America', 'Silver',   '2023-03-30'),
(15, 'Michelle Harris',  'michelle.h@email.com',      'Asia Pacific',  'Bronze',   '2024-02-10'),
(16, 'Daniel King',      'daniel.k@email.com',        'Europe',        'Premium',  '2021-09-25'),
(17, 'Jessica Wright',   'jessica.w@email.com',       'North America', 'Gold',     '2022-07-08'),
(18, 'Ryan Lopez',       'ryan.l@email.com',          'Asia Pacific',  'Silver',   '2023-06-12'),
(19, 'Angela Hill',      'angela.h@email.com',        'Europe',        'Bronze',   '2024-03-01'),
(20, 'Nathan Scott',     'nathan.s@email.com',        'North America', 'Silver',   '2023-10-22');

-- ============================================================
-- PRODUCTS
-- ============================================================
CREATE OR REPLACE TABLE PRODUCTS (
    product_id  INT,
    name        VARCHAR(100),
    category    VARCHAR(50),
    brand       VARCHAR(50),
    price       DECIMAL(10,2),
    stock_qty   INT
);

INSERT INTO PRODUCTS VALUES
(101, 'Wireless Headphones Pro',   'Electronics',  'ShopSmart Audio', 149.99, 250),
(102, 'SmartWatch X1',             'Electronics',  'ShopSmart Tech',  249.99, 180),
(103, 'Bluetooth Speaker BoomBox', 'Electronics',  'ShopSmart Audio',  79.99, 320),
(104, 'Laptop Stand Ergo',         'Accessories',  'ShopSmart Office', 39.99, 500),
(105, 'USB-C Hub Pro',             'Accessories',  'ShopSmart Office', 59.99, 400),
(106, 'Wireless Mouse Glide',      'Accessories',  'ShopSmart Office', 29.99, 600),
(107, 'Mechanical Keyboard MK1',   'Accessories',  'ShopSmart Office', 89.99, 220),
(108, 'Phone Case Shield',         'Accessories',  'ShopSmart Mobile', 24.99, 800),
(109, 'Screen Protector UltraClear','Accessories', 'ShopSmart Mobile', 14.99, 1000),
(110, 'Power Bank 20K',            'Electronics',  'ShopSmart Mobile', 44.99, 350),
(111, 'Webcam HD Pro',             'Electronics',  'ShopSmart Tech',   69.99, 280),
(112, 'Desk Lamp Smart',           'Home',         'ShopSmart Home',   54.99, 190),
(113, 'Cable Organizer Kit',       'Home',         'ShopSmart Home',   19.99, 700),
(114, 'Monitor Light Bar',         'Home',         'ShopSmart Home',   49.99, 240),
(115, 'Travel Adapter Universal',  'Accessories',  'ShopSmart Office', 34.99, 450);

-- ============================================================
-- ORDERS
-- ============================================================
CREATE OR REPLACE TABLE ORDERS (
    order_id        INT,
    customer_id     INT,
    product_id      INT,
    order_date      DATE,
    quantity        INT,
    total_amount    DECIMAL(10,2),
    status          VARCHAR(20),
    shipping_method VARCHAR(30)
);

INSERT INTO ORDERS VALUES
(1001, 1,  101, '2024-04-10', 1, 149.99, 'Delivered',   'Standard'),
(1002, 1,  104, '2024-04-10', 2,  79.98, 'Delivered',   'Standard'),
(1003, 2,  102, '2024-04-15', 1, 249.99, 'Delivered',   'Expedited'),
(1004, 3,  101, '2024-04-20', 1, 149.99, 'Delivered',   'Next-Day'),
(1005, 3,  103, '2024-04-20', 2, 159.98, 'Delivered',   'Next-Day'),
(1006, 4,  104, '2024-05-01', 1,  39.99, 'Delivered',   'Standard'),
(1007, 5,  102, '2024-05-05', 1, 249.99, 'Delivered',   'Expedited'),
(1008, 5,  106, '2024-05-05', 1,  29.99, 'Delivered',   'Expedited'),
(1009, 6,  101, '2024-05-12', 2, 299.98, 'Delivered',   'Standard'),
(1010, 7,  103, '2024-05-18', 1,  79.99, 'Delivered',   'Standard'),
(1011, 8,  107, '2024-05-25', 1,  89.99, 'Delivered',   'Standard'),
(1012, 9,  102, '2024-06-01', 1, 249.99, 'Delivered',   'Expedited'),
(1013, 9,  110, '2024-06-01', 1,  44.99, 'Delivered',   'Expedited'),
(1014, 10, 105, '2024-06-08', 1,  59.99, 'Delivered',   'Standard'),
(1015, 11, 101, '2024-06-15', 1, 149.99, 'Delivered',   'Next-Day'),
(1016, 11, 112, '2024-06-15', 1,  54.99, 'Delivered',   'Next-Day'),
(1017, 12, 103, '2024-06-22', 1,  79.99, 'Delivered',   'Standard'),
(1018, 13, 102, '2024-06-28', 1, 249.99, 'Delivered',   'Expedited'),
(1019, 14, 104, '2024-07-05', 3, 119.97, 'Delivered',   'Standard'),
(1020, 14, 113, '2024-07-05', 2,  39.98, 'Delivered',   'Standard'),
(1021, 15, 108, '2024-07-10', 1,  24.99, 'Delivered',   'Standard'),
(1022, 15, 109, '2024-07-10', 2,  29.98, 'Delivered',   'Standard'),
(1023, 16, 101, '2024-07-18', 1, 149.99, 'Delivered',   'Expedited'),
(1024, 16, 114, '2024-07-18', 1,  49.99, 'Delivered',   'Expedited'),
(1025, 17, 102, '2024-07-25', 1, 249.99, 'Delivered',   'Standard'),
(1026, 18, 103, '2024-08-01', 2, 159.98, 'Delivered',   'Standard'),
(1027, 19, 106, '2024-08-08', 1,  29.99, 'Delivered',   'Standard'),
(1028, 19, 107, '2024-08-08', 1,  89.99, 'Delivered',   'Standard'),
(1029, 20, 101, '2024-08-15', 1, 149.99, 'Delivered',   'Expedited'),
(1030, 1,  110, '2024-08-20', 1,  44.99, 'Delivered',   'Standard'),
(1031, 2,  111, '2024-08-22', 1,  69.99, 'Delivered',   'Expedited'),
(1032, 3,  102, '2024-08-28', 1, 249.99, 'Delivered',   'Next-Day'),
(1033, 4,  103, '2024-09-02', 1,  79.99, 'Delivered',   'Standard'),
(1034, 5,  115, '2024-09-05', 2,  69.98, 'Delivered',   'Expedited'),
(1035, 6,  112, '2024-09-10', 1,  54.99, 'Delivered',   'Standard'),
(1036, 7,  101, '2024-09-15', 1, 149.99, 'Delivered',   'Standard'),
(1037, 8,  102, '2024-09-18', 1, 249.99, 'Shipped',     'Expedited'),
(1038, 9,  104, '2024-09-22', 1,  39.99, 'Delivered',   'Standard'),
(1039, 10, 103, '2024-09-25', 1,  79.99, 'Delivered',   'Standard'),
(1040, 11, 107, '2024-09-28', 1,  89.99, 'Delivered',   'Next-Day'),
(1041, 12, 101, '2024-10-01', 1, 149.99, 'Delivered',   'Standard'),
(1042, 12, 108, '2024-10-01', 2,  49.98, 'Delivered',   'Standard'),
(1043, 13, 110, '2024-10-05', 1,  44.99, 'Delivered',   'Expedited'),
(1044, 14, 102, '2024-10-08', 1, 249.99, 'Shipped',     'Standard'),
(1045, 15, 103, '2024-10-10', 1,  79.99, 'Processing',  'Standard'),
(1046, 16, 105, '2024-10-12', 1,  59.99, 'Delivered',   'Expedited'),
(1047, 17, 112, '2024-10-15', 2, 109.98, 'Delivered',   'Standard'),
(1048, 18, 101, '2024-10-18', 1, 149.99, 'Shipped',     'Expedited'),
(1049, 19, 102, '2024-10-20', 1, 249.99, 'Processing',  'Standard'),
(1050, 20, 114, '2024-10-22', 1,  49.99, 'Processing',  'Standard'),
(1051, 1,  103, '2024-10-25', 1,  79.99, 'Processing',  'Next-Day'),
(1052, 3,  115, '2024-10-26', 1,  34.99, 'Processing',  'Standard'),
(1053, 5,  111, '2024-10-27', 1,  69.99, 'Processing',  'Expedited'),
(1054, 6,  102, '2024-10-28', 1, 249.99, 'Processing',  'Standard'),
(1055, 9,  106, '2024-10-28', 2,  59.98, 'Processing',  'Standard'),
(1056, 2,  104, '2024-08-15', 1,  39.99, 'Delivered',   'Standard'),
(1057, 7,  110, '2024-07-20', 1,  44.99, 'Delivered',   'Expedited'),
(1058, 10, 101, '2024-06-30', 1, 149.99, 'Delivered',   'Standard'),
(1059, 13, 107, '2024-08-05', 1,  89.99, 'Delivered',   'Standard'),
(1060, 16, 103, '2024-09-01', 1,  79.99, 'Delivered',   'Expedited'),
(1061, 17, 104, '2024-05-15', 1,  39.99, 'Delivered',   'Standard'),
(1062, 20, 102, '2024-07-12', 1, 249.99, 'Delivered',   'Standard'),
(1063, 11, 113, '2024-08-20', 3,  59.97, 'Delivered',   'Standard'),
(1064, 4,  109, '2024-09-10', 4,  59.96, 'Delivered',   'Standard'),
(1065, 8,  105, '2024-06-05', 1,  59.99, 'Delivered',   'Expedited');

-- ============================================================
-- RETURNS
-- ============================================================
CREATE OR REPLACE TABLE RETURNS (
    return_id       INT,
    order_id        INT,
    reason          VARCHAR(200),
    status          VARCHAR(20),
    refund_amount   DECIMAL(10,2),
    return_date     DATE
);

INSERT INTO RETURNS VALUES
(5001, 1001, 'Bluetooth connectivity issues',            'Refunded',    149.99, '2024-05-05'),
(5002, 1003, 'Screen condensation after shower use',     'Refunded',    249.99, '2024-05-10'),
(5003, 1006, 'Hinge mechanism broke after 6 weeks',      'Replaced',     39.99, '2024-06-15'),
(5004, 1010, 'Battery only lasts 3 hours',               'Refunded',     79.99, '2024-06-20'),
(5005, 1012, 'App crashes during sleep data sync',       'In Progress', 249.99, '2024-06-28'),
(5006, 1017, 'Distorted sound at high volume',           'Refunded',     79.99, '2024-07-15'),
(5007, 1023, 'Left ear cup buzzing sound',               'Replaced',    149.99, '2024-08-10'),
(5008, 1025, 'Changed mind, prefer different brand',     'Refunded',    249.99, '2024-08-18'),
(5009, 1029, 'ANC not effective enough for office',      'Refunded',    149.99, '2024-09-05'),
(5010, 1033, 'USB-C port cover broke off',               'In Progress',  79.99, '2024-09-20'),
(5011, 1036, 'Headband too tight, causes headaches',     'Refunded',    149.99, '2024-10-01'),
(5012, 1041, 'Battery only lasts 15 hours instead of 40','In Progress', 149.99, '2024-10-15'),
(5013, 1058, 'Firmware update bricked the headphones',   'Replaced',    149.99, '2024-07-20'),
(5014, 1062, 'Watch band clasp keeps coming undone',     'In Progress', 249.99, '2024-08-01'),
(5015, 1056, 'Silicone pads fell off after 3 weeks',     'Replaced',     39.99, '2024-09-10');
