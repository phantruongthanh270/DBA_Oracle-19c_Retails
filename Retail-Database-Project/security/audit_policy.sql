--Kiểm tra cấu hình hiện tại
Show parameter audit;

--Kiểm tra các đối tượng đang được audit
SELECT * FROM DBA_OBJ_AUDIT_OPTS WHERE OWNER = 'RETAIL_USER';

--Kiểm tra loại auditing được bật trong Oracle
SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Unified Auditing';

--Tạo Audit Policy (dùng trong Unified Auditing)
CREATE AUDIT POLICY retail_table_audit ACTIONS SELECT ON SCHEMA retail_user;
CREATE AUDIT POLICY retail_table_audit ACTIONS INSERT ON SCHEMA retail_user;
CREATE AUDIT POLICY retail_table_audit ACTIONS UPDATE ON SCHEMA retail_user;
CREATE AUDIT POLICY retail_table_audit ACTIONS DELETE ON SCHEMA retail_user;

--Bật chế độ audit truyền thống (nếu chưa bật Unified Auditing)
ALTER SYSTEM SET audit_trail = DB, EXTENDED SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;

--Bật audit cho việc tạo và xóa bảng
AUDIT CREATE TABLE BY ACCESS;
AUDIT DROP TABLE BY ACCESS;

--Bật audit cho các thao tác DML trên bảng CUSTOMERS
AUDIT INSERT, UPDATE, DELETE ON RETAIL_USER.CUSTOMERS BY ACCESS;

--Bật audit cho các hành động quản trị hệ thống
AUDIT GRANT ANY PRIVILEGE;
AUDIT CREATE USER;
AUDIT ALTER USER;