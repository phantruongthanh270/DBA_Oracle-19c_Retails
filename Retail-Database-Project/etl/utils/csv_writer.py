import csv
import os

def write_csv(file_path, fieldnames, data_rows):
    """Ghi dữ liệu ra file CSV."""
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, mode='w', newline="", encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        writer.writerows(data_rows)
    print(f"[OK] Đã ghi {len(data_rows)} dòng vào {file_path}")



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
