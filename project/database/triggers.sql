-- SQL in this file will be called when the database is reset to prevent loss of triggers
-- trigger to update stock quantity after inserting a sale detail
DROP TRIGGER IF EXISTS trg_update_qty_after_insert_saledetail;;
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
END;;

-- trigger to update stock quantity after updating a sale detail
DROP TRIGGER IF EXISTS trg_update_qty_after_update_saledetail;;
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
END;;

-- trigger to update stock quantity after deleting a sale detail
DROP TRIGGER IF EXISTS trg_update_qty_after_delete_saledetail;;
CREATE TRIGGER trg_update_qty_after_delete_saledetail
AFTER DELETE ON SaleDetails
FOR EACH ROW
BEGIN
    UPDATE Products
    SET stockQuantity = stockQuantity + OLD.quantity
    WHERE productID = OLD.productID;
END ;;