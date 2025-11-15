# Explanation

File này sinh ra các bảng quan hệ phụ thuộc (relationship tables) kết nối dữ liệu giữa các thực thể (nhân viên, khách hàng, chi nhánh, sản phẩm…).
Nó yêu cầu Entities đã được sinh trước.

## 1. Nhóm hàm dùng chung

### 1.1. next_ids(table_name, n)
- Sinh n ID mới theo dạng tăng dần.
- Lấy ID cũ từ id_tracker → tạo ID mới nối tiếp → lưu lại.
- Đảm bảo không trùng ID khi sinh nhiều lần.

### 1.2. ensure_entities_exist(required_tables)
- Kiểm tra xem các bảng Entities (Employees, Products…) đã tồn tại ID chưa.
- Nếu thiếu → dừng, tránh sinh dữ liệu sai hoặc rỗng.

---

## 2. Các bảng quan hệ

### 2.1. generate_employee_salaries()
Sinh lịch sử lương nhân viên:
- Mỗi nhân viên có 1–n bản ghi (đủ để mô phỏng tăng lương).
- Gồm BaseSalary, Bonus, EffectiveDate, ExpiryDate.
- Ngày hiệu lực và ngày hết hạn được đảm bảo theo đúng thời gian thực.

Tạo file: Employee_Salaries.csv

### 2.2. generate_customer_addresses()
Sinh 1–3 địa chỉ cho mỗi khách hàng:
- Địa chỉ gồm: Street, City, District, Province, PostalCode.
- Danh sách tỉnh/thành được liệt kê trước.
- Tự đánh số AddressID.

Tạo file: Customer_Addresses.csv

### 2.3. generate_product_prices()
Sinh lịch sử giá sản phẩm (giá thay đổi theo thời gian):
- Mỗi sản phẩm có 1–3 mức giá.
- Mỗi giá có EffectiveDate / ExpiryDate.
- Giá trong khoảng 20.000 – 5.000.000.

Tạo file: Product_Prices.csv

### 2.4. generate_branch_managers()
Sinh danh sách quản lý chi nhánh:
- Mỗi chi nhánh có 1 nhân viên được chọn ngẫu nhiên làm quản lý.
- Tạo StartDate hợp lý.

Tạo file: Branch_Managers.csv

### 2.5. generate_branch_employees()
Sinh danh sách nhân viên làm việc ở từng chi nhánh:
- Mỗi chi nhánh có 15–20 nhân viên.
- Gán vị trí: Thu ngân, Tư vấn, Bảo vệ, Giao hàng, Quản kho.
- Lưu thêm mapping BranchEmployeeID → {BranchID, EmployeeID} vào id_tracker (dùng cho Orders/Invoices sau này).

Tạo file: Branch_Employees.csv >> Lưu mapping id vào Branch_Employees trong id_tracker.

### 2.6. generate_branch_customers() (tùy chọn – đang tắt)
Sinh danh sách khách hàng từng ghé chi nhánh:
- Mỗi chi nhánh có 200–1000 khách.
- Lưu ngày FirstVisitDate.

Tạo file: Branch_Customers.csv >> (Hiện đang comment trong main().)

---

## 3. Hàm main()

Chạy tất cả các bước sinh relations theo thứ tự:
- Employee Salaries
- Customer Addresses
- Product Prices
- Branch Managers
- Branch Employees
- Branch Customers (nếu bật)

Kết thúc với thông báo hoàn tất.