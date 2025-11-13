
-- Beaver Stationery's Sales Management System - DDL Script

SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

-- Drop tables if they exist
DROP TABLE IF EXISTS SaleDetails;
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Categories;

-- 1. Categories Table
CREATE TABLE Categories (
    categoryID INT AUTO_INCREMENT,
    categoryName VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    PRIMARY KEY (categoryID)
);

-- 2. Suppliers Table
CREATE TABLE Suppliers (
    supplierID INT AUTO_INCREMENT,
    supplierName VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phoneNumber VARCHAR(20) NOT NULL,
    PRIMARY KEY (supplierID)
);

-- 3. Customers Table
CREATE TABLE Customers (
    customerID INT AUTO_INCREMENT,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    address VARCHAR(500),
    loyaltyPoints INT NOT NULL DEFAULT 0,
    PRIMARY KEY (customerID)
);

-- 4. Employees Table
CREATE TABLE Employees (
    employeeID INT AUTO_INCREMENT,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(20) NOT NULL,
    position VARCHAR(100) NOT NULL,
    payRate DECIMAL(10, 2) NOT NULL,
    hireDate DATE NOT NULL,
    PRIMARY KEY (employeeID)
);

-- 5. Products Table
CREATE TABLE Products (
    productID INT AUTO_INCREMENT,
    productName VARCHAR(255) NOT NULL,
    description TEXT,
    categoryID INT NOT NULL,
    supplierID INT NOT NULL,
    listPrice DECIMAL(10, 2) NOT NULL,
    stockQuantity INT NOT NULL DEFAULT 0,
    reorderLevel INT NOT NULL,
    PRIMARY KEY (productID),
    FOREIGN KEY (categoryID) REFERENCES Categories(categoryID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (supplierID) REFERENCES Suppliers(supplierID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 6. Sales Table
CREATE TABLE Sales (
    saleID INT AUTO_INCREMENT,
    customerID INT,  -- NULL allowed for walk-in customers
    employeeID INT NOT NULL,
    saleDate DATE NOT NULL,
    PRIMARY KEY (saleID),
    FOREIGN KEY (customerID) REFERENCES Customers(customerID)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (employeeID) REFERENCES Employees(employeeID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 7. SaleDetails Table
CREATE TABLE SaleDetails (
    saleDetailID INT AUTO_INCREMENT,
    saleID INT NOT NULL,
    productID INT NOT NULL,
    quantity INT NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (SaleDetailID),
    FOREIGN KEY (saleID) REFERENCES Sales(saleID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (productID) REFERENCES Products(productID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- Beaver Stationery's Sales Management System - Insert Data

-- 1) Categories (3 rows)
INSERT INTO Categories (categoryName, description) VALUES
('Writing Instruments', 'Pens and markers'),
('Paper Products', 'Notebooks and printer paper'),
('Art Supplies', 'Paints and brushes');

-- 2) Suppliers (3 rows)
INSERT INTO Suppliers (supplierName, email, phoneNumber) VALUES
('Pacific Office Supply Co.', 'sales@pacificoffice.com', '503-555-0101'),
('ArtWorld Distributors', 'orders@artworld.com', '503-555-0202'),
('Union Distributors', 'orders@union.com', '503-555-0203');

-- 3) Customers (3 rows)
INSERT INTO Customers (firstName, lastName, phoneNumber, email, address, loyaltyPoints) VALUES
('Emily', 'Johnson', '503-555-1001', 'emily.j@email.com', '123 Oak St, Portland, OR', 120),
('Michael', 'Chen', '503-555-1002', 'm.chen@email.com', '456 Maple Ave, Portland, OR', 80),
('Jin', 'Lin', '503-555-1005', 'jin.lin@email.com', '439 Seattle Ave, Portland, OR', 90);

-- 4) Employees (3 rows)
INSERT INTO Employees (firstName, lastName, phoneNumber, position, payRate, hireDate) VALUES
('Ryan', 'Thompson', '503-555-2002', 'Sales Associate', 16.00, '2021-06-01'),
('Amanda', 'Lee', '503-555-2003', 'Sales Associate', 16.50, '2021-09-20'),
('Steve', 'Don', '503-555-2004', 'Director', 19.00, '2022-09-20');

-- 5) Products (3 rows) depends on Categories and Suppliers
INSERT INTO Products (productName, description, categoryID, supplierID, listPrice, stockQuantity, reorderLevel) VALUES
('Blue Gel Pen Pack (12ct)', 'Smooth writing gel pens in blue ink', 1, 1, 8.99, 100, 20),
('Spiral Notebook A5', 'College-ruled 100-page spiral notebook', 2, 1, 3.49, 150, 30),
('Watercolor Paint Set', '24-color watercolor set', 3, 2, 24.99, 40, 10);

-- 6) Sales (3 rows) depends on Customers, Employees
INSERT INTO Sales (customerID, employeeID, saleDate) VALUES
(1, 1, '2025-10-15'),
(NULL, 1, '2025-10-16'),
(2, 2, '2025-10-17');

-- 7) SaleDetails (3 rows) depends on Sales and Products
INSERT INTO SaleDetails (saleID, productID, quantity,unitPrice) VALUES
(1, 1, 2, 7.99),
(1, 2, 1, 3.49),
(3, 3, 1,23.99);

SET FOREIGN_KEY_CHECKS=1;
COMMIT;