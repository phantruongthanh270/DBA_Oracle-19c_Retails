import sys, os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))


import os
import time

from data_generator import generate_catalogs
from data_generator import generate_entities
from data_generator import generate_relations
from data_generator import generate_transactions

from data_generator.utils.csv_writer import write_csv
from data_generator.utils.id_tracker import save_ids

# === 1. Sinh dữ liệu phụ trợ ===
def generate_static_tables():
    print("=== [1A] Sinh dữ liệu bảng phụ trợ (Order/Invoice Status, Payment, Channels) ===")

    BASE_DIR = os.path.dirname(__file__)
    OUTPUT_DIR = os.path.join(BASE_DIR, "data", "extras")
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    static_configs = {
        "Order_Status": [
            ("Pending", "Đơn hàng đang chờ xử lý"),
            ("Processing", "Đơn hàng đang được xử lý"),
            ("Shipped", "Đơn hàng đã gửi đi"),
            ("Delivered", "Đơn hàng đã giao thành công"),
            ("Cancelled", "Đơn hàng bị hủy")
        ],
        "Invoice_Status": [
            ("Unpaid", "Hóa đơn chưa thanh toán"),
            ("Partially Paid", "Thanh toán một phần"),
            ("Paid", "Đã thanh toán"),
            ("Refunded", "Đã hoàn tiền"),
            ("Cancelled", "Hóa đơn bị hủy")
        ],
        "Payment_Methods": [
            ("Tiền mặt", "Thanh toán trực tiếp bằng tiền mặt"),
            ("Thẻ tín dụng", "Thanh toán bằng Visa/Mastercard"),
            ("Chuyển khoản ngân hàng", "Thanh toán qua tài khoản ngân hàng"),
            ("Ví điện tử", "Sử dụng Momo, ZaloPay, ShopeePay..."),
            ("Trả góp", "Thanh toán theo hình thức trả góp")
        ],
        "Sale_Channels": [
            ("Cửa hàng trực tiếp", "Khách đến mua tại chi nhánh"),
            ("Website", "Khách đặt hàng qua website"),
            ("Ứng dụng di động", "Khách đặt hàng qua app"),
            ("Điện thoại", "Đặt hàng qua tổng đài"),
            ("Đối tác phân phối", "Đại lý hoặc cộng tác viên")
        ],
    }

    for name, items in static_configs.items():
        key = name.replace(" ", "_")
        file_path = os.path.join(OUTPUT_DIR, f"{key}.csv")

        if "Status" in key:
            data = [{"StatusID": i + 1, "StatusName": n, "Description": d} for i, (n, d) in enumerate(items)]
            save_ids(key, [d["StatusID"] for d in data])
            headers = ["StatusID", "StatusName", "Description"]

        elif "Payment" in key:
            data = [{"MethodID": i + 1, "MethodName": n, "Description": d} for i, (n, d) in enumerate(items)]
            save_ids(key, [d["MethodID"] for d in data])
            headers = ["MethodID", "MethodName", "Description"]

        elif "Channel" in key:
            data = [{"ChannelID": i + 1, "ChannelName": n, "Description": d} for i, (n, d) in enumerate(items)]
            save_ids(key, [d["ChannelID"] for d in data])
            headers = ["ChannelID", "ChannelName", "Description"]

        else:
            continue

        write_csv(file_path, headers, data)

    print("=== ✅ Đã sinh dữ liệu bảng phụ trợ ===\n")


# === 2. MAIN PIPELINE ===
def main():
    start_time = time.time()
    print("\n==============================")
    print("🚀 BẮT ĐẦU SINH DỮ LIỆU GIẢ")
    print("==============================\n")

    steps = [
        ("[1A] Bảng phụ trợ", generate_static_tables),
        ("[1B] Catalogs", generate_catalogs.main),
        ("[2] Entities", generate_entities.main),
        ("[3] Quan hệ (Relations)", generate_relations.main),
        ("[4] Giao dịch (Transactions)", generate_transactions.main),
    ]

    for label, func in steps:
        print(f"=== {label} ===")
        func()

    elapsed = time.time() - start_time
    print("\n==============================")
    print(f"🎉 Hoàn tất toàn bộ pipeline sau {elapsed:.2f} giây.")
    print("==============================\n")


if __name__ == "__main__":
    main()
