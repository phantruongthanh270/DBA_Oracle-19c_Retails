# Explanation

File này chứa các hàm tiện ích giúp sinh dữ liệu giả lập (fake data) theo cách thống nhất, ổn định, có quy luật, dùng khi tạo CSV cho Retail Database.

## 1. random_date(start_year=2015, end_year=2025, as_date=True)

- Sinh một ngày ngẫu nhiên trong khoảng từ start_year đến end_year.
- Tính số ngày giữa hai mốc → chọn ngẫu nhiên một ngày → trả về date hoặc datetime.
- Dùng để tạo OrderDate, InvoiceDate, PaymentDate,…
Ý nghĩa: đảm bảo dữ liệu có thời gian hợp lý, không bị lệch năm.

---

## 2. random_phone()

- Trả về số điện thoại hợp lệ của VN.
- Format: +84xxxxxxxxx (9 chữ số cuối).
- Dùng cho bảng Customers, Employees,…

---

## 3. normalize_text(text)

- Chuẩn hóa chuỗi ký tự:
   + Loại bỏ dấu tiếng Việt bằng unicodedata.normalize
   + Loại bỏ ký tự đặc biệt bằng regex
- Giữ lại chữ cái A–Z và số 0–9.
- Dùng để tạo email hoặc mã code sạch.

---

## 4. random_email(name=None)

- Tạo email hợp lệ dựa trên tên.
- Nếu không truyền name → tự sinh bằng faker.
- Normalize tên → chuyển lowercase → gắn domain @example.com.
- Giúp dữ liệu email nhất quán, không chứa ký tự lạ.

---

## 5. random_price(min_price=10, max_price=500)

- Sinh giá ngẫu nhiên trong khoảng.
- Kết quả được làm tròn 2 chữ số thập phân.
- Dùng cho Product Prices hoặc Payment Amount.

---

## 6. random_status_name(options=None)

- Trả về một trạng thái ngẫu nhiên.
- Nếu không cung cấp danh sách → dùng default:
    + Active, Inactive, Suspended, Pending
- Hỗ trợ sinh Status cho Orders, Payments,…

---

## 7.random_description()

- Sinh mô tả ngẫu nhiên bằng thư viện faker.
- Một câu khoảng 10 từ.
- Dùng cho Products, branches,…