# 01. Project Overview - Retail Database

## 1. Giới thiệu dự án

**Retail Database Project** được xây dựng nhằm mô phỏng hệ thống dữ liệu nghiệp vụ cho một chuỗi cửa hàng bán lẻ đa chi nhánh.  
Mục tiêu của dự án là **thiết kế, triển khai và quản trị cơ sở dữ liệu** phục vụ toàn bộ vòng đời dữ liệu — từ sản phẩm, khách hàng, nhân viên, đơn hàng, thanh toán cho đến hóa đơn và báo cáo.

Dự án đồng thời đóng vai trò **portfolio cá nhân** trong lộ trình học chứng chỉ **IBM Data Engineer**, thể hiện khả năng:
- Thiết kế cơ sở dữ liệu quan hệ (RDBMS) chuẩn hóa.
- Tối ưu lưu trữ và phân vùng dữ liệu lớn (Partitioning).
- Xây dựng pipeline ETL bằng Python và SQL*Loader.
- Quản trị, bảo mật và sao lưu phục hồi dữ liệu.

---

## 2. Phạm vi & Mục tiêu kỹ thuật

| Hạng mục | Mô tả |
|-----------|--------|
| Hệ quản trị CSDL | **Oracle Database 19c** (có partitioning, tablespace, CLOB, trigger, constraint) |
| Môi trường triển khai | VMware với Oracle Linux 8 |
| Loại dữ liệu | Sản phẩm, nhân viên, khách hàng, đơn hàng, hóa đơn, thanh toán |
| Quy mô dữ liệu | 10 triệu đơn hàng giả lập qua Python Faker |
| Mục tiêu | Xây dựng hệ thống dữ liệu hoàn chỉnh cho Retail, có khả năng mở rộng, dễ bảo trì và tích hợp thêm phân tích BI |

---

## 3. Kiến trúc tổng quan

Hệ thống **Retail Database** được thiết kế theo mô hình **OLTP (Online Transaction Processing)** — phục vụ lưu trữ và xử lý dữ liệu nghiệp vụ giao dịch hằng ngày.  

Cấu trúc gồm 3 lớp chính:

1. **Source Layer** – dữ liệu nguồn (CSV, API, dữ liệu giả lập từ Python Faker).  
2. **Operational Database (Retail DB)** – nơi lưu trữ dữ liệu chuẩn hóa (3NF), phục vụ nghiệp vụ bán hàng, khách hàng, nhân viên, đơn hàng, hóa đơn.  
3. **Analytical Layer (tùy chọn trong giai đoạn mở rộng)** – có thể trích xuất dữ liệu từ Retail DB sang Data Warehouse/BI sau này.

```mermaid
flowchart LR
    A[Source Data (CSV, API, Faker)] --> B[Operational Retail Database (Oracle)]
    B --> C[Future: Data Warehouse / BI Tools]
```

---

## 4. Stack công nghệ

| Thành phần | Công cụ / Công nghệ |
|------------|---------------------|
| Cơ sở dữ liệu | Oracle Database 19c |
| ETL | Python (Pandas, Faker, ...), SQL*Loader (ctl, sh, bat, csv) |
| Quản lý script | Git / VSCode |
| Backup & Restore | Oracle RMAN |
| Triển khai | VMware + Oracle Linux 8 (server) |
| SSH | WinSCP, MobaXterm, SQL Developer (Windown 11) |

---

## 5. Lợi ích & Mục tiêu học tập

- Nâng cao kỹ năng Oracle Database.
- Nâng cao kỹ năng Database Design & ETL Development.
- Hiểu quy trình DBA thực tế: security, backup, tuning, deploy.
- Tạo nền tảng cho các vị trí DBA / Data Engineering / Analytics sau này.
- Xây dựng portfolio cá nhân.

---

## 6. Cấu trúc tài liệu đi kèm

| STT | File | Mô tả |
|-----|------|-------|
| 1 | 02_Database_Design.md | Thiết kế cơ sở dữ liệu & ERD |
| 2 | 03_ETL_Flow.md | Mô tả pipeline ETL |
| 3 | 04_Security_Policy.md | Chính sách bảo mật & phân quyền |
| 4 | 05_Backup_Recovery_Guide | Hướng dẫn backup & restore |
| 5 | 06_Performance_Tuning.md | Ghi chú tối ưu hiệu năng |
| 6 | 07_Deployment_Guide.md | Hướng dẫn triển khai hệ thống |

---

## 7. Ghi chú cá nhân

Dự án này được phát triển trong khuôn khổ học tập chứng chỉ IBM Data Engineer và được sử dụng làm portfolio cá nhân để thể hiện khả năng:

- Ứng dụng kiến thức về thiết kế & quản trị cơ sở dữ liệu thực tế.
- Rèn luyện kỹ năng viết tài liệu kỹ thuật rõ ràng, logic.
- Thể hiện khả năng làm việc độc lập như một Database Administrator (DBA) và Data Engineer.