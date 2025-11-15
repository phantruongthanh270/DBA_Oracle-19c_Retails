# Explanation

File này sinh toàn bộ dữ liệu danh mục tĩnh của hệ thống bán lẻ, bao gồm: loại sản phẩm, trạng thái, loại nhân viên, phương thức thanh toán, trạng thái đơn hàng, v.v.
Đây là các bảng ít thay đổi và cần có trước khi sinh dữ liệu giao dịch.

Tất cả các hàm đều theo nguyên tắc chung:
- Tạo danh sách dữ liệu tĩnh (list).
- Chuyển thành data_rows dạng dictionary.
- Ghi ra file CSV bằng write_csv().
- Lưu danh sách ID vào id_tracker để dùng khi sinh khóa ngoại.
- In kết quả.

## 1. Các nhóm danh mục được sinh

### 1.1. Product catalogs (Sản phẩm)
- generate_product_categories(): Tạo 10 nhóm sản phẩm (đồ uống, bánh kẹo, gia vị...).
- generate_product_units(): Tạo các đơn vị tính chuẩn (Cái, Hộp, Gói, Kg…).
- generate_product_status(): Các trạng thái hàng hóa (Còn hàng / Hết hàng / Ngừng kinh doanh...).

### 1.2. Employee catalogs (Nhân viên)
- generate_employee_status(): Trạng thái làm việc (Đang làm / Nghỉ phép / Nghỉ hưu…).
- generate_employee_types(): Chức danh nhân viên (Thu ngân, Bán hàng, Kho, IT, Quản lý...).

### 1.3. Customer catalogs (Khách hàng)
- generate_customer_types(): Loại khách: Thường, VIP, Sỉ, Online.
- generate_customer_status(): Trạng thái khách hàng: Hoạt động / Cấm giao dịch...

### 1.4. Branch catalogs (Chi nhánh)
- generate_branch_types(): Các loại cửa hàng: bán lẻ, kho hàng, online...
- generate_branch_status(): Trạng thái chi nhánh: hoạt động / tạm đóng / bảo trì.

### 1.5. Order & Invoice catalogs
- generate_order_status(): Trạng thái đơn hàng.
- generate_invoice_status(): Trạng thái hoá đơn.

### 1.6. Payment / Sale catalogs
- generate_payment_methods(): Tiền mặt / thẻ / ví điện tử / chuyển khoản.
- generate_sale_channels(): Kênh bán hàng: trực tuyến, cửa hàng, đối tác.

---

## 2. Cách mỗi hàm hoạt động

Mỗi hàm làm đúng 3 việc:

### 2.1. Tạo dữ liệu tĩnh
- VD: 
```python 
statuses = ["Chờ xử lý", "Đang giao", "Đã giao", "Đã hủy"]
```

### 2.2. Ghi ra file CSV
```python
write_csv(file_path, fieldnames, data)
```

### 2.3. Lưu danh sách ID
Để phục vụ sinh khóa ngoại:
```python
save_ids("Order_Status", [d["StatusID"] for d in data])
```

---

## 3. Hàm main()
- Chạy toàn bộ các generator theo đúng thứ tự phụ thuộc và xuất ra toàn bộ CSV trong thư mục data/catalogs.
