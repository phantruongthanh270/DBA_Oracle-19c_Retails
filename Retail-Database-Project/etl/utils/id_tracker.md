# Explanation

File dùng để lưu, cập nhật và truy vấn danh sách ID của từng bảng khi sinh dữ liệu.
Mục tiêu: đảm bảo khóa ngoại (FK) luôn lấy từ các ID đã tồn tại → tránh lỗi khi load dữ liệu vào Oracle.

## 1. load_all_ids()

Đọc toàn bộ file id_tracker.json.
- Nếu file chưa tồn tại → trả {}
- Nếu file lỗi hoặc rỗng → cảnh báo và trả về {}
- Đảm bảo luôn trả về dictionary hợp lệ

Dùng để lấy trạng thái ID hiện tại của hệ thống.
 
---

## 2. save_ids(table_name, ids)

Ghi đè toàn bộ danh sách ID của một bảng.
- Đọc JSON hiện tại
- Ghi lại ids cho bảng tương ứng
- Xuất file mới

Dùng cho lần sinh dữ liệu đầu tiên hoặc khi tái tạo bảng.

---

## 3. append_ids(table_name, new_ids)

Thêm ID mới vào danh sách cũ (không trùng).
- Load danh sách hiện có
- Convert sang set để loại trùng
- Gộp thêm new_ids
- Ghi lại vào file

Dùng khi chạy nhiều batch → đảm bảo không trùng khóa.

---

## 4. load_ids(table_name)

Trả về danh sách ID của một bảng.
- Nếu không có → trả list rỗng

Dùng để truy vấn FK.

---

## 5. get_random_id(table_name)

Trả 1 ID ngẫu nhiên từ một bảng.
- Nếu bảng chưa có ID → báo lỗi
- Random trong danh sách ID đã lưu

Hàm quan trọng nhất dùng để sinh khóa ngoại hợp lệ
(ví dụ Orders cần CustomerID đã có).