--Khách hàng có tổng chi tiêu cao nhất
EXPLAIN PLAN FOR
SELECT *
FROM (
    SELECT c.CustomerID, c.FullName,
           (SELECT SUM(o.TotalAmount)
            FROM Orders o
            WHERE o.CustomerID = c.CustomerID
              AND TO_CHAR(o.OrderDate, 'YYYY-MM') = '2024-12') AS TotalSpent
    FROM Customers c
)
ORDER BY TotalSpent DESC
FETCH FIRST 10 ROWS ONLY;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
    
--sản phẩm bán chạy nhất
EXPLAIN PLAN FOR
SELECT p.ProductName,
       (SELECT SUM(d.Quantity)
        FROM Order_Details d
        WHERE d.ProductID = p.ProductID) AS TotalSold,
       (SELECT SUM(d.Quantity * d.UnitPrice)
        FROM Order_Details d
        WHERE d.ProductID = p.ProductID) AS Revenue
FROM Products p
ORDER BY TotalSold DESC
FETCH FIRST 10 ROWS ONLY;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
 
--Xem đơn hàng của khách hàng
EXPLAIN PLAN FOR
SELECT *
FROM Orders o, Order_Status os
WHERE o.StatusID = os.StatusID
  AND o.CustomerID IN (SELECT CustomerID FROM Customers WHERE CustomerID = :customer_id)
ORDER BY TO_CHAR(o.OrderDate, 'YYYY-MM-DD') DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Xem chi tiết đơn hàng
EXPLAIN PLAN FOR
SELECT *
FROM Orders o
JOIN Order_Details d ON o.OrderID = d.OrderID
JOIN Products p ON UPPER(d.ProductID) = UPPER(p.ProductID)
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderID IN (SELECT OrderID FROM Orders WHERE OrderID = :order_id);
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Danh sách đơn hàng theo chi nhánh
EXPLAIN PLAN FOR
SELECT *
FROM Orders o
WHERE o.BranchID = :branch_id
  AND TO_CHAR(o.OrderDate, 'YYYY-MM-DD') BETWEEN :start_date AND :end_date
ORDER BY o.OrderDate DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Hóa đơn của một đơn hàng
EXPLAIN PLAN FOR
SELECT *
FROM Invoices i
WHERE i.InvoiceID IN (
    SELECT oi.InvoiceID
    FROM Order_Invoices oi
    WHERE oi.OrderID = :order_id
)
ORDER BY TO_CHAR(i.InvoiceDate, 'YYYY-MM-DD');
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Thanh toán của một hóa đơn
EXPLAIN PLAN FOR
SELECT *
FROM Payments p
WHERE p.MethodID IN (SELECT MethodID FROM Payment_Methods)
  AND p.InvoiceID = :invoice_id
ORDER BY TO_CHAR(p.PaymentDate, 'YYYY-MM-DD');
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Danh sách sản phẩm đang bán
EXPLAIN PLAN FOR
SELECT *
FROM Products
WHERE StatusID IN (
    SELECT StatusID FROM Product_Status
    WHERE LOWER(StatusName) IN ('còn hàng', 'đặt trước')
)
ORDER BY LOWER(ProductName);
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Tìm kiếm sản phẩm theo tên
EXPLAIN PLAN FOR
SELECT *
FROM Products
WHERE ProductName LIKE '%' || :keyword || '%'
   OR Description LIKE '%' || :keyword || '%'
ORDER BY ProductName;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Danh sách nhân viên theo chi nhánh
EXPLAIN PLAN FOR
SELECT e.EmployeeID, e.FullName, et.TypeName, es.StatusName
FROM Branch_Employees be
JOIN Employees e ON be.EmployeeID = e.EmployeeID
LEFT JOIN Employee_Types et ON e.TypeID = et.TypeID
LEFT JOIN Employee_Status es ON e.StatusID = es.StatusID
WHERE be.BranchID = :branch_id;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Xem doanh số trong ngày của chi nhánh
EXPLAIN PLAN FOR
SELECT *
FROM Orders
WHERE BranchID = :branch_id
  AND TO_CHAR(OrderDate, 'YYYY-MM-DD') = :Ordate;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);