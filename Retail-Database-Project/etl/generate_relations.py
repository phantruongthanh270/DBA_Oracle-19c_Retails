# generate_relations.py
import os
import random
import pandas as pd
from faker import Faker
from datetime import datetime, timedelta
from data_generator.utils.csv_writer import write_csv
from data_generator.utils.id_tracker import load_ids, save_ids

fake = Faker("vi_VN")

BASE_DIR = os.path.dirname(__file__)
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "relations")
INPUT_DIR = os.path.join(BASE_DIR, "data", "entities")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ============================================================
# 🔧 HÀM DÙNG CHUNG
# ============================================================

def next_ids(table_name, n):
    """Sinh ID nối tiếp với các ID cũ."""
    prev = load_ids(table_name)
    start = max(prev) + 1 if prev else 1
    ids = list(range(start, start + n))
    save_ids(table_name, ids)
    return ids

def ensure_entities_exist(required_tables):
    """Kiểm tra các bảng Entity cần thiết đã sinh chưa."""
    for table in required_tables:
        if not load_ids(table):
            raise Exception(f"⚠️ Thiếu dữ liệu entity: {table}. Hãy chạy generate_entities.py trước.")
        


# ============================================================
# 💰 LƯƠNG NHÂN VIÊN
# ============================================================

def generate_employee_salaries():
    ensure_entities_exist(["Employees"])
    employee_ids = load_ids("Employees")

    ids = next_ids("Employee_Salaries", len(employee_ids))
    data = []

    for sid, emp_id in zip(ids, employee_ids):
        base_salary = random.randint(6_000_000, 30_000_000)
        bonus = random.randint(500_000, 3_000_000)
        eff_date = fake.date_between(start_date="-2y", end_date="-6m")
        exp_date = fake.date_between(start_date=eff_date, end_date="today")

        data.append({
            "SalaryID": sid,
            "EmployeeID": emp_id,
            "BaseSalary": base_salary,
            "Bonus": bonus,
            "EffectiveDate": eff_date.strftime("%Y-%m-%d"),
            "ExpiryDate": exp_date.strftime("%Y-%m-%d"),
        })

    write_csv(
        os.path.join(OUTPUT_DIR, "Employee_Salaries.csv"),
        fieldnames=list(data[0].keys()),
        data_rows=data
    )
    print(f"[OK] Employee_Salaries ({len(data)} hàng)")



# ============================================================
# 🏠 ĐỊA CHỈ KHÁCH HÀNG
# ============================================================

def generate_customer_addresses():
    ensure_entities_exist(["Customers"])
    customer_ids = load_ids("Customers")

    provinces = [
        "An Giang", "Bà Rịa - Vũng Tàu", "Bắc Giang", "Bắc Kạn", "Bạc Liêu", 
        "Bắc Ninh", "Bến Tre", "Bình Định", "Bình Dương", "Bình Phước", 
        "Bình Thuận", "Cà Mau", "Cần Thơ", "Cao Bằng", "Đà Nẵng", 
        "Đắk Lắk", "Đắk Nông", "Điện Biên", "Đồng Nai", "Đồng Tháp", 
        "Gia Lai", "Hà Giang", "Hà Nam", "Hà Nội", "Hà Tĩnh", 
        "Hải Dương", "Hải Phòng", "Hậu Giang", "Hòa Bình", "Hưng Yên", 
        "Khánh Hòa", "Kiên Giang", "Kon Tum", "Lai Châu", "Lâm Đồng", 
        "Lạng Sơn", "Lào Cai", "Long An", "Nam Định", "Nghệ An", 
        "Ninh Bình", "Ninh Thuận", "Phú Thọ", "Phú Yên", "Quảng Bình", 
        "Quảng Nam", "Quảng Ngãi", "Quảng Ninh", "Quảng Trị", "Sóc Trăng", 
        "Sơn La", "Tây Ninh", "Thái Bình", "Thái Nguyên", "Thanh Hóa", 
        "Thừa Thiên Huế", "Tiền Giang", "TP. Hồ Chí Minh", "Trà Vinh", "Tuyên Quang", 
        "Vĩnh Long", "Vĩnh Phúc", "Yên Bái"
    ]

    data = []
    aid = 1
    for cid in customer_ids:
        for _ in range(random.randint(1, 3)):
            data.append({
                "AddressID": aid,
                "CustomerID": cid,
                "Street": fake.street_name(),
                "City": fake.city(),
                "District": fake.word().capitalize(),
                "Province": random.choice(provinces),
                "PostalCode": fake.postcode(),
            })
            aid += 1

    save_ids("Customer_Addresses", list(range(1, aid)))
    write_csv(os.path.join(OUTPUT_DIR, "Customer_Addresses.csv"), list(data[0].keys()), data)
    print(f"[OK] Customer_Addresses ({len(data)} hàng)")



# ============================================================
# 💵 GIÁ SẢN PHẨM
# ============================================================

def generate_product_prices():
    ensure_entities_exist(["Products"])
    product_ids = load_ids("Products")

    data = []
    pid = 1
    for prod_id in product_ids:
        for _ in range(random.randint(1, 3)):
            eff_date = fake.date_between(start_date="-2y", end_date="-3m")
            exp_date = fake.date_between(start_date=eff_date, end_date="today")
            price = round(random.uniform(20_000, 5_000_000), 2)
            data.append({
                "PriceID": pid,
                "ProductID": prod_id,
                "Price": price,
                "EffectiveDate": eff_date.strftime("%Y-%m-%d"),
                "ExpiryDate": exp_date.strftime("%Y-%m-%d"),
            })
            pid += 1

    save_ids("Product_Prices", list(range(1, pid)))
    write_csv(os.path.join(OUTPUT_DIR, "Product_Prices.csv"), list(data[0].keys()), data)
    print(f"[OK] Product_Prices ({len(data)} hàng)")



# ============================================================
# 👔 QUẢN LÝ CHI NHÁNH
# ============================================================

def generate_branch_managers():
    ensure_entities_exist(["Branches", "Employees"])
    branch_ids = load_ids("Branches")
    employee_ids = load_ids("Employees")

    data = []
    mid = 1
    for branch_id in branch_ids:
        emp_id = random.choice(employee_ids)
        start_date = fake.date_between(start_date="-2y", end_date="today")
        data.append({
            "BranchManagerID": mid,
            "BranchID": branch_id,
            "EmployeeID": emp_id,
            "StartDate": start_date.strftime("%Y-%m-%d"),
        })
        mid += 1

    save_ids("Branch_Managers", list(range(1, mid)))
    write_csv(os.path.join(OUTPUT_DIR, "Branch_Managers.csv"), list(data[0].keys()), data)
    print(f"[OK] Branch_Managers ({len(data)} hàng)")



# ============================================================
# 👷‍♂️ NHÂN VIÊN CHI NHÁNH
# ============================================================

def generate_branch_employees():
    ensure_entities_exist(["Branches", "Employees"])
    branch_ids = load_ids("Branches")
    employee_ids = load_ids("Employees")

    data = []
    eid = 1
    mapping = {}  # <== dùng để lưu mapping chi nhánh - nhân viên

    for branch_id in branch_ids:
        # Lấy ngẫu nhiên từ 5–20 nhân viên khác nhau cho chi nhánh này
        num_staff = random.randint(15, 20)
        selected_employees = random.sample(employee_ids, min(num_staff, len(employee_ids)))

        for emp_id in selected_employees:
            position = random.choice(["Thu ngân", "Tư vấn", "Bảo vệ", "Giao hàng", "Quản kho"])
            start_date = fake.date_between(start_date="-2y", end_date="today")

            data.append({
                "BranchEmployeeID": eid,
                "BranchID": branch_id,
                "EmployeeID": emp_id,
                "Position": position,
                "StartDate": start_date.strftime("%Y-%m-%d"),
            })

            mapping[eid] = {"BranchID": branch_id, "EmployeeID": emp_id}
            eid += 1

    # Lưu CSV
    write_csv(os.path.join(OUTPUT_DIR, "Branch_Employees.csv"), list(data[0].keys()), data)

    # Lưu ID + mapping
    save_ids("Branch_Employees", mapping)

    print(f"[OK] Branch_Employees ({len(data):,} hàng)")



# ============================================================
# 👥 KHÁCH HÀNG CHI NHÁNH
# ============================================================

def generate_branch_customers():
    ensure_entities_exist(["Branches", "Customers"])
    branch_ids = load_ids("Branches")
    customer_ids = load_ids("Customers")

    data = []
    cid = 1
    for branch_id in branch_ids:
        selected_customers = random.sample(customer_ids, min(len(customer_ids), random.randint(200, 1000)))
        for cust_id in selected_customers:
            first_visit = fake.date_between(start_date="-2y", end_date="today")
            data.append({
                "BranchCustomerID": cid,
                "BranchID": branch_id,
                "CustomerID": cust_id,
                "FirstVisitDate": first_visit.strftime("%Y-%m-%d"),
            })
            cid += 1

    save_ids("Branch_Customers", list(range(1, cid)))
    write_csv(os.path.join(OUTPUT_DIR, "Branch_Customers.csv"), list(data[0].keys()), data)
    print(f"[OK] Branch_Customers ({len(data)} hàng)")



# ============================================================
# 🚀 MAIN
# ============================================================

def main():
    print("=== Sinh dữ liệu quan hệ (Relations) ===")
    generate_employee_salaries()
    generate_customer_addresses()
    generate_product_prices()
    generate_branch_managers()
    generate_branch_employees()
    #generate_branch_customers()
    print("=== ✅ Hoàn tất: Relations đã được sinh ===")

if __name__ == "__main__":
    main()
