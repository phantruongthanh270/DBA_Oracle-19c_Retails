--Danh mục sản phẩm
CREATE TABLE Product_Categories (
    CategoryID NUMBER PRIMARY KEY,
    CategoryName VARCHAR2(100) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

--Đơn vị tính sản phẩm
CREATE TABLE Product_Units (
    UnitID NUMBER PRIMARY KEY,
    UnitName VARCHAR2(50) NOT NULL,
    ConversionRate NUMBER(18,6) NOT NULL
)
TABLESPACE master_ts;

--Trạng thái sản phẩm
CREATE TABLE Product_Status (
    StatusID NUMBER PRIMARY KEY,
    StatusName VARCHAR2(50) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

--Sảng phẩm
CREATE TABLE Products (
    ProductID NUMBER PRIMARY KEY,
    ProductName VARCHAR2(255) NOT NULL,
    CategoryID NUMBER,
    UnitID NUMBER,
    StatusID NUMBER,
    Description CLOB,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_category FOREIGN KEY (CategoryID) REFERENCES Product_Categories(CategoryID),
    CONSTRAINT fk_product_unit FOREIGN KEY (UnitID) REFERENCES Product_Units(UnitID),
    CONSTRAINT fk_product_status FOREIGN KEY (StatusID) REFERENCES Product_Status(StatusID)
)
TABLESPACE master_ts;

--Giá sản phẩm
CREATE TABLE Product_Prices (
    PriceID NUMBER PRIMARY KEY,
    ProductID NUMBER NOT NULL,
    Price NUMBER(10,2) NOT NULL,
    EffectiveDate TIMESTAMP NOT NULL,
    ExpiryDate TIMESTAMP,
    CONSTRAINT fk_price_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
)
TABLESPACE orders_ts;

--Trạng thái nhân viên
CREATE TABLE Employee_Status (
    StatusID NUMBER PRIMARY KEY,
    StatusName VARCHAR2(50) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

--Loại nhân viên
CREATE TABLE Employee_Types (
    TypeID NUMBER PRIMARY KEY,
    TypeName VARCHAR2(50) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

--Nhân viên
CREATE TABLE Employees (
    EmployeeID NUMBER PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    TypeID NUMBER,
    StatusID NUMBER,
    HireDate DATE,
    Email VARCHAR2(100),
    Phone VARCHAR2(20),
    CONSTRAINT fk_emp_type FOREIGN KEY (TypeID) REFERENCES Employee_Types(TypeID),
    CONSTRAINT fk_emp_status FOREIGN KEY (StatusID) REFERENCES Employee_Status(StatusID)
)
TABLESPACE master_ts;

--Lương nhân viên
CREATE TABLE Employee_Salaries (
    SalaryID NUMBER PRIMARY KEY,
    EmployeeID NUMBER NOT NULL,
    BaseSalary NUMBER(10,2),
    Bonus NUMBER(10,2),
    EffectiveDate DATE,
    ExpiryDate DATE,
    CONSTRAINT fk_salary_emp FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
)
TABLESPACE master_ts;

--Loại khách hàng
CREATE TABLE Customer_Types (
    TypeID NUMBER PRIMARY KEY,
    TypeName VARCHAR2(50) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

--Trạng thái khách hàng
CREATE TABLE Customer_Status (
    StatusID NUMBER PRIMARY KEY,
    StatusName VARCHAR2(50) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

--Khách hàng
CREATE TABLE Customers (
    CustomerID NUMBER PRIMARY KEY,
    FullName VARCHAR2(100) NOT NULL,
    TypeID NUMBER,
    StatusID NUMBER,
    Email VARCHAR2(100),
    Phone VARCHAR2(20),
    RegistrationDate DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_cust_type FOREIGN KEY (TypeID) REFERENCES Customer_Types(TypeID),
    CONSTRAINT fk_cust_status FOREIGN KEY (StatusID) REFERENCES Customer_Status(StatusID)
)
TABLESPACE master_ts;

--Địa chỉ khách hàng
CREATE TABLE Customer_Addresses (
    AddressID NUMBER PRIMARY KEY,
    CustomerID NUMBER NOT NULL,
    Street VARCHAR2(100),
    City VARCHAR2(50),
    District VARCHAR2(50),
    Province VARCHAR2(50),
    PostalCode VARCHAR2(10),
    CONSTRAINT fk_address_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
)
TABLESPACE master_ts;

--Loại cửa hàng
CREATE TABLE Branch_Types (
    BranchTypeID NUMBER PRIMARY KEY,
    TypeName VARCHAR2(50) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

--Trạng thái cửa hàng
CREATE TABLE Branch_Status (
    BranchStatusID NUMBER PRIMARY KEY,
    StatusName VARCHAR2(50) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

--Chi nhánh cửa hàng
CREATE TABLE Branches (
    BranchID NUMBER PRIMARY KEY,
    BranchName VARCHAR2(100) NOT NULL,
    TypeID NUMBER,
    StatusID NUMBER,
    Address VARCHAR2(255),
    Phone VARCHAR2(20),
    Email VARCHAR2(100),
    CreatedDate DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_branch_type FOREIGN KEY (TypeID) REFERENCES Branch_Types(BranchTypeID),
    CONSTRAINT fk_branch_status FOREIGN KEY (StatusID) REFERENCES Branch_Status(BranchStatusID)
)
TABLESPACE master_ts;

--Quản lý cửa hàng
CREATE TABLE Branch_Managers (
    BranchManagerID NUMBER PRIMARY KEY,
    BranchID NUMBER NOT NULL,
    EmployeeID NUMBER NOT NULL,
    StartDate DATE,
    CONSTRAINT fk_manager_branch FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    CONSTRAINT fk_branch_emp_mgr FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
)
TABLESPACE master_ts;

--Nhân viên của cửa hàng
CREATE TABLE Branch_Employees (
    BranchEmployeeID NUMBER PRIMARY KEY,
    BranchID NUMBER NOT NULL,
    EmployeeID NUMBER NOT NULL,
    Position VARCHAR2(100),
    StartDate DATE,
    CONSTRAINT fk_emp_branch FOREIGN KEY (BranchID) REFERENCES Branches(BranchID),
    CONSTRAINT fk_branch_emp_rel FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
)
TABLESPACE master_ts;

--Trạng thái đơn hàng
CREATE TABLE Order_Status (
    StatusID NUMBER PRIMARY KEY,
    StatusName VARCHAR2(50),
    Description CLOB
)
TABLESPACE master_ts;

--Trạng thái hóa đơn
CREATE TABLE Invoice_Status (
    StatusID NUMBER PRIMARY KEY,
    StatusName VARCHAR2(50),
    Description CLOB
)
TABLESPACE master_ts;

-- Đơn hàng
CREATE TABLE Orders (
    OrderID      NUMBER PRIMARY KEY,
    CustomerID   NUMBER NOT NULL,
    BranchID     NUMBER NOT NULL,
    OrderDate    DATE DEFAULT CURRENT_DATE,
    StatusID     NUMBER,
    TotalAmount  NUMBER(10,2),
    CONSTRAINT fk_order_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT fk_order_status   FOREIGN KEY (StatusID) REFERENCES Order_Status(StatusID),
    CONSTRAINT fk_order_branch   FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
)
PARTITION BY RANGE (OrderDate)
INTERVAL (NUMTOYMINTERVAL(3, 'MONTH'))   -- Mỗi 3 tháng tự tạo phân vùng
SUBPARTITION BY HASH (BranchID)
SUBPARTITIONS 4
(
    PARTITION p_start VALUES LESS THAN (TO_DATE('2024-01-01','YYYY-MM-DD'))  -- Phân vùng gốc ban đầu
)
TABLESPACE orders_ts
NOLOGGING;

-- Chi tiết đơn hàng
CREATE TABLE Order_Details (
    OrderDetailID  NUMBER PRIMARY KEY,
    OrderID        NUMBER NOT NULL,
    ProductID      NUMBER NOT NULL,
    Quantity       NUMBER NOT NULL,
    UnitPrice      NUMBER(10,2),
    CONSTRAINT fk_detail_order   FOREIGN KEY (OrderID)  REFERENCES Orders(OrderID),
    CONSTRAINT fk_detail_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
)
PARTITION BY REFERENCE (fk_detail_order)  -- Kế thừa phân vùng từ Orders
TABLESPACE orders_ts
NOLOGGING;

-- Hóa đơn
CREATE TABLE Invoices (
    InvoiceID    NUMBER PRIMARY KEY,
    InvoiceDate  DATE DEFAULT CURRENT_DATE,
    StatusID     NUMBER,
    EmployeeID   NUMBER NOT NULL,
    TotalAmount  NUMBER(10,2),
    CONSTRAINT fk_invoice_status FOREIGN KEY (StatusID) REFERENCES Invoice_Status(StatusID),
    CONSTRAINT fk_emp_invoice    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
)
PARTITION BY RANGE (InvoiceDate)
INTERVAL (NUMTOYMINTERVAL(3, 'MONTH'))   -- Tự động tạo phân vùng mỗi quý
(
    PARTITION p_start VALUES LESS THAN (TO_DATE('2024-01-01','YYYY-MM-DD'))
)
TABLESPACE invoices_ts
NOLOGGING;

--Phương thức thanh toán
CREATE TABLE Payment_Methods (
    MethodID NUMBER PRIMARY KEY,
    MethodName VARCHAR2(50) NOT NULL,
    Description CLOB
)
TABLESPACE master_ts;

-- Thanh toán
CREATE TABLE Payments (
    PaymentID    NUMBER PRIMARY KEY,
    InvoiceID    NUMBER NOT NULL,
    PaymentDate  DATE DEFAULT CURRENT_DATE,
    MethodID     NUMBER NOT NULL,
    AmountPaid   NUMBER(10,2),
    CONSTRAINT fk_payment_invoice FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID),
    CONSTRAINT fk_payment_method  FOREIGN KEY (MethodID)  REFERENCES Payment_Methods(MethodID)
)
PARTITION BY RANGE (PaymentDate)
INTERVAL (NUMTOYMINTERVAL(3, 'MONTH'))
(
    PARTITION p_start VALUES LESS THAN (TO_DATE('2024-01-01','YYYY-MM-DD'))
)
TABLESPACE payments_ts
NOLOGGING;

--Kênh bán hàng
CREATE TABLE Sale_Channels (
    ChannelID NUMBER PRIMARY KEY,
    ChannelName VARCHAR2(100),
    Description CLOB
)
TABLESPACE master_ts;

-- Nhân viên bán hàng
CREATE TABLE Sale_Staffs (
    Sale_StaffID NUMBER PRIMARY KEY,
    OrderID      NUMBER NOT NULL,
    ChannelID    NUMBER NOT NULL,
    EmployeeID   NUMBER NOT NULL,
    ShippedDate  DATE,
    DeliveryDate DATE,
    Status       VARCHAR2(50),
    CONSTRAINT fk_sale_emp     FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    CONSTRAINT fk_staff_order  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT fk_staff_channel FOREIGN KEY (ChannelID) REFERENCES Sale_Channels(ChannelID)
)
PARTITION BY RANGE (ShippedDate)
INTERVAL (NUMTOYMINTERVAL(3, 'MONTH'))   -- Phân vùng tự động 3 tháng/lần
SUBPARTITION BY HASH (ChannelID)
SUBPARTITIONS 4
(
    PARTITION p_start VALUES LESS THAN (TO_DATE('2024-01-01','YYYY-MM-DD'))
)
TABLESPACE orders_ts
NOLOGGING;

-- Hóa đơn đơn hàng
CREATE TABLE Order_Invoices (
    OrderInvoiceID NUMBER PRIMARY KEY,
    OrderID  NUMBER NOT NULL,
    InvoiceID NUMBER NOT NULL,
    CONSTRAINT fk_oi_order   FOREIGN KEY (OrderID)  REFERENCES Orders(OrderID),
    CONSTRAINT fk_oi_invoice FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID)
)
PARTITION BY REFERENCE (fk_oi_order)   -- Kế thừa phân vùng từ Orders
TABLESPACE orders_ts
NOLOGGING;