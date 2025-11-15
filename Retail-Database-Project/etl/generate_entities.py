# generate_entities.py
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

# ============================================================
# 🔧 HÀM DÙNG CHUNG
# ============================================================

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


# ============================================================
# 🧩 HÀM SINH DỮ LIỆU
# ============================================================

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



def generate_employees(n=3500):
    ensure_catalogs_exist(["Employee_Types", "Employee_Status"])
    type_ids = load_ids("Employee_Types")
    status_ids = load_ids("Employee_Status")

    ids = next_ids("Employees", n)
    data = []
    for eid in ids:
        data.append({
            "EmployeeID": eid,
            "FullName": fake.name(),
            "TypeID": random.choice(type_ids),
            "StatusID": random.choice(status_ids),
            "HireDate": fake.date_between(start_date="-3y", end_date="today").strftime("%Y-%m-%d"),
            "Email": fake.email(),
            "Phone": fake.phone_number()
        })

    write_csv(os.path.join(OUTPUT_DIR, "Employees.csv"), list(data[0].keys()), data)

    print(f"[OK] Employees ({n} hàng)")

    

def generate_customers(n=300000):
    ensure_catalogs_exist(["Customer_Types", "Customer_Status"])
    type_ids = load_ids("Customer_Types")
    status_ids = load_ids("Customer_Status")

    ids = next_ids("Customers", n)
    data = []
    for cid in ids:
        data.append({
            "CustomerID": cid,
            "FullName": fake.name(),
            "TypeID": random.choice(type_ids),
            "StatusID": random.choice(status_ids),
            "Email": fake.email(),
            "Phone": fake.phone_number(),
            "RegistrationDate": fake.date_between(start_date="-2y", end_date="today").strftime("%Y-%m-%d")
        })

    write_csv(os.path.join(OUTPUT_DIR, "Customers.csv"), list(data[0].keys()), data)

    print(f"[OK] Customers ({n} hàng)")



def generate_branches(n=120):
    ensure_catalogs_exist(["Branch_Types", "Branch_Status"])
    type_ids = load_ids("Branch_Types")
    status_ids = load_ids("Branch_Status")

    ids = next_ids("Branches", n)
    data = []
    for bid in ids:
        city = getattr(fake, "city_name", fake.city)()
        data.append({
            "BranchID": bid,
            "BranchName": f"Chi nhánh {city}",
            "TypeID": random.choice(type_ids),
            "StatusID": random.choice(status_ids),
            "Address": fake.address().replace("\n", ", "),
            "Phone": fake.phone_number(),
            "Email": fake.email(),
            "CreatedDate": fake.date_between(start_date="-3y", end_date="today").strftime("%Y-%m-%d")
        })

    write_csv(os.path.join(OUTPUT_DIR, "Branches.csv"), list(data[0].keys()), data)

    print(f"[OK] Branches ({n} hàng)")



# ============================================================
# 🚀 MAIN
# ============================================================

def main():
    print("=== Sinh dữ liệu Entities ===")
    generate_products(n=15000)
    generate_employees(n=3500)
    generate_customers(n=300000)
    generate_branches(n=120)
    print("=== Hoàn tất: Entities đã được sinh ===")

if __name__ == "__main__":
    main()
