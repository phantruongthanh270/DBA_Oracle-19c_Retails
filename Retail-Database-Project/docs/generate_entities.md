# Explanation

File này sinh ra các thực thể chính của hệ thống bán lẻ: Products, Employees, Customers, Branches.
Khác với catalogs (danh mục tĩnh), các thực thể này lớn, thay đổi nhiều và dùng trong các bảng giao dịch (orders, invoices…).

## 1. Nhóm hàm dùng chung

### 1.1. next_ids(table_name, n)
- Tự động tạo n ID mới theo dạng cộng dồn, để tránh trùng ID khi sinh nhiều lần.
- Lưu lại ID vào id_tracker phục vụ khóa ngoại.
- Trả về danh sách ID mới.

### 1.2. ensure_catalogs_exist(tables)
- Kiểm tra các bảng danh mục bắt buộc phải tồn tại trước khi sinh thực thể.
- Nếu thiếu → báo lỗi và dừng, tránh sinh dữ liệu sai.

### 1.3. load_unit_map()
- Đọc file Product_Units.csv.
- Trả về map UnitName → UnitID (dùng trong phần sinh sản phẩm).

---

## 2. Các hàm sinh dữ liệu

### 2.1. generate_products(n=15000)
Sinh ra ~15k (tùy chọn) sản phẩm với logic phong phú:
- Lấy dữ liệu từ danh mục: CategoryID, UnitID, StatusID.
- Map danh mục → từ khóa sản phẩm (VD: "Bánh kẹo" → "Snack", "Kẹo dẻo"...).
- Lấy đơn vị phù hợp với từng loại (VD: Đồ uống → Lít, Chai...).
- Sinh tên sản phẩm theo mẫu: Tên từ khóa + Thương hiệu
- Tạo mô tả + ngày tạo thực tế.
- Xuất ra Products.csv.

### 2.2. generate_employees(n=3500)
- Sinh ~3.5k nhân viên.
- Gán ngẫu nhiên: loại nhân viên, trạng thái làm việc.
- Sinh ngày tuyển dụng, email, số điện thoại.
- Xuất Employees.csv.

### 2.3. generate_customers(n=300000)
- Sinh số lượng rất lớn (~300k khách).
- Gán loại khách, trạng thái khách.
- Sinh email, số điện thoại, ngày đăng ký.
- Xuất Customers.csv.

### 2.4. generate_branches(n=120)
- Sinh ~120 chi nhánh.
- Gán loại chi nhánh, trạng thái, địa chỉ, số điện thoại.
- Tạo tên chi nhánh theo thành phố.
- Xuất Branches.csv.

---

## 3. Hàm main()

Chạy toàn bộ pipeline theo thứ tự: Products >> Employees >> Customers >> Branches