--kiểm tra tất cả người dùng bên trong cơ sở dữ liệu
select username, account_status, default_tablespace from dba_users;

--kiểm tra người dùng hiện tại
show user;

--khóa / mở khóa người dùng
alter user scott account unlock;
alter user scott account lock;

--tìm không gian bảng mặc định của cơ sở dữ liệu.
select PROPERTY_NAME, PROPERTY_VALUE from database_properties where PROPERTY_NAME like '%DEFAULT%';

--Tạo tablespace riêng cho user
CREATE TABLESPACE operator_ts DATAFILE '/u02/oradata/ORCL/orclpdb/operator_ts01.dbf' SIZE 100M;
CREATE TABLESPACE analyst_ts DATAFILE '/u02/oradata/ORCL/orclpdb/analyst_ts01.dbf' SIZE 50M;

--Admin
CREATE ROLE role_admin;
GRANT CREATE USER, DROP USER, GRANT ANY PRIVILEGE TO role_admin;
GRANT CREATE TABLE, DROP ANY TABLE, ALTER ANY TABLE TO role_admin;
GRANT CREATE VIEW TO role_admin;
GRANT CREATE SEQUENCE TO role_admin;
GRANT CREATE TRIGGER TO role_admin;
      
--Thu hồi quyền
REVOKE ALTER SYSTEM FROM role_admin;
REVOKE BACKUP ANY TABLE FROM role_admin;

--Kiểm tra quyền
SELECT grantee, privilege FROM dba_sys_privs WHERE grantee = 'ROLE_ADMIN';

--Operator
CREATE ROLE role_operator;
GRANT SELECT, INSERT, UPDATE ON Orders TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Order_Details TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Invoices TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Order_Invoices TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Payments TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Customers TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Customer_Addresses TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Branch_Employees TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Branch_Managers TO role_operator;
GRANT SELECT, INSERT, UPDATE ON Sale_Staffs TO role_operator;

GRANT SELECT ON Product_Categories TO role_operator;
GRANT SELECT ON Product_Units TO role_operator;
GRANT SELECT ON Product_Status TO role_operator;

GRANT SELECT ON Employee_Types TO role_operator;
GRANT SELECT ON Employee_Status TO role_operator;

GRANT SELECT ON Customer_Types TO role_operator;
GRANT SELECT ON Customer_Status TO role_operator;

GRANT SELECT ON Branch_Types TO role_operator;
GRANT SELECT ON Branch_Status TO role_operator;

GRANT SELECT ON Sale_Channels TO role_operator;

GRANT SELECT ON Payment_Methods TO role_operator;

GRANT SELECT ON Invoice_Status TO role_operator;
--Kiểm tra quyền
SELECT grantee, privilege, table_name FROM dba_tab_privs WHERE grantee = 'ROLE_OPERATOR';

-- Analyst
CREATE ROLE role_analyst;
GRANT SELECT ON Orders TO role_analyst;
GRANT SELECT ON Order_Details TO role_analyst;
GRANT SELECT ON Order_Status TO role_analyst;
GRANT SELECT ON Invoices TO role_analyst;
GRANT SELECT ON Order_Invoices TO role_analyst;
GRANT SELECT ON Payments TO role_analyst;
GRANT SELECT ON Customers TO role_analyst;
GRANT SELECT ON Customer_Addresses TO role_analyst;
GRANT SELECT ON Products TO role_analyst;
GRANT SELECT ON Product_Prices TO role_analyst;
GRANT SELECT ON Branches TO role_analyst;
GRANT SELECT ON Branch_Employees TO role_analyst;
GRANT SELECT ON Branch_Managers TO role_analyst;
GRANT SELECT ON Sale_Staffs TO role_analyst;

GRANT SELECT ON Product_Categories TO role_analyst;
GRANT SELECT ON Product_Units TO role_analyst;
GRANT SELECT ON Product_Status TO role_analyst;

GRANT SELECT ON Employee_Types TO role_analyst;
GRANT SELECT ON Employee TO role_analyst;
GRANT SELECT ON Employee_Status TO role_analyst;
GRANT SELECT ON Employee_Salaries TO role_analyst;

GRANT SELECT ON Customer_Types TO role_analyst;
GRANT SELECT ON Customer_Status TO role_analyst;

GRANT SELECT ON Branch_Types TO role_analyst;
GRANT SELECT ON Branch_Status TO role_analyst;

GRANT SELECT ON Sale_Channels TO role_analyst;

GRANT SELECT ON Invoice_Status TO role_analyst;

GRANT SELECT ON Payment_Methods TO role_analyst;


--Kiểm tra quyền
SELECT grantee, privilege, table_name FROM dba_tab_privs WHERE grantee = 'ROLE_ANALYST';

--Cấp quyền cơ bản
GRANT CREATE SESSION TO role_admin;
GRANT CREATE SESSION TO role_operator;
GRANT CREATE SESSION TO role_analyst;

--Tạo user Admin
CREATE USER admin1 IDENTIFIED BY admin123 DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT role_admin TO admin1;

---Tạo user Operator
CREATE USER operator1 IDENTIFIED BY op123 DEFAULT TABLESPACE operator_ts QUOTA 100M ON operator_ts;
CREATE USER operator2 IDENTIFIED BY op123 DEFAULT TABLESPACE operator_ts QUOTA 100M ON operator_ts;
CREATE USER operator3 IDENTIFIED BY op123 DEFAULT TABLESPACE operator_ts QUOTA 100M ON operator_ts;
GRANT role_operator TO operator1, operator2, operator3;

---Tạo user Analyst
CREATE USER analyst1 IDENTIFIED BY an123 DEFAULT TABLESPACE analyst_ts QUOTA 50M ON analyst_ts;
CREATE USER analyst2 IDENTIFIED BY an123 DEFAULT TABLESPACE analyst_ts QUOTA 50M ON analyst_ts;
GRANT role_analyst TO analyst1, analyst2;

--Tạo profile để quản lý bảo mật và tài nguyên:
CREATE PROFILE retail_user_profile LIMIT
  SESSIONS_PER_USER 3
  CPU_PER_SESSION 6000
  CONNECT_TIME 60
  IDLE_TIME 30
  FAILED_LOGIN_ATTEMPTS 5
  PASSWORD_LIFE_TIME 90;

--Gán profile cho user
ALTER USER operator1 PROFILE retail_user_profile;
ALTER USER analyst1 PROFILE retail_user_profile;


--------------------------------------------------------------------------------
--kiểm tra lại thông tin profile bằng
SELECT * FROM DBA_PROFILES WHERE PROFILE = 'RETAIL_USER_PROFILE';

-- Kiểm tra role của user
SELECT * FROM dba_role_privs WHERE grantee = 'OPERATOR1';

-- Kiểm tra quyền hệ thống
SELECT * FROM dba_sys_privs WHERE grantee = 'ROLE_OPERATOR';

-- Kiểm tra quyền trên đối tượng
SELECT * FROM dba_tab_privs WHERE grantee = 'ROLE_ANALYST';

-- Kiểm tra quota
SELECT * FROM dba_ts_quotas WHERE username = 'OPERATOR1';