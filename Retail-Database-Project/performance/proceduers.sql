--Package: pkg_order
--Specification
CREATE OR REPLACE PACKAGE pkg_order AS

    -- Tạo Order mới
    PROCEDURE Create_Order(
        p_CustomerID   IN NUMBER,
        p_BranchID     IN NUMBER,
        p_EmployeeID   IN NUMBER,
        p_ChannelID    IN NUMBER,
        p_StatusID     IN NUMBER,
        p_ProductIDs   IN SYS.ODCINUMBERLIST,
        p_Quantities   IN SYS.ODCINUMBERLIST,
        p_OrderID      OUT NUMBER
    );

    -- Lấy danh sách Orders phân trang
    PROCEDURE Get_Orders_Paginated(
        p_Page       IN NUMBER,
        p_PageSize   IN NUMBER,
        p_Cursor     OUT SYS_REFCURSOR
    );

    -- Lấy chi tiết Order
    PROCEDURE Get_Order_Details(
        p_OrderID IN NUMBER,
        p_Cursor  OUT SYS_REFCURSOR
    );

    -- Cập nhật trạng thái Order
    PROCEDURE Update_Order_Status(
        p_OrderID  IN NUMBER,
        p_StatusID IN NUMBER
    );

END pkg_order;
/
--Body
CREATE OR REPLACE PACKAGE BODY pkg_order AS

    PROCEDURE Create_Order(
        p_CustomerID   IN NUMBER,
        p_BranchID     IN NUMBER,
        p_EmployeeID   IN NUMBER,
        p_ChannelID    IN NUMBER,
        p_StatusID     IN NUMBER,
        p_ProductIDs   IN SYS.ODCINUMBERLIST,
        p_Quantities   IN SYS.ODCINUMBERLIST,
        p_OrderID      OUT NUMBER
    ) AS
        v_Total     NUMBER := 0;
        v_UnitPrice NUMBER;
    BEGIN
        -- Lấy OrderID mới từ sequence
        SELECT Orders_SEQ.NEXTVAL INTO p_OrderID FROM dual;

        -- Tạo Order
        INSERT INTO Orders(OrderID, CustomerID, BranchID, EmployeeID, ChannelID, OrderDate, StatusID, TotalAmount)
        VALUES(p_OrderID, p_CustomerID, p_BranchID, p_EmployeeID, p_ChannelID, SYSDATE, p_StatusID, 0);

        -- Thêm chi tiết sản phẩm
        FOR i IN 1..p_ProductIDs.COUNT LOOP
            BEGIN
                SELECT Price INTO v_UnitPrice
                FROM Product_Prices
                WHERE ProductID = p_ProductIDs(i)
                  AND EffectiveDate <= SYSDATE
                  AND (ExpiryDate IS NULL OR ExpiryDate >= SYSDATE)
                FETCH FIRST 1 ROWS ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- Nếu không tìm thấy giá, gán mặc định 50,000
                    v_UnitPrice := 50000;
            END;

            INSERT INTO Order_Details(OrderDetailID, OrderID, ProductID, Quantity, UnitPrice)
            VALUES(Order_Details_SEQ.NEXTVAL, p_OrderID, p_ProductIDs(i), p_Quantities(i), v_UnitPrice);

            v_Total := v_Total + (p_Quantities(i) * v_UnitPrice);
        END LOOP;

        -- Cập nhật tổng tiền
        UPDATE Orders SET TotalAmount = v_Total WHERE OrderID = p_OrderID;
        COMMIT;
    END Create_Order;

    PROCEDURE Get_Orders_Paginated(
        p_Page       IN NUMBER,
        p_PageSize   IN NUMBER,
        p_Cursor     OUT SYS_REFCURSOR
    ) AS
        v_Start NUMBER;
        v_End   NUMBER;
    BEGIN
        v_Start := (p_Page-1)*p_PageSize + 1;
        v_End := p_Page*p_PageSize;

        OPEN p_Cursor FOR
            SELECT * FROM (
                SELECT o.*, ROW_NUMBER() OVER (ORDER BY OrderDate DESC) AS rn
                FROM Orders o
            )
            WHERE rn BETWEEN v_Start AND v_End;
    END Get_Orders_Paginated;

    PROCEDURE Get_Order_Details(
        p_OrderID IN NUMBER,
        p_Cursor  OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_Cursor FOR
            SELECT od.*, p.ProductName
            FROM Order_Details od
            JOIN Products p ON od.ProductID = p.ProductID
            WHERE od.OrderID = p_OrderID;
    END Get_Order_Details;

    PROCEDURE Update_Order_Status(
        p_OrderID  IN NUMBER,
        p_StatusID IN NUMBER
    ) AS
    BEGIN
        UPDATE Orders SET StatusID = p_StatusID WHERE OrderID = p_OrderID;
        COMMIT;
    END Update_Order_Status;

END pkg_order;
/

--Test Procedure Create_Order
SET SERVEROUTPUT ON;
DECLARE
    v_OrderID NUMBER;
    v_ProductIDs SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(101, 102, 103);
    v_Quantities SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(2, 1, 5);
BEGIN
    pkg_order.Create_Order(
        p_CustomerID => 1,
        p_BranchID   => 2,
        p_EmployeeID => 5,
        p_ChannelID  => 1,
        p_StatusID   => 1,
        p_ProductIDs => v_ProductIDs,
        p_Quantities => v_Quantities,
        p_OrderID    => v_OrderID
    );

    DBMS_OUTPUT.PUT_LINE('Created Order ID: ' || v_OrderID);
END;
/

SELECT * FROM Product_Prices WHERE ProductID IN (101,102,103);

SELECT TO_CHAR(TotalAmount, 'FM999G999G999') AS Formatted_Total
FROM Orders
WHERE OrderID = 2000005;

select * from ORDER_DETAILS where orderid = 2000005;


------------------------------------------------------------------------------------
--Package: pkg_invoice
--Specification
CREATE OR REPLACE PACKAGE pkg_invoice AS

    -- Tạo Invoice & Payment từ Order
    PROCEDURE Create_Invoice_Payment(
        p_OrderID      IN NUMBER,
        p_EmployeeID   IN NUMBER,
        p_StatusID     IN NUMBER,
        p_MethodID     IN NUMBER,
        p_AmountPaid   IN NUMBER,
        p_InvoiceID    OUT NUMBER
    );

    -- Lấy danh sách Invoice phân trang
    PROCEDURE Get_Invoices_Paginated(
        p_Page       IN NUMBER,
        p_PageSize   IN NUMBER,
        p_Cursor     OUT SYS_REFCURSOR
    );

    -- Cập nhật trạng thái Invoice
    PROCEDURE Update_Invoice_Status(
        p_InvoiceID IN NUMBER,
        p_StatusID  IN NUMBER
    );

    -- Lấy chi tiết Invoice (các Payment liên quan)
    PROCEDURE Get_Invoice_Details(
        p_InvoiceID IN NUMBER,
        p_Cursor    OUT SYS_REFCURSOR
    );

END pkg_invoice;
/
--Body
CREATE OR REPLACE PACKAGE BODY pkg_invoice AS

    PROCEDURE Create_Invoice_Payment(
        p_OrderID      IN NUMBER,
        p_EmployeeID   IN NUMBER,
        p_StatusID     IN NUMBER,
        p_MethodID     IN NUMBER,
        p_AmountPaid   IN NUMBER,
        p_InvoiceID    OUT NUMBER
    ) AS
        v_OrderAmount NUMBER;
    BEGIN
        SELECT TotalAmount INTO v_OrderAmount FROM Orders WHERE OrderID = p_OrderID;

        SELECT Invoices_SEQ.NEXTVAL INTO p_InvoiceID FROM dual;

        INSERT INTO Invoices(InvoiceID, InvoiceDate, StatusID, EmployeeID, TotalAmount)
        VALUES(p_InvoiceID, SYSDATE, p_StatusID, p_EmployeeID, v_OrderAmount);

        INSERT INTO Payments(PaymentID, InvoiceID, PaymentDate, MethodID, AmountPaid)
        VALUES(Payments_SEQ.NEXTVAL, p_InvoiceID, SYSDATE, p_MethodID, p_AmountPaid);

        INSERT INTO Order_Invoices(OrderInvoiceID, OrderID, InvoiceID)
        VALUES(Order_Invoices_SEQ.NEXTVAL, p_OrderID, p_InvoiceID);

        COMMIT;
    END Create_Invoice_Payment;

    PROCEDURE Get_Invoices_Paginated(
        p_Page       IN NUMBER,
        p_PageSize   IN NUMBER,
        p_Cursor     OUT SYS_REFCURSOR
    ) AS
        v_Start NUMBER;
        v_End   NUMBER;
    BEGIN
        v_Start := (p_Page-1)*p_PageSize + 1;
        v_End := p_Page*p_PageSize;

        OPEN p_Cursor FOR
            SELECT * FROM (
                SELECT i.*, ROW_NUMBER() OVER (ORDER BY InvoiceDate DESC) AS rn
                FROM Invoices i
            )
            WHERE rn BETWEEN v_Start AND v_End;
    END Get_Invoices_Paginated;

    PROCEDURE Update_Invoice_Status(
        p_InvoiceID IN NUMBER,
        p_StatusID  IN NUMBER
    ) AS
    BEGIN
        UPDATE Invoices SET StatusID = p_StatusID WHERE InvoiceID = p_InvoiceID;
        COMMIT;
    END Update_Invoice_Status;

    PROCEDURE Get_Invoice_Details(
        p_InvoiceID IN NUMBER,
        p_Cursor    OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_Cursor FOR
            SELECT pmt.*, pm.MethodName
            FROM Payments pmt
            JOIN Payment_Methods pm ON pmt.MethodID = pm.MethodID
            WHERE pmt.InvoiceID = p_InvoiceID;
    END Get_Invoice_Details;

END pkg_invoice;
/

--TEST
--CREATE_INVOICE_PAYMENTS
SET SERVEROUTPUT ON;

DECLARE
    v_InvoiceID NUMBER;
BEGIN
    pkg_invoice.Create_Invoice_Payment(
        p_OrderID    => 2000005,   -- Order đã tồn tại
        p_EmployeeID => 5,
        p_StatusID   => 1,         -- trạng thái ban đầu
        p_MethodID   => 2,         -- ví dụ MethodID=2 là "Cash"
        p_AmountPaid => 400000,    -- số tiền thanh toán
        p_InvoiceID  => v_InvoiceID
    );

    DBMS_OUTPUT.PUT_LINE('Created Invoice ID: ' || v_InvoiceID);
END;
/
select * from invoices where invoiceid = 2000001;

--GET_INVOICE_PAGINATED
SET SERVEROUTPUT ON;

DECLARE
    v_Cursor SYS_REFCURSOR;
    v_InvoiceID NUMBER;
    v_InvoiceDate DATE;
    v_StatusID NUMBER;
    v_EmployeeID NUMBER;
    v_TotalAmount NUMBER;
    v_rn NUMBER;
BEGIN
    pkg_invoice.Get_Invoices_Paginated(
        p_Page     => 1,
        p_PageSize => 15,
        p_Cursor   => v_Cursor
    );

    LOOP
        FETCH v_Cursor INTO v_InvoiceID, v_InvoiceDate, v_StatusID, v_EmployeeID, v_TotalAmount, v_rn;
        EXIT WHEN v_Cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('InvoiceID=' || v_InvoiceID || ', Total=' || TO_CHAR(v_TotalAmount,'FM999G999G999'));
    END LOOP;
    CLOSE v_Cursor;
END;
/

--UPDATE_INVOICE_STATUS
BEGIN
    pkg_invoice.Update_Invoice_Status(
        p_InvoiceID => 2000001,  -- ID invoice cần cập nhật
        p_StatusID  => 2         -- ví dụ 2 = "Paid"
    );
    DBMS_OUTPUT.PUT_LINE('Invoice status updated.');
END;
/
select * from invoices where invoiceid = 2000001;

--GET_INVOICE_DETAILS
SET SERVEROUTPUT ON;

DECLARE
    v_Cursor SYS_REFCURSOR;
    v_PaymentID NUMBER;
    v_InvoiceID NUMBER;
    v_PaymentDate DATE;
    v_MethodID NUMBER;
    v_AmountPaid NUMBER;
    v_MethodName VARCHAR2(100);
BEGIN
    pkg_invoice.Get_Invoice_Details(
        p_InvoiceID => 2000001,   -- ID invoice cần xem chi tiết
        p_Cursor    => v_Cursor
    );

    LOOP
        FETCH v_Cursor INTO v_PaymentID, v_InvoiceID, v_PaymentDate, v_MethodID, v_AmountPaid, v_MethodName;
        EXIT WHEN v_Cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('PaymentID=' || v_PaymentID || ', Amount=' || TO_CHAR(v_AmountPaid,'FM999G999G999') || ', Method=' || v_MethodName);
    END LOOP;
    CLOSE v_Cursor;
END;
/

-----------------------------------------------------------------------------------
--Package: pkg_product
--Specification
CREATE OR REPLACE PACKAGE pkg_product AS

    -- Cập nhật giá sản phẩm
    PROCEDURE Update_Product_Price(
        p_ProductID     IN NUMBER,
        p_NewPrice      IN NUMBER,
        p_EffectiveDate IN DATE DEFAULT SYSDATE
    );

    -- Lấy giá hiện tại
    FUNCTION Get_Current_Price(
        p_ProductID IN NUMBER
    ) RETURN NUMBER;

    -- Phân trang Products
    PROCEDURE Get_Products_Paginated(
        p_Page       IN NUMBER,
        p_PageSize   IN NUMBER,
        p_Cursor     OUT SYS_REFCURSOR
    );

    -- Lấy danh sách Product theo Category
    PROCEDURE Get_Products_By_Category(
        p_CategoryID IN NUMBER,
        p_Cursor     OUT SYS_REFCURSOR
    );

    -- Lấy danh sách Product theo Status
    PROCEDURE Get_Products_By_Status(
        p_StatusID IN NUMBER,
        p_Cursor   OUT SYS_REFCURSOR
    );

END pkg_product;
/
--Body
CREATE OR REPLACE PACKAGE BODY pkg_product AS

    PROCEDURE Update_Product_Price(
        p_ProductID     IN NUMBER,
        p_NewPrice      IN NUMBER,
        p_EffectiveDate IN DATE DEFAULT SYSDATE
    ) AS
    BEGIN
        UPDATE Product_Prices
        SET ExpiryDate = p_EffectiveDate - (1/86400)
        WHERE ProductID = p_ProductID
          AND ExpiryDate IS NULL;

        INSERT INTO Product_Prices(PriceID, ProductID, Price, EffectiveDate, ExpiryDate)
        VALUES(Product_Prices_SEQ.NEXTVAL, p_ProductID, p_NewPrice, p_EffectiveDate, NULL);

        COMMIT;
    END Update_Product_Price;

    FUNCTION Get_Current_Price(p_ProductID IN NUMBER) RETURN NUMBER IS
        v_Price NUMBER;
    BEGIN
        SELECT Price INTO v_Price
        FROM Product_Prices
        WHERE ProductID = p_ProductID
          AND ExpiryDate IS NULL;

        RETURN v_Price;
    END Get_Current_Price;

    PROCEDURE Get_Products_Paginated(
        p_Page       IN NUMBER,
        p_PageSize   IN NUMBER,
        p_Cursor     OUT SYS_REFCURSOR
    ) AS
        v_Start NUMBER;
        v_End   NUMBER;
    BEGIN
        v_Start := (p_Page-1)*p_PageSize + 1;
        v_End := p_Page*p_PageSize;

        OPEN p_Cursor FOR
            SELECT * FROM (
                SELECT p.*, ROW_NUMBER() OVER (ORDER BY ProductID) AS rn
                FROM Products p
            )
            WHERE rn BETWEEN v_Start AND v_End;
    END Get_Products_Paginated;

    PROCEDURE Get_Products_By_Category(
        p_CategoryID IN NUMBER,
        p_Cursor     OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_Cursor FOR
            SELECT *
            FROM Products
            WHERE CategoryID = p_CategoryID;
    END Get_Products_By_Category;

    PROCEDURE Get_Products_By_Status(
        p_StatusID IN NUMBER,
        p_Cursor   OUT SYS_REFCURSOR
    ) AS
    BEGIN
        OPEN p_Cursor FOR
            SELECT *
            FROM Products
            WHERE StatusID = p_StatusID;
    END Get_Products_By_Status;

END pkg_product;
/

--TEST
--UPDATE_PRODUCT_PRICES
SET SERVEROUTPUT ON;

BEGIN
    pkg_product.Update_Product_Price(
        p_ProductID     => 5,
        p_NewPrice      => 40000,
        p_EffectiveDate => SYSDATE
    );
    DBMS_OUTPUT.PUT_LINE('Giá sản phẩm đã được cập nhật.');
END;
/
select * from product_prices where productid = 101;

--GET_CURENT_PRICE
SET SERVEROUTPUT ON;

DECLARE
    v_Price NUMBER;
BEGIN
    v_Price := pkg_product.Get_Current_Price(101);
    DBMS_OUTPUT.PUT_LINE('Giá hiện tại của ProductID 101: ' || TO_CHAR(v_Price,'FM999G999G999'));
END;
/

--GET_PRODUCT_PAGINATED
SET SERVEROUTPUT ON;

DECLARE
    v_Cursor SYS_REFCURSOR;
    v_ProductID NUMBER;
    v_ProductName VARCHAR2(100);
    v_CategoryID NUMBER;
    v_StatusID NUMBER;
    v_rn NUMBER;
BEGIN
    pkg_product.Get_Products_Paginated(
        p_Page     => 1,
        p_PageSize => 5,
        p_Cursor   => v_Cursor
    );

    LOOP
        FETCH v_Cursor INTO v_ProductID, v_ProductName, v_CategoryID, v_StatusID, v_rn;
        EXIT WHEN v_Cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ProductID=' || v_ProductID || ', Name=' || v_ProductName);
    END LOOP;
    CLOSE v_Cursor;
END;
/

--GET_PRODUCT_BY_CATEGORY
SET SERVEROUTPUT ON;

DECLARE
    v_Cursor SYS_REFCURSOR;
    v_ProductID NUMBER;
    v_ProductName VARCHAR2(100);
    v_CategoryID NUMBER;
    v_StatusID NUMBER;
BEGIN
    pkg_product.Get_Products_By_Category(
        p_CategoryID => 10,   -- ví dụ CategoryID=10
        p_Cursor     => v_Cursor
    );

    LOOP
        FETCH v_Cursor INTO v_ProductID, v_ProductName, v_CategoryID, v_StatusID;
        EXIT WHEN v_Cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ProductID=' || v_ProductID || ', Name=' || v_ProductName);
    END LOOP;
    CLOSE v_Cursor;
END;
/

--GET_PROCUCT_BY_STATUS
SET SERVEROUTPUT ON;

DECLARE
    v_Cursor SYS_REFCURSOR;
    v_ProductID NUMBER;
    v_ProductName VARCHAR2(100);
    v_CategoryID NUMBER;
    v_StatusID NUMBER;
BEGIN
    pkg_product.Get_Products_By_Status(
        p_StatusID => 1,   -- ví dụ StatusID=1
        p_Cursor   => v_Cursor
    );

    LOOP
        FETCH v_Cursor INTO v_ProductID, v_ProductName, v_CategoryID, v_StatusID;
        EXIT WHEN v_Cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ProductID=' || v_ProductID || ', Name=' || v_ProductName);
    END LOOP;
    CLOSE v_Cursor;
END;
/