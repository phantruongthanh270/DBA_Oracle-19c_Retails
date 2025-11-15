# 03. ETL Flow

## 1. Mục tiêu

Tài liệu mô tả quy trình ETL được sử dụng trong dự án Retail Database:

- Sinh dữ liệu bằng Python + Faker  
- Xuất ra file CSV  
- Tạo file SQL*Loader `.ctl`  
- Tạo script `.sh` / `.bat`  
- Chuyển toàn bộ file liên quan sang máy ảo Oracle  
- Chạy `run_all_loaders.sh` để nạp dữ liệu vào DB  
- Quản lý log, badfile, discardfile

---

## 2. Tổng quan quy trình ETL

Python (Faker)
↓
CSV Files (.csv)
↓
Control Files (.ctl)
↓
Shell/Bat Scripts
↓
Chuyển sang máy ảo (WinSCP)
↓
run_all_loaders.sh
↓
SQL*Loader
↓
Oracle Database (OLTP)

---

## 3. Môi trường thực hiện

### 3.1 Máy phát triển (Local)
- Python 3.x  
- Faker  
- Xuất CSV  
- Tạo `.ctl`, `.sh`, `.bat`
- WinSCP
- MobaXterm
- SQL Developer

### 3.2 Máy ảo chạy Oracle
- Oracle Linux 8
- Oracle Database  
- SQL*Loader  
- Bash shell (chạy `run_all_loaders.sh`)

---

## 4. Sinh dữ liệu bằng Python (Faker)

Ví dụ sinh dữ liệu bảng **Products**:
```python
import os
import random
import pandas as pd
from faker import Faker
from datetime import datetime, timedelta
from utils.csv_writer import write_csv
from utils.id_tracker import save_ids, load_ids

fake = Faker('vi_VN')

BASE_DIR = os.path.dirname(__file__)
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "entities")
INPUT_DIR = os.path.join(BASE_DIR, "data", "catalogs")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def next_ids(table_name, n):
    """Tạo danh sách ID mới, nối tiếp với ID cũ."""
    prev = load_ids(table_name)
    start = max(prev) + 1 if prev else 1
    ids = list(range(start, start + n))
    save_ids(table_name, ids)
    return ids

def ensure_catalogs_exist(tables):
    base_dir = os.path.dirname(__file__)
    catalogs_dir = os.path.join(base_dir, "data", "catalogs")

    for table in tables:
        path = os.path.join(catalogs_dir, f"{table}.csv")
        if not os.path.exists(path):
            raise Exception(f"⚠️ Thiếu dữ liệu danh mục: {table}. Hãy chạy generate_catalogs.py trước.")

def load_unit_map():
    file_path = os.path.join(INPUT_DIR, "Product_Units.csv")
    df = pd.read_csv(file_path)
    return {row["UnitName"]: row["UnitID"] for _, row in df.iterrows()}

def generate_products(n=15000):
    ensure_catalogs_exist(["Product_Categories", "Product_Units", "Product_Status"])
    category_ids = load_ids("Product_Categories")
    unit_ids = load_ids("Product_Units")
    status_ids = load_ids("Product_Status")

    # === Đọc tên danh mục và map ID -> Tên
    file_path = os.path.join(INPUT_DIR, "Product_Categories.csv")
    df = pd.read_csv(file_path)
    category_map = dict(zip(df["CategoryID"], df["CategoryName"]))

    # === Đọc UnitName -> UnitID map
    unit_map = load_unit_map()

    # === Từ khóa đặc trưng từng danh mục
    category_keywords = {
        "Đồ uống": ["Nước suối", "Trà xanh", "Cà phê", "Soda", "Sữa đậu nành", "Nước ngọt", "Trà sữa"],
        "Bánh kẹo": ["Bánh quy", "Snack", "Kẹo dẻo", "Socola", "Bánh xốp", "Bánh gạo"],
        "Thực phẩm tươi sống": ["Thịt heo", "Thịt bò", "Cá hồi", "Tôm", "Rau muống", "Cà rốt", "Chuối", "Cam"],
        "Thực phẩm khô": ["Gạo", "Mì gói", "Đậu xanh", "Đậu đỏ", "Ngũ cốc", "Bún khô", "Miến"],
        "Gia vị": ["Muối", "Đường", "Bột ngọt", "Nước mắm", "Nước tương", "Dầu ăn", "Tiêu", "Tương ớt"],
        "Đồ gia dụng": ["Nồi inox", "Dao bếp", "Chảo chống dính", "Chén sứ", "Ly thủy tinh", "Dĩa nhựa"],
        "Chăm sóc cá nhân": ["Dầu gội", "Sữa tắm", "Kem đánh răng", "Bàn chải", "Nước hoa", "Lăn khử mùi"],
        "Chăm sóc nhà cửa": ["Nước lau sàn", "Nước rửa chén", "Bột giặt", "Nước xịt phòng", "Túi rác"],
        "Thực phẩm đông lạnh": ["Xúc xích", "Chả giò", "Cá viên", "Tôm đông lạnh", "Gà viên", "Bánh bao"],
        "Sữa và sản phẩm từ sữa": ["Sữa tươi", "Sữa chua", "Phô mai", "Bơ", "Sữa đặc"]
    }

    # === Đơn vị phù hợp với từng danh mục
    category_units = {
        "Đồ uống": ["Chai", "Lít", "Hộp"],
        "Bánh kẹo": ["Gói", "Hộp", "Cái"],
        "Thực phẩm tươi sống": ["Kg", "Gram"],
        "Thực phẩm khô": ["Kg", "Gói"],
        "Gia vị": ["Chai", "Gói", "Gram"],
        "Đồ gia dụng": ["Cái", "Bộ"],
        "Chăm sóc cá nhân": ["Chai", "Hộp", "Tuýp"],
        "Chăm sóc nhà cửa": ["Chai", "Túi", "Hộp"],
        "Thực phẩm đông lạnh": ["Gói", "Hộp", "Kg"],
        "Sữa và sản phẩm từ sữa": ["Hộp", "Lít", "Chai"]
    }

    ids = next_ids("Products", n)
    data = []

    for pid in ids:
        cat_id = random.choice(category_ids)
        cat_name = category_map.get(cat_id, "Khác")

        # Tên sản phẩm theo danh mục
        keywords = category_keywords.get(cat_name, [fake.word().capitalize()])
        product_name = random.choice(keywords)

        # Đơn vị phù hợp
        possible_units = category_units.get(cat_name, ["Cái"])
        unit_name = random.choice(possible_units)
        unit_id = unit_map.get(unit_name, random.choice(unit_ids))

        # Thêm thương hiệu để đa dạng
        brand = fake.company().split()[0]
        full_name = f"{product_name} {brand}"

        data.append({
            "ProductID": pid,
            "ProductName": full_name,
            "CategoryID": cat_id,
            "UnitID": unit_id,
            "StatusID": random.choice(status_ids),
            "Description": fake.sentence(nb_words=10),
            "CreatedDate": fake.date_time_between(start_date="-2y", end_date="now").strftime("%Y-%m-%d %H:%M:%S")
        })

    write_csv(
        os.path.join(OUTPUT_DIR, "Products.csv"),
        fieldnames=list(data[0].keys()),
        data_rows=data
    )

    print(f"[OK] Products ({n} hàng)")

```

- Chạy file main_generate.py để sinh dữ liệu ngẫu nhiên.
- Code chưa được tối ưu nên việc sinh dữ liệu chỉ đủ để test Database, nhưng vẫn đủ dùng.

---

## 5. File Control SQL*Loader

products.ctl
```
load data 
characterset AL32UTF8
infile 'Products.csv' "str '\r\n'"
append
into table PRODUCTS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( PRODUCTID,
             PRODUCTNAME CHAR(255),
             CATEGORYID,
             UNITID,
             STATUSID,
             DESCRIPTION CHAR(4000),
             CREATEDDATE TIMESTAMP "YYYY-MM-DD HH24:MI:SS"
           )
```

- Câu lệnh chính: "load data" (bắt đầu khai báo job load dữ liệu).
- Thiết lập ký tự: "characterset AL32UTF8" (dữ liệu CSV được đọc theo encoding UTF-8 (AL32UTF8)).
- File nguồn: infile 'Products.csv' "str '\r\n'" (lấy dữ liệu từ file Products.csv và kết thúc mỗi dòng là CRLF (\r\n), phổ biến trên Windows).
- Hành vi load: "append" (thêm dữ liệu vào bảng PRODUCTS mà không xóa dữ liệu cũ).
- Định dạng trường: fields terminated by ',' OPTIONALLY ENCLOSED BY '"' AND '"'
- Mapping cột:
```
( PRODUCTID,
  PRODUCTNAME CHAR(255),
  CATEGORYID,
  UNITID,
  STATUSID,
  DESCRIPTION CHAR(4000),
  CREATEDDATE TIMESTAMP "YYYY-MM-DD HH24:MI:SS"
)
```

---

## 6. Chuyển file sang máy ảo

- Dùng tools WinSCP hỗ trợ kết nối đến máy ảo qua SSH.

## 7. Script thực thi ETL trên máy ảo

run_all_loaders.sh
```bash
#!/bin/bash
# ========================================
# Script: run_all_loaders.sh
# Mục đích: Tự động chạy tất cả file .ctl trong thư mục
# Tác giả: Tger
# ========================================

# Thông tin kết nối Oracle
USER="RETAIL_USER"
PASS="retail123"
CONN="localhost:1521/orclpdb"

# Tạo file log tổng hợp
MASTER_LOG="all_loader_results_$(date +%Y%m%d_%H%M%S).log"
echo "SQL*Loader batch started at $(date)" > "$MASTER_LOG"
echo "====================================" >> "$MASTER_LOG"

CTL_ORDER=(
  "Branch_Status.ctl"
  "Branch_Types.ctl"
  "Branches.ctl"
  "Branch_Managers.ctl"
  "Branch_Employees.ctl"
  "Employee_Status.ctl"
  "Employee_Types.ctl"
  "Employees.ctl"
  "Employee_Salaries.ctl"
  "Customer_Status.ctl"
  "Customer_Types.ctl"
  "Customers.ctl"
  "Customer_Addresses.ctl"
  "Product_Status.ctl"
  "Product_Categories.ctl"
  "Product_Units.ctl"
  "Products.ctl"
  "Product_Prices.ctl"
  "Order_Status.ctl"
  "Orders.ctl"
  "Order_Details.ctl"
  "Invoice_Status.ctl"
  "Invoices.ctl"
  "Order_Invoices.ctl"
  "Payment_Methods.ctl"
  "Payments.ctl"
  "Sale_Channels.ctl"
  "Sale_Staffs.ctl"
)

for ctl in "${CTL_ORDER[@]}"; do
    base=$(basename "$ctl" .ctl)
    echo "🔹 Loading $base ..." | tee -a "$MASTER_LOG"

    sqlldr userid=${USER}/${PASS}@${CONN} \
    control="$ctl" \
    log="${base}.log" \
    bad="${base}.bad" \
    direct=true

    if [ $? -eq 0 ]; then
        echo "✅ $base loaded successfully." | tee -a "$MASTER_LOG"
    else
        echo "Error loading $base. Check ${base}.log" | tee -a "$MASTER_LOG"
    fi

    echo "------------------------------------" >> "$MASTER_LOG"
done

echo "All loads finished at $(date)" >> "$MASTER_LOG"
echo "See $MASTER_LOG for summary."
```

---

## 8. Kiểm tra sau khi load

## 8.1. Kiểm tra số dòng
```SQL
SELECT COUNT(*) FROM Products;
```

## 8.2. Kiểm tra log
Tìm dòng:
- Rows successfully loaded
- Rows rejected

---

## 9. Best Practices

- Tên file phải khớp: products.csv ↔ products.ctl.
- Thứ tự nạp phải đúng theo thứ tự ràng buộc khóa ngoại.
- Dùng TO_TIMESTAMP() trong .ctl cho cột thời gian.
- Dùng Faker.seed() để dữ liệu tái tạo bất kỳ lúc nào.
- Dùng direct=true parallel=true để tăng tốc load.