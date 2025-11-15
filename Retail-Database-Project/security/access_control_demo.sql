----------Operator User------------
SHOW USER;

-- SELECT
SELECT * FROM RETAIL_USER.Orders WHERE OrderID = 10000001;

-- INSERT
INSERT INTO RETAIL_USER.Orders(OrderID, CustomerID, BranchID, TotalAmount)
VALUES (10000001, 1, 1, 1000);

-- UPDATE
UPDATE RETAIL_USER.Orders SET TotalAmount = 2000 WHERE OrderID = 10000001;

-- DELETE
DELETE FROM RETAIL_USER.Orders WHERE OrderID = 10000001;

-- Thử thao tác trên bảng analyst-only hoặc admin-only → lỗi
SELECT * FROM RETAIL_USER.Products; -- lỗi


----------Analyst User------------
SELECT * FROM RETAIL_USER.Orders; -- OK
SELECT * FROM RETAIL_USER.Products; -- OK

INSERT INTO RETAIL_USER.Orders(OrderID, CustomerID, BranchID, TotalAmount)
VALUES (999999, 1, 1, 1000); -- lỗi

UPDATE RETAIL_USER.Orders SET TotalAmount = 2000 WHERE OrderID = 999999; -- lỗi

DELETE FROM RETAIL_USER.Orders WHERE OrderID = 999999; -- lỗi

SELECT
    o.OrderID,
    c.FullName,
    p.ProductName,
    d.Quantity,
    d.UnitPrice,
    (d.Quantity * d.UnitPrice) AS Subtotal
FROM RETAIL_USER.Orders o
JOIN RETAIL_USER.Order_Details d ON o.OrderID = d.OrderID
JOIN RETAIL_USER.Products p ON d.ProductID = p.ProductID
JOIN RETAIL_USER.Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderID = :order_id;

--Phân loại khách hàng theo mức chi tiêu (CASE + subquery + analytic):
WITH cust_total AS (
    SELECT c.CustomerID, c.FullName, SUM(o.TotalAmount) AS TotalSpent
    FROM   RETAIL_USER.Orders o
    JOIN   RETAIL_USER.Customers c ON o.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.FullName
)
SELECT /*+ MONITOR */ FullName,
    TotalSpent,
    CASE 
        WHEN TotalSpent >= 10000000 THEN 'VIP'
        WHEN TotalSpent BETWEEN 5000000 AND 9999999 THEN 'Preferred'
        ELSE 'Regular'
    END AS CustomerLevel,
    NTILE(4) OVER (ORDER BY TotalSpent DESC) AS Quartile
FROM   cust_total
ORDER BY TotalSpent DESC;
    
--Doanh thu chi nhánh theo tháng
WITH branch_monthly AS (
    SELECT b.BranchName,
            TRUNC(o.OrderDate, 'MM') AS OrderMonth,
            SUM(o.TotalAmount) AS MonthlyRevenue
    FROM   RETAIL_USER.Orders o
    JOIN   RETAIL_USER.Branches b ON o.BranchID = b.BranchID
    GROUP BY b.BranchName, TRUNC(o.OrderDate, 'MM')
)
SELECT /*+ MONITOR */  *
FROM   branch_monthly
ORDER BY BranchName, OrderMonth;

--Phân tích hiệu suất bán hàng theo chi nhánh, nhân viên, và sản phẩm trong quý hiện tại
SELECT /*+ MONITOR */
    b.BranchName,
    e.FullName AS Salesperson,
    p.ProductName,
    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    ROUND(AVG(od.Quantity), 2) AS AvgQuantityPerOrder,
    RANK() OVER (PARTITION BY b.BranchID ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) AS RevenueRankInBranch,
    ROUND(
        SUM(CASE WHEN o.StatusID = (SELECT StatusID FROM RETAIL_USER.Order_Status WHERE StatusName = 'Đã giao') THEN 1 ELSE 0 END) * 100.0
        / COUNT(o.OrderID), 2) AS SuccessRate
FROM RETAIL_USER.Orders o
JOIN RETAIL_USER.Order_Details od ON o.OrderID = od.OrderID
JOIN RETAIL_USER.Products p ON od.ProductID = p.ProductID
JOIN RETAIL_USER.Sale_Staffs ss ON o.OrderID = ss.OrderID
JOIN RETAIL_USER.Employees e ON ss.EmployeeID = e.EmployeeID
JOIN RETAIL_USER.Branches b ON o.BranchID = b.BranchID
WHERE TO_CHAR(o.OrderDate, 'Q-YYYY') = TO_CHAR(SYSDATE, 'Q-YYYY')
GROUP BY b.BranchName, b.BranchID, e.FullName, p.ProductName
ORDER BY b.BranchName, RevenueRankInBranch;

----------Admin User------------
CREATE TABLE RETAIL_USER.test_admin(id NUMBER);
DROP TABLE RETAIL_USER.test_admin;

CREATE USER test_user IDENTIFIED BY test123;
DROP USER test_user;

SELECT * FROM USER_SYS_PRIVS;
SELECT * FROM USER_TAB_PRIVS;
SELECT * FROM ROLE_SYS_PRIVS;
