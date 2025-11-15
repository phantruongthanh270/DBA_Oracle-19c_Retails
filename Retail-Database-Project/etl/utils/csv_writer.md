# Explanation

File csv.writer.py cung cấp 2 hàm tiện ích dùng chung cho toàn bộ hệ thống sinh dữ liệu:

## 1. write_csv()

Ghi danh sách dict vào file CSV theo đúng cấu trúc, có header, đảm bảo thư mục tồn tại.
```python
def write_csv(file_path, fieldnames, data_rows):
    """Ghi dữ liệu ra file CSV."""
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, mode='w', newline="", encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        writer.writerows(data_rows)
    print(f"[OK] Đã ghi {len(data_rows)} dòng vào {file_path}")

```

| Thành phần | Ý nghĩa |
|------------|---------|
| os.makedirs(..., exist_ok=True) | Tự động tạo thư mục nếu chưa có (tránh lỗi khi ghi file vào thư mục mới). |
| open(..., newline="", encoding='utf-8') | Mở file theo chuẩn UTF-8, tránh lỗi xuống dòng bị nhân đôi trên Windows. |
| csv.DictWriter | Ghi CSV theo dạng dictionary → đảm bảo đúng cột. |
| quoting=csv.QUOTE_ALL | Tất cả giá trị đều nằm trong dấu " " để tránh lỗi ký tự đặc biệt (, ; newline). | 
| writer.writeheader() | Ghi tên cột. |
| writer.writerows(data_rows) | Ghi toàn bộ dữ liệu. |

---

## 2. validate_csv()

Kiểm tra dữ liệu CSV sau khi sinh, phát hiện lỗi như:
- Header sai thứ tự
- Thiếu cột hoặc thừa cột
- File rỗng
- Giá trị trống (nếu bật kiểm tra)

Hai hàm này giúp quy chuẩn hoá việc xuất dữ liệu và đảm bảo chất lượng trước khi load vào Oracle.
```python
def validate_csv(file_path, expected_fieldnames, check_empty=False):
    """Kiểm tra tính hợp lệ của file CSV."""
    if not os.path.exists(file_path):
        print(f"[ERROR] File không tồn tại: {file_path}")
        return False

    with open(file_path, mode='r', encoding='utf-8') as file:
        reader = csv.reader(file)
        try:
            header = next(reader)
        except StopIteration:
            print(f"[ERROR] File {file_path} rỗng.")
            return False

        if header != expected_fieldnames:
            print(f"[ERROR] Header không khớp trong {file_path}")
            print(f"  Mong đợi : {expected_fieldnames}")
            print(f"  Thực tế  : {header}")
            return False

        for i, row in enumerate(reader, start=2):
            if len(row) != len(expected_fieldnames):
                print(f"[ERROR] Dòng {i} có {len(row)} cột (mong đợi {len(expected_fieldnames)})")
                return False

            if check_empty and any(cell.strip() == '' for cell in row):
                print(f"[WARN] Dòng {i} chứa giá trị trống: {row}")

    print(f"[VALID] File {file_path} hợp lệ ({len(expected_fieldnames)} cột).")
    return True

```

| Kiểm tra | Ý nghĩa |
|----------|---------|
| os.path.exists() | Tránh lỗi khi file không tồn tại. |
| header != expected_fieldnames | Phát hiện thiếu cột, thừa cột, sai thứ tự. |
| len(row) != len(expected_fieldnames) | Bắt lỗi cực quan trọng — tránh lỗi khi load vào Oracle SQL*Loader. |
| check_empty=True | Thông báo nếu có giá trị bị empty, giúp bạn debug dữ liệu. |s