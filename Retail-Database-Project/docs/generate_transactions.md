# Explanation 

File này sinh toàn bộ dữ liệu giao dịch của hệ thống theo pipeline:

## 1. Kiểm tra dữ liệu nền

ensure_entities_exist() đảm bảo các bảng cha như Customers, Products, Employees… đã có ID trước khi sinh bảng con (FK hợp lệ).

---

## 2. Sinh Orders (đa luồng)

- Chia OrderID thành nhiều chunk theo số core (chunkify + ProcessPoolExecutor).
- Mỗi chunk sinh danh sách đơn hàng gồm:
    + CustomerID, BranchID (FK)
    + OrderDate
    + StatusID
    + TotalAmount = 0 (tính sau)
- Lưu:
    + danh sách ID (save_ids)
    + metadata (OrderID → BranchID)
    + xuất CSV

---

## 3. Sinh Order_Details

- Lấy danh sách OrderID & ProductID.
- Với mỗi Order:
    + sinh 3–5 sản phẩm
    + mỗi dòng gồm ProductID, Quantity, UnitPrice
- Sau khi ghép all chunk → gán OrderDetailID tuần tự.
- Ghi CSV + lưu ID.

---

## 4. Sinh Invoices

- Mỗi Order tạo đúng 1 Invoice.
- Mỗi hóa đơn gồm:
    + InvoiceDate
    + StatusID
    + EmployeeID
    + TotalAmount = 0 (tính sau)
- Ghi CSV + lưu ID.

---

## 5. Sinh Payments

- Mỗi Invoice có 1 hoặc 2 lần thanh toán.
- Sinh PaymentDate, MethodID, AmountPaid = 0.
- Sau khi gom dữ liệu → gán PaymentID.
- Ghi CSV + lưu ID.

---

## 6. Sinh bảng Order_Invoices (mapping 1-1)

- Ghép OrderID với InvoiceID tương ứng.
- Ghi CSV + lưu ID.

---

## 7. Sinh Sales_Staffs

- Dựa vào Orders + Branch_Employees + Sale_Channels.
- Mỗi Order được gán:
    + EmployeeID thuộc cùng chi nhánh
    + ChannelID
    + ShippedDate, DeliveryDate
    + Status
- Ghi CSV + lưu ID.

---

## 8. Cập nhật số tiền (sau khi sinh hết dữ liệu thô)

### 8.1. update_order_totals()
- Đọc Orders + Order_Details.
- Tính tiền từng Order = SUM(Quantity * UnitPrice).
- Ghi ngược vào Orders.csv.

### 8.2. update_invoice_totals()
- Tổng tiền Invoice = SUM(TotalAmount của các Order thuộc invoice).
- Ghi ngược vào Invoices.csv.

### 8.3. update_payment_totals()
- AmountPaid = TotalAmount của Invoice (thanh toán đủ).
- Ghi ngược vào Payments.csv.

---

## 9. Hàm main

Chạy tuần tự theo đúng thứ tự phụ thuộc FK: 