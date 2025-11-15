# 04. Chính sách Bảo mật & Phân quyền Hệ thống RetailDB

## 1. Mục tiêu của Chính sách Bảo mật

Chính sách bảo mật nhằm đảm bảo:
- Tính bảo mật (Confidentiality): Chỉ người có quyền mới được truy cập dữ liệu.
- Tính toàn vẹn (Integrity): Dữ liệu không bị sửa đổi trái phép.
- Tính sẵn sàng (Availability): Hệ thống có thể truy cập khi cần thiết.

---

## 2. Các Nguyên tắc Bảo mật Chính

- Nguyên tắc phân quyền tối thiểu (Least Privilege): Người dùng chỉ được cấp đúng quyền phù hợp nhiệm vụ.
- Tách biệt trách nhiệm (Separation of Duties): Không một tài khoản nào được toàn quyền từ ETL → DB → Admin.
- Không sử dụng tài khoản SYS/SYSTEM cho workflow hàng ngày.
- Ghi log truy cập đầy đủ: Truy vết các hành động INSERT/UPDATE/DELETE.

---

## 3. Các Loại Role trong Hệ Thống

| Role | Vai trò | Mô tả nhóm Quyền |
|------|---------|------------------|
| role_operator | Ứng dụng Retail | SELECT/INSERT/UPDATE các bảng giao dịch |
| role_analyst | Xem báo cáo | Chỉ có SELECT |
| role_admin | DBA quản trị | Toàn quyền |

---

## 4. Các Quyền Cấp Cho Mỗi Nhóm Quyền

### 4.1. Role Operator
- INSERT/UPDATE/DELETE: Orders, Order_Details, Invoices, Order_Invoices, Payments, Customers, Customer_Addresses, Branch_Managers, Sale_Staffs.
- SELECT: Product_Categories, Product_Units, Product_Status, Employee_Types, Employee_Status, Customer_Types, Customer_Status, Branch_Types, Branch_Status, Sale_Channels.
- Với các User: operator1, operator2, operator3, ...

### 4.2. Role Analysts
- SELECT: Trên tất cả các bảng
- Với các user: analyst1, analyst2, ...

### 4.3. Role Admin
- CREATE USER, DROP USER, GRANT ANY PRIVILEGE.
- CREATE TABLE, DROP ANY TABLE, ALTER ANY TABLE.
- CREATE VIEW.
- CREATE SEQUENCE.
- CREATE TRIGGER.
- Với các user: admin1, ...

---

## 5. Ghi Log & Theo dõi

Các loại log cần lưu:
- Nhật ký chạy ETL (run.log)
- Log lỗi SQL*Loader (.bad, .log)
- Log truy cập người dùng Oracle (DBA_AUDIT_TRAIL)

---

## 6. Chính sách Sao lưu Dữ liệu Bảo mật

- Backup mỗi giờ, ngày, tuần bằng RMAN (chi tiết trong file 05_Backup_Recovery_Guide.md).
- Backup phải mã hóa trước khi chuyển ra ngoài.
- Chỉ DBA được phép truy cập backup.

--- 

## 7. Quy trình Xử lý Vi phạm Bảo mật

- Khóa user bị nghi ngờ: ```SQL: ALTER USER <username> ACCOUNT LOCK;```
- Kiểm tra log tại DBA_AUDIT_TRAIL.
- Phân tích lại hành vi trong 24h gần nhất.
- Khôi phục dữ liệu nếu bị mất.
- Báo cáo sự cố và cập nhật chính sách nếu cần.