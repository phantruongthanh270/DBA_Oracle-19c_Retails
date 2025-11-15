# generate_transactions.py
import os
import random
import pandas as pd
from faker import Faker
from datetime import datetime, timedelta
from concurrent.futures import ProcessPoolExecutor, as_completed

from utils.csv_writer import write_csv
from utils.id_tracker import load_ids, save_ids
from utils.entity_tracker import save_entities , load_entities

fake = Faker("vi_VN")

BASE_DIR = os.path.dirname(__file__)
OUTPUT_DIR = os.path.join(BASE_DIR, "data", "transactions")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# === CẤU HÌNH ===
NUM_ORDERS = 10000000   # triệu đơn hàng
AVG_ITEMS_PER_ORDER = 2   # 3–5 sản phẩm / đơn
BATCH_SIZE = 100000      # batch ghi từng phần (giúp tiết kiệm RAM)
MAX_WORKERS = 16        # số core chạy song song


# ============================================================
# 🔧 HÀM DÙNG CHUNG
# ============================================================

def ensure_entities_exist(required_tables):
    for table in required_tables:
        if not load_ids(table):
            raise Exception(f"⚠️ Thiếu dữ liệu entity: {table}. Hãy chạy generate_entities.py trước.")


def chunkify(lst, n):
    """Chia danh sách thành n phần gần bằng nhau."""
    k, m = divmod(len(lst), n)
    return [lst[i * k + min(i, m):(i + 1) * k + min(i + 1, m)] for i in range(n)]


# ============================================================
# 🛒 ORDERS
# ============================================================

def generate_orders_chunk(chunk_ids, customer_ids, branch_ids, order_statuses):
    data = []
    for oid in chunk_ids:
        order_date = fake.date_time_between(start_date="-1y", end_date="now")
        status = random.choices(order_statuses, weights=[0.2, 0.5, 0.2, 0.1])[0]
        cust_id = random.choice(customer_ids)
        branch_id = random.choice(branch_ids)
        data.append({
            "OrderID": oid,
            "CustomerID": cust_id,
            "BranchID": branch_id,
            "OrderDate": order_date.strftime("%Y-%m-%d %H:%M:%S"),
            "StatusID": status,
            "TotalAmount": 0.0,
        })
    return data


def generate_orders():
    ensure_entities_exist(["Customers", "Branches", "Order_Status"])

    customer_ids = load_ids("Customers")
    branch_ids = load_ids("Branches")
    order_statuses = load_ids("Order_Status")

    all_order_ids = list(range(1, NUM_ORDERS + 1))
    chunks = chunkify(all_order_ids, MAX_WORKERS)

    results = []
    with ProcessPoolExecutor(max_workers=MAX_WORKERS) as ex:
        futures = [ex.submit(generate_orders_chunk, c, customer_ids, branch_ids, order_statuses) for c in chunks]
        for f in as_completed(futures):
            results.extend(f.result())

    # Lưu ID như cũ
    save_ids("Orders", all_order_ids)

    # 🔥 Lưu metadata dạng {OrderID: {"OrderID": ..., "BranchID": ...}}
    order_entities = {
        str(r["OrderID"]): {
            "OrderID": r["OrderID"],
            "BranchID": r["BranchID"]
        }
        for r in results
    }
    save_entities("Orders", order_entities)

    # Xuất CSV
    write_csv(os.path.join(OUTPUT_DIR, "Orders.csv"), list(results[0].keys()), results)
    print(f"[OK] Orders ({len(results):,} hàng)")



# ============================================================
# 📦 ORDER DETAILS
# ============================================================

def generate_order_details_chunk(chunk_orders, product_ids):
    data = []
    for order_id in chunk_orders:
        num_items = random.randint(3, 5)
        selected_products = random.sample(product_ids, num_items)
        for pid in selected_products:
            qty = random.randint(1, 5)
            price = round(random.uniform(10_000, 2_000_000), 2)
            data.append({
                # KHÔNG thêm OrderDetailID ở đây
                "OrderID": order_id,
                "ProductID": pid,
                "Quantity": qty,
                "UnitPrice": price,
            })
    return data


def generate_order_details():
    ensure_entities_exist(["Orders", "Products"])
    order_ids = list(load_ids("Orders").keys())
    product_ids = load_ids("Products")

    chunks = chunkify(order_ids, MAX_WORKERS)
    results = []
    with ProcessPoolExecutor(max_workers=MAX_WORKERS) as ex:
        futures = [ex.submit(generate_order_details_chunk, c, product_ids) for c in chunks]
        for f in as_completed(futures):
            results.extend(f.result())

    # Gán ID duy nhất sau khi gom toàn bộ kết quả
    for i, r in enumerate(results, start=1):
        r["OrderDetailID"] = i

    save_ids("Order_Details", list(range(1, len(results) + 1)))
    write_csv(os.path.join(OUTPUT_DIR, "Order_Details.csv"), list(results[0].keys()), results)
    print(f"[OK] Order_Details ({len(results):,} hàng)")


# ============================================================
# 🧾 INVOICES
# ============================================================

def generate_invoices_chunk(chunk_invoice_ids, status_ids, employee_ids):
    data = []
    for invoice_id in chunk_invoice_ids:
        invoice_date = fake.date_time_between(start_date="-1y", end_date="now")
        data.append({
            "InvoiceID": invoice_id,
            "InvoiceDate": invoice_date.strftime("%Y-%m-%d %H:%M:%S"),
            "StatusID": random.choice(status_ids),
            "EmployeeID": random.choice(employee_ids),
            "TotalAmount": 0.0,
        })
    return data


def generate_invoices():
    ensure_entities_exist(["Invoice_Status", "Employees"])

    # ✅ giả định mỗi Order tương ứng 1 hóa đơn
    order_ids = list(load_ids("Orders").keys())
    status_ids = load_ids("Invoice_Status")
    employee_ids = load_ids("Employees")

    chunks = chunkify(order_ids, MAX_WORKERS)
    results = []

    with ProcessPoolExecutor(max_workers=MAX_WORKERS) as ex:
        futures = [ex.submit(generate_invoices_chunk, c, status_ids, employee_ids) for c in chunks]
        for f in as_completed(futures):
            results.extend(f.result())

    # Lưu ID và ghi file CSV
    save_ids("Invoices", [r["InvoiceID"] for r in results])
    write_csv(os.path.join(OUTPUT_DIR, "Invoices.csv"), list(results[0].keys()), results)

    print(f"[OK] Invoices ({len(results):,} hàng)")



# ============================================================
# 💳 PAYMENTS
# ============================================================

def generate_payments_chunk(chunk_invoices, payment_method_ids):
    data = []
    for iid in chunk_invoices:
        num_payments = random.choice([1, 1, 2])  # đa số hóa đơn chỉ có 1 lần thanh toán
        for _ in range(num_payments):
            pay_date = fake.date_time_between(start_date="-1y", end_date="now")
            data.append({
                "InvoiceID": iid,
                "PaymentDate": pay_date.strftime("%Y-%m-%d %H:%M:%S"),
                "MethodID": random.choice(payment_method_ids),
                "AmountPaid": 0.0 # sẽ cập nhật sau,
            })
    return data


def generate_payments():
    ensure_entities_exist(["Invoices", "Payment_Methods"])
    invoice_ids = load_ids("Invoices")
    payment_method_ids = load_ids("Payment_Methods")

    chunks = chunkify(invoice_ids, MAX_WORKERS)
    results = []
    with ProcessPoolExecutor(max_workers=MAX_WORKERS) as ex:
        futures = [ex.submit(generate_payments_chunk, c, payment_method_ids) for c in chunks]
        for f in as_completed(futures):
            results.extend(f.result())

    # ✅ Gán ID tuần tự sau khi merge
    for i, r in enumerate(results, start=1):
        r["PaymentID"] = i

    save_ids("Payments", list(range(1, len(results) + 1)))
    write_csv(os.path.join(OUTPUT_DIR, "Payments.csv"), list(results[0].keys()), results)
    print(f"[OK] Payments ({len(results):,} hàng)")



# ============================================================
# 🔗 ORDER-INVOICES
# ============================================================

def generate_order_invoices():
    ensure_entities_exist(["Orders", "Invoices"])
    order_ids = list(load_ids("Orders").keys())
    invoice_ids = load_ids("Invoices")

    data = [{"OrderInvoiceID": oid, "OrderID": oid, "InvoiceID": iid}
            for oid, iid in zip(order_ids, invoice_ids)]

    save_ids("Order_Invoices", order_ids)
    write_csv(os.path.join(OUTPUT_DIR, "Order_Invoices.csv"), list(data[0].keys()), data)
    print(f"[OK] Order_Invoices ({len(data):,} hàng)")


# ============================================================
# 🧍 SALES STAFFS
# ============================================================

def generate_sale_staffs():
    ensure_entities_exist(["Orders", "Branch_Employees", "Sale_Channels"])

    # === 🔹 Đọc dữ liệu ===
    orders = load_ids("Orders")
    branch_employees = load_ids("Branch_Employees")
    channel_ids = load_ids("Sale_Channels")

    if not orders or not branch_employees:
        print("[WARN] Không có Orders hoặc Branch_Employees để sinh Sales_Staffs.")
        return

    # === 🔹 Tạo mapping BranchID → [ {BranchEmployeeID, EmployeeID}, ... ] ===
    branch_to_employees = {}
    for beid, info in branch_employees.items():
        branch_id = info.get("BranchID")
        emp_id = info.get("EmployeeID")
        if branch_id and emp_id:
            branch_to_employees.setdefault(branch_id, []).append({
                "BranchEmployeeID": beid,
                "EmployeeID": emp_id
            })

    data = []
    sid = 1

    # === 🔹 Chuẩn hóa Orders: lấy OrderID và BranchID ===
    order_items = []

    # Trường hợp orders là dict {OrderID: {..., BranchID: x}}
    if isinstance(orders, dict):
        for oid, info in orders.items():
            branch_id = info.get("BranchID")
            if branch_id:  # chỉ lấy khi có chi nhánh
                order_items.append((oid, branch_id))
    else:
        print("[WARN] Orders không chứa thông tin BranchID hợp lệ, bỏ qua.")
        return

    # === 🔹 Sinh dữ liệu Sales_Staffs ===
    for oid, branch_id in order_items:
        # Chỉ lấy nhân viên thuộc chi nhánh đó
        if branch_id not in branch_to_employees:
            continue

        emp_info = random.choice(branch_to_employees[branch_id])

        shipped_date = fake.date_time_between(start_date="-1y", end_date="now")
        delivery_date = shipped_date + timedelta(days=random.randint(1, 7))

        data.append({
            "SaleStaffID": sid,
            "OrderID": oid,
            "EmployeeID": emp_info["EmployeeID"],
            "ChannelID": random.choice(channel_ids),
            "ShippedDate": shipped_date.strftime("%Y-%m-%d %H:%M:%S"),
            "DeliveryDate": delivery_date.strftime("%Y-%m-%d %H:%M:%S"),
            "Status": random.choice(["Pending", "Shipped", "Delivered", "Cancelled"])
        })
        sid += 1

    # === 🔹 Ghi dữ liệu ===
    if data:
        save_ids("Sale_Staffs", list(range(1, sid)))
        write_csv(
            os.path.join(OUTPUT_DIR, "Sale_Staffs.csv"),
            list(data[0].keys()),
            data
        )
        print(f"[OK] Sale_Staffs ({len(data):,} hàng) — dữ liệu hợp lệ với Orders & Branch_Employees.")
    else:
        print("[WARN] Không thể sinh Sale_Staffs — không tìm thấy chi nhánh hợp lệ hoặc nhân viên.")


# ============================================================
# 🚀 Update TotalAmount in Order
# ============================================================

def update_order_totals():
    import os
    import pandas as pd

    base_path = r"D:\DBA\ERD_THS\data_generator\data\transactions"
    orders_file = os.path.join(base_path, "Orders.csv")
    details_file = os.path.join(base_path, "Order_Details.csv")

    if not os.path.exists(orders_file) or not os.path.exists(details_file):
        print("⚠️ Orders.csv hoặc Order_Details.csv không tồn tại, bỏ qua cập nhật TotalAmount.")
        return

    print("🔄 Đang tính lại TotalAmount trong Orders.csv...")

    # Đọc dữ liệu
    orders = pd.read_csv(orders_file)
    details = pd.read_csv(details_file)

    # Tính tổng tiền từng đơn hàng
    totals = (
        details.groupby("OrderID")
        .apply(lambda x: (x["Quantity"] * x["UnitPrice"]).sum())
        .reset_index(name="TotalAmount")
    )

    # Gộp tổng tiền vào Orders, GHI ĐÈ cột TotalAmount
    orders = orders.drop(columns=["TotalAmount"], errors="ignore")
    orders = orders.merge(totals, on="OrderID", how="left")
    orders["TotalAmount"] = orders["TotalAmount"].fillna(0.0)

    # 👉 Làm tròn 2 chữ số sau dấu thập phân
    orders["TotalAmount"] = orders["TotalAmount"].round(2)

    # Ghi lại file, đảm bảo chỉ 2 chữ số thập phân
    orders.to_csv(orders_file, index=False, float_format="%.2f")
    print("✅ Đã cập nhật TotalAmount trong Orders.csv.")


# ============================================================
# 🚀 Update TotalAmount in Invoices
# ============================================================

def update_invoice_totals():
    import os
    import pandas as pd

    base_path = r"D:\DBA\ERD_THS\data_generator\data\transactions"
    invoices_file = os.path.join(base_path, "Invoices.csv")
    orders_file = os.path.join(base_path, "Orders.csv")
    order_invoices_file = os.path.join(base_path, "Order_Invoices.csv")

    # Kiểm tra file
    for f in [invoices_file, orders_file, order_invoices_file]:
        if not os.path.exists(f):
            print(f"⚠️ Thiếu file: {f}")
            return

    print("🔄 Đang tính lại TotalAmount trong Invoices.csv...")

    # Đọc dữ liệu
    invoices = pd.read_csv(invoices_file)
    orders = pd.read_csv(orders_file)
    order_invoices = pd.read_csv(order_invoices_file)

    # Gộp để tính tổng
    merged = order_invoices.merge(
        orders[['OrderID', 'TotalAmount']], on='OrderID', how='left'
    )

    invoice_totals = (
        merged.groupby('InvoiceID')['TotalAmount']
        .sum()
        .reset_index()
        .rename(columns={'TotalAmount': 'InvoiceTotal'})
    )

    # Gộp tổng trở lại Invoices.csv
    invoices = invoices.merge(invoice_totals, on='InvoiceID', how='left')
    invoices['TotalAmount'] = invoices['InvoiceTotal'].fillna(0.0)
    invoices.drop(columns=['InvoiceTotal'], inplace=True)

    # 👉 Làm tròn 2 chữ số sau dấu thập phân
    invoices['TotalAmount'] = invoices['TotalAmount'].round(2)

    # Ghi lại file
    invoices.to_csv(invoices_file, index=False, float_format="%.2f")
    print(f"✅ Đã cập nhật TotalAmount cho Invoices.csv ({len(invoices)} hóa đơn).")


# ============================================================
# 🚀 Update AmountPaid in Payments
# ============================================================

def update_payment_totals():
    base_path = r"D:\DBA\ERD_THS\data_generator\data\transactions"
    payments_file = os.path.join(base_path, "Payments.csv")
    invoices_file = os.path.join(base_path, "Invoices.csv")

    # Kiểm tra file tồn tại
    for f in [payments_file, invoices_file]:
        if not os.path.exists(f):
            print(f"⚠️ Thiếu file: {f}")
            return

    print("🔄 Đang tính lại AmountPaid trong Payments.csv...")

    # Đọc dữ liệu
    payments = pd.read_csv(payments_file)
    invoices = pd.read_csv(invoices_file)

    # Gộp để lấy TotalAmount tương ứng InvoiceID
    payments = payments.drop(columns=['AmountPaid'], errors='ignore')
    payments = payments.merge(
        invoices[['InvoiceID', 'TotalAmount']], on='InvoiceID', how='left'
    )

    # Đổi tên cột cho đúng
    payments.rename(columns={'TotalAmount': 'AmountPaid'}, inplace=True)

    # Nếu có hóa đơn chưa tồn tại thì gán 0
    payments['AmountPaid'] = payments['AmountPaid'].fillna(0.0)

    # Làm tròn 2 chữ số sau dấu thập phân
    payments['AmountPaid'] = payments['AmountPaid'].round(2)

    # Ghi lại file
    payments.to_csv(payments_file, index=False, float_format="%.2f")

    print(f"✅ Đã cập nhật AmountPaid cho Payments.csv ({len(payments)} dòng).")


# ============================================================
# 🚀 MAIN
# ============================================================

def main():
    print("=== 🚀 Sinh dữ liệu giao dịch (Transactions) ===")
    generate_orders()
    generate_order_details()
    generate_invoices()
    generate_payments()
    generate_order_invoices()
    generate_sale_staffs()
    update_order_totals()
    update_invoice_totals()
    update_payment_totals()
    print("=== ✅ Hoàn tất Transactions ===")


if __name__ == "__main__":
    main()
