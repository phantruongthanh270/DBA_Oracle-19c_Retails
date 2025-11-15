# Explanation

Đây là script khởi tạo toàn bộ dữ liệu giả cho hệ thống bán lẻ, bắt đầu từ dữ liệu tham chiếu nhỏ, rồi đến catalog, entities, quan hệ, và cuối cùng là các giao dịch thực tế.

## 1. Sinh dữ liệu phụ trợ (generate_static_tables)

- Tạo các bảng “tham chiếu” dùng chung trong hệ thống:
    + Order_Status, Invoice_Status → trạng thái đơn/hóa đơn
    + Payment_Methods → phương thức thanh toán
    + Sale_Channels → kênh bán hàng
- Mỗi mục được gán ID duy nhất (StatusID, MethodID, ChannelID).
- Dữ liệu được lưu ra CSV trong thư mục data/extras.
- Các ID cũng được lưu lại để dùng cho các bảng khác (qua save_ids).

---

## 2. Pipeline chính (main)

- Thời gian bắt đầu được ghi lại.
- Gồm các bước tuần tự:
    + Bảng phụ trợ (generate_static_tables)
    + Catalogs (generate_catalogs.main)
    + Entities (generate_entities.main)
    + Quan hệ giữa các thực thể (generate_relations.main)
    + Giao dịch thực tế (generate_transactions.main)
- Mỗi bước in ra thông báo trước khi chạy.
- Kết thúc pipeline, in ra thời gian thực thi tổng thể.