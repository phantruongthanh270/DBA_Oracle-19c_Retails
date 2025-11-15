--Khách hàng có tổng chi tiêu cao nhất
EXPLAIN PLAN FOR
SELECT *
FROM MV_CUSTOMER_MONTHLY_SPENDING
WHERE Month_Year = '2024-11'
ORDER BY TotalSpent DESC
FETCH FIRST 10 ROWS ONLY;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
    
--Sản phẩm bán chạy nhất
EXPLAIN PLAN FOR
SELECT
    p.ProductName,
    SUM(d.Quantity) AS TotalSold,
    SUM(d.Quantity * d.UnitPrice) AS Revenue
FROM Order_Details d
JOIN Products p ON d.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSold DESC
FETCH FIRST 10 ROWS ONLY;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Xem đơn hàng của khách hàng
EXPLAIN PLAN FOR
SELECT 
    o.OrderID,
    o.OrderDate,
    os.StatusName,
    o.TotalAmount
FROM Orders o
JOIN Order_Status os ON o.StatusID = os.StatusID
WHERE o.CustomerID = :customer_id
ORDER BY o.OrderDate DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
    
--Xem chi tiết đơn hàng
EXPLAIN PLAN FOR
SELECT
    o.OrderID,
    c.FullName,
    p.ProductName,
    d.Quantity,
    d.UnitPrice,
    (d.Quantity * d.UnitPrice) AS Subtotal
FROM Orders o
JOIN Order_Details d ON o.OrderID = d.OrderID
JOIN Products p ON d.ProductID = p.ProductID
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderID = :order_id;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Danh sách đơn hàng theo chi nhánh
EXPLAIN PLAN FOR
SELECT o.OrderID, o.OrderDate, c.FullName AS CustomerName, o.TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.BranchID = :branch_id
  AND o.OrderDate BETWEEN TO_DATE(:start_date, 'YYYY-MM-DD') 
                      AND TO_DATE(:end_date, 'YYYY-MM-DD')
ORDER BY o.OrderDate DESC;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Hóa đơn của một đơn hàng
EXPLAIN PLAN FOR
SELECT i.InvoiceID, i.InvoiceDate, i.TotalAmount, ist.StatusName
FROM Order_Invoices oi
JOIN Invoices i ON oi.InvoiceID = i.InvoiceID
JOIN Invoice_Status ist ON i.StatusID = ist.StatusID
WHERE oi.OrderID = :order_id;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Thanh toán của một hóa đơn
EXPLAIN PLAN FOR
SELECT p.PaymentID, p.PaymentDate, pm.MethodName, p.AmountPaid
FROM Payments p
JOIN Payment_Methods pm ON p.MethodID = pm.MethodID
WHERE p.InvoiceID = :invoice_id
ORDER BY p.PaymentDate;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Danh sách sản phẩm đang bán
EXPLAIN PLAN FOR
SELECT p.ProductID, p.ProductName, pc.CategoryName, ps.StatusName
FROM Products p
LEFT JOIN Product_Categories pc ON p.CategoryID = pc.CategoryID
LEFT JOIN Product_Status ps ON p.StatusID = ps.StatusID
WHERE ps.StatusName = 'Còn hàng' OR ps.StatusName = 'Đặt trước'
ORDER BY p.ProductName;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Tìm kiếm sản phẩm theo tên
EXPLAIN PLAN FOR
SELECT ProductID, ProductName, CategoryID
FROM Products
WHERE LOWER(ProductName) LIKE LOWER('%'||:keyword||'%')
FETCH FIRST 50 ROWS ONLY;
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
SELECT 
    o.BranchID, 
    SUM(o.TotalAmount) AS TotalSales
FROM Orders o
WHERE o.BranchID = :branch_id
  AND o.OrderDate >= TO_DATE(:Ordate, 'YYYY-MM-DD')
  AND o.OrderDate <  TO_DATE(:Ordate, 'YYYY-MM-DD') + 1
GROUP BY o.BranchID;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);