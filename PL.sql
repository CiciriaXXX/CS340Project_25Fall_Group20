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
    UPDATE Products
    SET stockQuantity = stockQuantity - (NEW.quantity - OLD.quantity)
    WHERE productID = NEW.productID;

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


