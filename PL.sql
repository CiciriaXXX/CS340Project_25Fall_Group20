-- Citation for the following code:
-- Date: 12/01/2025
-- The CRUD logic in this file is my own work, adapted from course material provided in CS 340.
-- All stored procedures, triggers, and application-specific logic have been
-- written for our project requirements.

-- ########################################
-- ########## STORED PROCEDURES

-- Drop stored procedures if they exist
DROP PROCEDURE IF EXISTS sp_reset_db;

DELIMITER //

-- Stored Procedure to Reset Database
-- This procedure drops all tables, recreates them, and reloads sample data
CREATE PROCEDURE sp_reset_db()
BEGIN
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
        customerID INT,
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
    
    -- Insert sample data
    INSERT INTO Categories (categoryName, description) VALUES
    ('Writing Instruments', 'Pens and markers'),
    ('Paper Products', 'Notebooks and printer paper'),
    ('Art Supplies', 'Paints and brushes');
    
    INSERT INTO Suppliers (supplierName, email, phoneNumber) VALUES
    ('Pacific Office Supply Co.', 'sales@pacificoffice.com', '503-555-0101'),
    ('ArtWorld Distributors', 'orders@artworld.com', '503-555-0202'),
    ('Union Distributors', 'orders@union.com', '503-555-0203');
    
    INSERT INTO Customers (firstName, lastName, phoneNumber, email, address, loyaltyPoints) VALUES
    ('Emily', 'Johnson', '503-555-1001', 'emily.j@email.com', '123 Oak St, Portland, OR', 120),
    ('Michael', 'Chen', '503-555-1002', 'm.chen@email.com', '456 Maple Ave, Portland, OR', 80),
    ('Jin', 'Lin', '503-555-1005', 'jin.lin@email.com', '439 Seattle Ave, Portland, OR', 90);
    
    INSERT INTO Employees (firstName, lastName, phoneNumber, position, payRate, hireDate) VALUES
    ('Ryan', 'Thompson', '503-555-2002', 'Sales Associate', 16.00, '2021-06-01'),
    ('Amanda', 'Lee', '503-555-2003', 'Sales Associate', 16.50, '2021-09-20'),
    ('Steve', 'Don', '503-555-2004', 'Director', 19.00, '2022-09-20');
    
    INSERT INTO Products (productName, description, categoryID, supplierID, listPrice, stockQuantity, reorderLevel) VALUES
    ('Blue Gel Pen Pack (12ct)', 'Smooth writing gel pens in blue ink', 1, 1, 8.99, 100, 20),
    ('Spiral Notebook A5', 'College-ruled 100-page spiral notebook', 2, 1, 3.49, 150, 30),
    ('Watercolor Paint Set', '24-color watercolor set', 3, 2, 24.99, 40, 10);
    
    INSERT INTO Sales (customerID, employeeID, saleDate) VALUES
    (1, 1, '2025-10-15'),
    (NULL, 1, '2025-10-16'),
    (2, 2, '2025-10-17');
    
    INSERT INTO SaleDetails (saleID, productID, quantity, unitPrice) VALUES
    (1, 1, 2, 7.99),
    (1, 2, 1, 3.49),
    (3, 3, 1, 23.99);
    
    SET FOREIGN_KEY_CHECKS=1;
    COMMIT;
END //

DELIMITER ;

-- SP to test the delete
DELIMITER $$
DROP PROCEDURE IF EXISTS delete_michael_chen $$
CREATE PROCEDURE delete_michael_chen()
BEGIN
    DELETE FROM Customers WHERE firstName = 'Michael' AND lastName = 'Chen';
END $$
DELIMITER ;

-- SP to create a customer
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_customer $$
CREATE PROCEDURE `sp_create_customer`(
    IN p_firstName VARCHAR(100),
    IN p_lastName VARCHAR(100),
    IN p_phoneNumber VARCHAR(20),
    IN p_email VARCHAR(255),
    IN p_address VARCHAR(500),
    IN p_loyaltyPoints INT
)
BEGIN
    INSERT INTO Customers (firstName, lastName, phoneNumber, email, address, loyaltyPoints)
    VALUES (p_firstName, p_lastName, p_phoneNumber, p_email, p_address, p_loyaltyPoints);
END $$
DELIMITER ;

-- SP to update a customer
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_customer $$
CREATE  PROCEDURE `sp_update_customer`(
    IN p_customerID INT,
    IN p_firstName VARCHAR(100),
    IN p_lastName VARCHAR(100),
    IN p_phoneNumber VARCHAR(20),
    IN p_email VARCHAR(255),
    IN p_address VARCHAR(500),
    IN p_loyaltyPoints INT
)
BEGIN
    UPDATE Customers
    SET 
        firstName = p_firstName,
        lastName = p_lastName,
        phoneNumber = p_phoneNumber,
        email = p_email,
        address = p_address,
        loyaltyPoints = p_loyaltyPoints
    WHERE customerID = p_customerID;
END $$
DELIMITER ;

-- SP to delete a customer
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_delete_customer $$
CREATE PROCEDURE `sp_delete_customer`(IN p_customerID INT)
BEGIN
	DELETE FROM Customers
    WHERE customerID = p_customerID;
END $$
DELIMITER ;

-- SP to delete a sale detail
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_delete_saledetail $$
CREATE PROCEDURE `sp_delete_saledetail`(IN p_saleDetailID INT)
BEGIN
	DELETE FROM SaleDetails
    WHERE saleDetailID = p_saleDetailID;
END $$
DELIMITER ;

-- SP to update a sale detail
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_saledetail $$
CREATE PROCEDURE `sp_update_saledetail`(
    IN p_saleDetailID INT,
    IN p_saleID INT,
    IN p_productID INT,
    IN p_quantity INT,
    IN p_unitPrice DECIMAL(10,2)
   
)
BEGIN
	UPDATE SaleDetails
    SET 
        saleID = p_saleID,
        productID = p_productID,
        quantity = p_quantity,
   	    unitPrice = p_unitPrice
    WHERE saleDetailID = p_saleDetailID;
END $$
DELIMITER ;

-- SP to create a sale detail
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_saledetail $$
CREATE PROCEDURE `sp_create_saledetail`(
    IN p_saleID INT,
    IN p_productID INT,
    IN p_quantity INT,
    IN p_unitPrice DECIMAL(10,2)
)
BEGIN
    INSERT INTO SaleDetails (saleID, productID, quantity, unitPrice)
    VALUES (p_saleID, p_productID, p_quantity, p_unitPrice);
END $$
DELIMITER ;

-- sp to create a sale
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_create_sale $$
CREATE PROCEDURE `sp_create_sale`(
    IN p_customerID INT,
    IN p_employeeID INT,
    IN p_saleDate DATE
)
BEGIN
    INSERT INTO Sales (customerID, employeeID, saleDate)
    VALUES (p_customerID, p_employeeID, p_saleDate);
END $$
DELIMITER ;

-- sp to update a sale
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_update_sale $$
CREATE PROCEDURE `sp_update_sale`(
    IN p_saleID INT,
    IN p_customerID INT,
    IN p_employeeID INT,
    IN p_saleDate DATE
)
BEGIN
    UPDATE Sales
    SET 
        customerID = p_customerID,
        employeeID = p_employeeID,
        saleDate = p_saleDate
    WHERE saleID = p_saleID;
END $$ 
DELIMITER ;

--sp to delete a sale
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_delete_sale $$
CREATE PROCEDURE `sp_delete_sale`(IN p_saleID INT)
BEGIN
    DELETE FROM Sales
    WHERE saleID = p_saleID;
END $$
DELIMITER ; 

-- sp to get a specific customer by ID
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_customer_by_id $$
CREATE PROCEDURE `sp_get_customer_by_id`(IN p_customerID INT)
BEGIN
    SELECT * FROM Customers WHERE customerID = p_customerID;
END $$
DELIMITER ;

-- sp to get a specific sale detail by ID
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_saledetail_by_id $$
CREATE PROCEDURE `sp_get_saledetail_by_id`(IN p_saleDetailID INT)
BEGIN
    SELECT * FROM SaleDetails WHERE saleDetailID = p_saleDetailID;
END $$
DELIMITER ;

-- sp to get a specific sale by ID
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_get_sale_by_id $$
CREATE PROCEDURE `sp_get_sale_by_id`(IN p_saleID INT)
BEGIN
    SELECT * FROM Sales WHERE saleID = p_saleID;
END $$
DELIMITER ;

-- trigger to update stock quantity after inserting a sale detail
DELIMITER $$
DROP TRIGGER IF EXISTS trg_update_qty_after_insert_saledetail $$
CREATE TRIGGER trg_update_qty_after_insert_saledetail
AFTER INSERT ON SaleDetails
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stockQuantity = stockQuantity - NEW.quantity
    WHERE productID = NEW.productID;

    IF (SELECT stockQuantity FROM Products WHERE productID = NEW.productID) < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Insufficient stock after INSERT.';
    END IF;
END $$
DELIMITER ;

-- trigger to update stock quantity after updating a sale detail
DELIMITER $$

DROP TRIGGER IF EXISTS trg_update_qty_after_update_saledetail $$
CREATE TRIGGER trg_update_qty_after_update_saledetail
AFTER UPDATE ON SaleDetails
FOR EACH ROW
BEGIN
    IF NEW.productID = OLD.productID THEN
    -- quantity changed
        UPDATE Products
        SET stockQuantity = stockQuantity - (NEW.quantity - OLD.quantity)
        WHERE productID = NEW.productID;
    ELSE
    -- product changed
        UPDATE Products
        SET stockQuantity = stockQuantity + OLD.quantity
        WHERE productID = OLD.productID;

        UPDATE Products
        SET stockQuantity = stockQuantity - NEW.quantity
        WHERE productID = NEW.productID;
    END IF;

    IF (SELECT stockQuantity FROM Products WHERE productID = NEW.productID) < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Insufficient stock after UPDATE.';
    END IF;
END $$

DELIMITER ;

-- trigger to update stock quantity after deleting a sale detail
DELIMITER $$

DROP TRIGGER IF EXISTS trg_update_qty_after_delete_saledetail $$
CREATE TRIGGER trg_update_qty_after_delete_saledetail
AFTER DELETE ON SaleDetails
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stockQuantity = stockQuantity + OLD.quantity
    WHERE productID = OLD.productID;
END $$

DELIMITER ;

