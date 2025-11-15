import os
from faker import Faker
from data_generator.utils.csv_writer import write_csv
from data_generator.utils.id_tracker import save_ids


# Dùng locale Việt Nam
fake = Faker('vi_VN')

# Thư mục xuất file
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "data", "catalogs")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_product_categories():
    categories = [
        ("Đồ uống", "Các loại nước giải khát, cà phê, trà, sữa..."),
        ("Bánh kẹo", "Các loại bánh, kẹo, snack, socola..."),
        ("Thực phẩm tươi sống", "Thịt, cá, rau củ, trái cây tươi..."),
        ("Thực phẩm khô", "Mì gói, gạo, đậu, ngũ cốc..."),
        ("Gia vị", "Đường, muối, nước mắm, dầu ăn, bột ngọt..."),
        ("Đồ gia dụng", "Chén, dĩa, nồi, dao kéo, dụng cụ nấu ăn..."),
        ("Chăm sóc cá nhân", "Dầu gội, sữa tắm, bàn chải, kem đánh răng..."),
        ("Chăm sóc nhà cửa", "Nước lau sàn, nước rửa chén, bột giặt..."),
        ("Thực phẩm đông lạnh", "Xúc xích, chả giò, hải sản đông lạnh..."),
        ("Sữa và sản phẩm từ sữa", "Sữa tươi, sữa chua, phô mai..."),
    ]

    data = [
        {"CategoryID": i + 1, "CategoryName": name, "Description": desc}
        for i, (name, desc) in enumerate(categories)
    ]

    write_csv(
        os.path.join(OUTPUT_DIR, "Product_Categories.csv"),
        ["CategoryID", "CategoryName", "Description"],
        data
    )

    save_ids("Product_Categories", [d["CategoryID"] for d in data])

    print(f"[OK] Product_Categories ({len(data)} hàng)")

def generate_product_units():
    units = [
        ("Cái", 1.0),
        ("Hộp", 10.0),
        ("Gói", 5.0),
        ("Kg", 1.0),
        ("Gram", 0.001),
        ("Lít", 1.0),
        ("Mililít", 0.001)
    ]
    data = [
        {"UnitID": i + 1, "UnitName": u, "ConversionRate": r}
        for i, (u, r) in enumerate(units)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Product_Units.csv"),
        ["UnitID", "UnitName", "ConversionRate"],
        data
    )

    save_ids("Product_Units", [d["UnitID"] for d in data])

    print(f"[OK] Product_Units ({len(data)} hàng)")


def generate_product_status():
    statuses = ["Còn hàng", "Hết hàng", "Ngừng kinh doanh", "Đặt trước"]
    data = [
        {"StatusID": i + 1, "StatusName": s, "Description": fake.sentence()}
        for i, s in enumerate(statuses)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Product_Status.csv"),
        ["StatusID", "StatusName", "Description"],
        data
    )
     
    save_ids("Product_Status", [d["StatusID"] for d in data]) 

    print(f"[OK] Product_Status ({len(data)} hàng)")


def generate_employee_status():
    statuses = [
        ("Đang làm việc", "Nhân viên đang làm việc bình thường"),
        ("Nghỉ phép", "Nghỉ phép ngắn hạn hoặc tạm thời"),
        ("Đã nghỉ hưu", "Nhân viên đã về hưu"),
        ("Đã nghỉ việc", "Nhân viên đã nghỉ việc hẳn")
    ]
    data = [
        {"StatusID": i + 1, "StatusName": s, "Description": d}
        for i, (s, d) in enumerate(statuses)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Employee_Status.csv"),
        ["StatusID", "StatusName", "Description"],
        data
    )

    save_ids("Employee_Status", [d["StatusID"] for d in data]) 

    print(f"[OK] Employee_Status ({len(data)} hàng)")


def generate_employee_types():
    types = [
        ("Thu ngân", "Phụ trách thanh toán, in hóa đơn, hỗ trợ khách hàng tại quầy."),
        ("Bán hàng", "Tư vấn, sắp xếp và kiểm hàng trên kệ."),
        ("Quản lý", "Giám sát nhân viên, xử lý sự cố và quản lý ca làm."),
        ("Kế toán", "Theo dõi doanh thu, chi phí và báo cáo tài chính."),
        ("Bảo vệ", "Giữ xe và đảm bảo an ninh cửa hàng."),
        ("Kho", "Nhập hàng, kiểm kho, đối soát hàng hóa."),
        ("Giao hàng", "Giao đơn nội bộ hoặc đơn hàng online."),
        ("Thu mua", "Làm việc với nhà cung cấp, nhập hàng mới."),
        ("Marketing", "Tổ chức chương trình khuyến mãi, trưng bày sản phẩm."),
        ("IT", "Bảo trì hệ thống POS, mạng nội bộ, camera.")
    ]
    data = [
        {"TypeID": i + 1, "TypeName": t, "Description": d}
        for i, (t, d) in enumerate(types)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Employee_Types.csv"),
        ["TypeID", "TypeName", "Description"],
        data
    )

    save_ids("Employee_Types", [d["TypeID"] for d in data]) 

    print(f"[OK] Employee_Types ({len(data)} hàng)")



def generate_customer_types():
    types = ["Thường", "VIP", "Sỉ", "Online"]
    data = [
        {"TypeID": i + 1, "TypeName": t, "Description": fake.sentence()}
        for i, t in enumerate(types)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Customer_Types.csv"),
        ["TypeID", "TypeName", "Description"],
        data
    )

    save_ids("Customer_Types", [d["TypeID"] for d in data]) 

    print(f"[OK] Customer_Types ({len(data)} hàng)")


def generate_customer_status():
    statuses = ["Hoạt động", "Ngưng hoạt động", "Cấm giao dịch"]
    data = [
        {"StatusID": i + 1, "StatusName": s, "Description": fake.sentence()}
        for i, s in enumerate(statuses)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Customer_Status.csv"),
        ["StatusID", "StatusName", "Description"],
        data
    )

    save_ids("Customer_Status", [d["StatusID"] for d in data]) 

    print(f"[OK] Customer_Status ({len(data)} hàng)")


def generate_branch_types():
    types = ["Bán lẻ", "Kho hàng", "Nhượng quyền", "Trực tuyến"]
    data = [
        {"TypeID": i + 1, "TypeName": t, "Description": fake.sentence()}
        for i, t in enumerate(types)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Branch_Types.csv"),
        ["TypeID", "TypeName", "Description"],
        data
    )

    save_ids("Branch_Types", [d["TypeID"] for d in data]) 

    print(f"[OK] Branch_Types ({len(data)} hàng)")


def generate_branch_status():
    statuses = ["Đang hoạt động", "Tạm đóng", "Đang bảo trì"]
    data = [
        {"StatusID": i + 1, "StatusName": s, "Description": fake.sentence()}
        for i, s in enumerate(statuses)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Branch_Status.csv"),
        ["StatusID", "StatusName", "Description"],
        data
    )

    save_ids("Branch_Status", [d["StatusID"] for d in data]) 

    print(f"[OK] Branch_Status ({len(data)} hàng)")


def generate_order_status():
    statuses = ["Chờ xử lý", "Đang giao", "Đã giao", "Đã hủy"]
    data = [
        {"StatusID": i + 1, "StatusName": s, "Description": fake.sentence()}
        for i, s in enumerate(statuses)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Order_Status.csv"),
        ["StatusID", "StatusName", "Description"],
        data
    )

    save_ids("Order_Status", [d["StatusID"] for d in data])

    print(f"[OK] Order_Status ({len(data)} hàng)")


def generate_invoice_status():
    statuses = ["Chưa thanh toán", "Đã thanh toán", "Hoàn tiền", "Quá hạn"]
    data = [
        {"StatusID": i + 1, "StatusName": s, "Description": fake.sentence()}
        for i, s in enumerate(statuses)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Invoice_Status.csv"),
        ["StatusID", "StatusName", "Description"],
        data
    )

    save_ids("Invoice_Status", [d["StatusID"] for d in data])

    print(f"[OK] Invoice_Status ({len(data)} hàng)")


def generate_payment_methods():
    methods = ["Tiền mặt", "Thẻ tín dụng", "Chuyển khoản ngân hàng", "Ví điện tử"]
    data = [
        {"MethodID": i + 1, "MethodName": m, "Description": fake.sentence()}
        for i, m in enumerate(methods)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Payment_Methods.csv"),
        ["MethodID", "MethodName", "Description"],
        data
    )

    save_ids("Payment_Methods", [d["MethodID"] for d in data])

    print(f"[OK] Payment_Methods ({len(data)} hàng)")


def generate_sale_channels():
    channels = ["Trực tuyến", "Tại cửa hàng", "Ứng dụng di động", "Đối tác"]
    data = [
        {"ChannelID": i + 1, "ChannelName": c, "Description": fake.sentence()}
        for i, c in enumerate(channels)
    ]
    write_csv(
        os.path.join(OUTPUT_DIR, "Sale_Channels.csv"),
        ["ChannelID", "ChannelName", "Description"],
        data
    )

    save_ids("Sale_Channels", [d["ChannelID"] for d in data])

    print(f"[OK] Sale_Channels ({len(data)} hàng)")


def main():
    print("=== Sinh dữ liệu danh mục (Catalogs) ===")
    generate_product_categories()
    generate_product_units()
    generate_product_status()
    generate_employee_status()
    generate_employee_types()
    generate_customer_types()
    generate_customer_status()
    generate_branch_types()
    generate_branch_status()
    generate_order_status()
    generate_invoice_status()
    generate_payment_methods()
    generate_sale_channels()
    print("=== Hoàn tất: Catalogs đã được sinh ===")

if __name__ == "__main__":
    main()
