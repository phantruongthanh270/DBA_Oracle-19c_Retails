# 07. Deployment

## 1. Mục tiêu Tài liệu

Tài liệu triển khai (Deployment Guide) mô tả toàn bộ quy trình đưa hệ thống vào hoạt động trên môi trường máy ảo Oracle Linux, bao gồm:
- Chuẩn bị hạ tầng (OS, user, thư mục, phân quyền).
- Cài đặt và cấu hình Oracle Database 19c.
- Triển khai schema, bảng, chỉ mục, partition.
- Nạp dữ liệu ban đầu bằng ETL (SQL*Loader).
- Kiểm tra sau triển khai và xác nhận tính toàn vẹn dữ liệu.

Tài liệu được thiết kế để đảm bảo việc triển khai có thể được lặp lại, ổn định, và tự động hóa một phần.

---

## 2. Kiến trúc Triển khai

### 2.1 Môi trường
- OS: Oracle Linux 8 (Server)
- Database: Oracle Database 19c
- Cơ chế lưu trữ: File System
- Backup: RMAN + FRA
- ETL: Python + Faker → CSV → SQL*Loader
- Automation: Shell Script + Cron

### 2.2 Sơ đồ triển khai
Host Machine
    → VMware
        → Oracle Linux 8
            → Oracle DB 19c
            → SQL*Loader (ETL load)
            → RMAN Backup Scripts

---

## 3. Chuẩn Bị Môi Trường

### 3.1 Cài máy ảo Oracle Linux 8
Tải file iso của os Oracle Linux 8 và cài theo cấu hình mặc định.

### 3.4. Cài đặt gói phụ thuộc, cây thư mục và nhóm người dùng
- Bước 1: Dùng user root mở /etc/hosts bằng vi
   + nhập theo cấu trúc: ```<IP-address>  <fully-qualified-machine-name>  <machine-name>```, VD: ```192.168.169.130 ol8-19.localdomain  ol8-19```
   + Lưu và thoát vi
- Bước 2: mở /etc/hostname bằng vi
   + nhập: ol8-19.localdomain
   + Lưu và thoát
- Bước 3: Thiết lập tự động chạy các lệnh
    ```
    dnf install -y oracle-database-preinstall-19c
    dnf update -y
    ```
- Bước 4: Cài thêm một số gói bắt buộc:
    ```
    dnf install -y bc    
    dnf install -y binutils
    dnf install -y compat-libcap1
    dnf install -y compat-libstdc++-33
    dnf install -y dtrace-modules
    dnf install -y dtrace-modules-headers
    dnf install -y dtrace-modules-provider-headers
    dnf install -y dtrace-utils
    dnf install -y elfutils-libelf
    dnf install -y elfutils-libelf-devel
    dnf install -y fontconfig-devel
    dnf install -y glibc
    dnf install -y glibc-devel
    dnf install -y ksh
    dnf install -y libaio
    dnf install -y libaio-devel
    dnf install -y libdtrace-ctf-devel
    dnf install -y libXrender
    dnf install -y libXrender-devel
    dnf install -y libX11
    dnf install -y libXau
    dnf install -y libXi
    dnf install -y libXtst
    dnf install -y libgcc
    dnf install -y librdmacm-devel
    dnf install -y libstdc++
    dnf install -y libstdc++-devel
    dnf install -y libxcb
    dnf install -y make
    dnf install -y net-tools # Clusterware
    dnf install -y nfs-utils # ACFS
    dnf install -y python # ACFS
    dnf install -y python-configshell # ACFS
    dnf install -y python-rtslib # ACFS
    dnf install -y python-six # ACFS
    dnf install -y targetcli # ACFS
    dnf install -y smartmontools
    dnf install -y sysstat

    dnf install -y gcc
    dnf install -y unixODBC

    dnf install -y libnsl
    dnf install -y libnsl.i686
    dnf install -y libnsl2
    dnf install -y libnsl2.i686
    ```
- Bước 5: Tạo nhóm User mới
    ```
    groupadd -g 54321 oinstall
    groupadd -g 54322 dba
    groupadd -g 54323 oper 

    useradd -u 54321 -g oinstall -G dba,oper oracle
    ```
- Bước 6: Đặt mật khẩu cho người dùng
    ```
    passwd oracle
    ```
- Bước 7: Đặt Linux firewall enabled thành disable, mở vi /etc/selinux/config sau đó đổi "setenforce Permissive"
- Bước 8: Tắt tường lửa nếu đang bật, nhập lệnh sau
    ```
    systemctl stop firewalld
    systemctl disable firewalld
    ```
- Bước 9: Tạo các thư mục mà Oracle Database sẽ cài đặt
    ```
    mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1
    mkdir -p /u02/oradata
    chown -R oracle:oinstall /u01 /u02
    chmod -R 775 /u01 /u02
    ```
- Bước 10: Tạo thư mục "scripts"
    ```
    mkdir /home/oracle/scripts
    ```
- Bước 11: Tạo một tệp môi trường có tên "setEnv.sh". Các ký tự "$" được thoát bằng ký tự "\". Nếu bạn không tạo tệp bằng lệnh cat, bạn sẽ cần xóa các ký tự thoát.
    ```
    cat > /home/oracle/scripts/setEnv.sh <<EOF
    # Oracle Settings
    export TMP=/tmp
    export TMPDIR=\$TMP

    export ORACLE_HOSTNAME=ol8-19.localdomain
    export ORACLE_UNQNAME=orcl
    export ORACLE_BASE=/u01/app/oracle
    export ORACLE_HOME=\$ORACLE_BASE/product/19.0.0/dbhome_1
    export ORA_INVENTORY=/u01/app/oraInventory
    export ORACLE_SID=orcl
    export PDB_NAME=orclpdb
    export DATA_DIR=/u02/oradata

    export PATH=/usr/sbin:/usr/local/bin:\$PATH
    export PATH=\$ORACLE_HOME/bin:\$PATH

    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
    export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
    EOF
    ```
- Bước 12: Thêm tham chiếu đến tệp "setEnv.sh" vào cuối tệp "/home/oracle/.bash_profile"
    ```
    echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile
    ```
- Bước 13: Tạo tập lệnh "start_all.sh" và "stop_all.sh" có thể được gọi từ dịch vụ khởi động/tắt máy. Đảm bảo quyền sở hữu và quyền truy cập là chính xác
    ```
    cat > /home/oracle/scripts/start_all.sh <<EOF
    #!/bin/bash
    . /home/oracle/scripts/setEnv.sh

    export ORAENV_ASK=NO
    . oraenv
    export ORAENV_ASK=YES

    dbstart \$ORACLE_HOME
    EOF

    cat > /home/oracle/scripts/stop_all.sh <<EOF
    #!/bin/bash
    . /home/oracle/scripts/setEnv.sh

    export ORAENV_ASK=NO
    . oraenv
    export ORAENV_ASK=YES

    dbshut \$ORACLE_HOME
    EOF

    chown -R oracle:oinstall /home/oracle/scripts
    chmod u+x /home/oracle/scripts/*.sh
    ```
- Bước 14: Dùng WinSCP để chuyển "LINUX.X64_193000_db_home.zip" sang máy ảo (Oracle Linux) và đặt ở mục Downloads của User
- Bước 15: Chuyển để thư mục "$ORACLE_HOME" và giải nén tệp bằng lệnh "unzip -oq /home/oracle/Downloads/LINUX.X64_193000_db_home.zip"
- Bước 16: Fake Oracle Linux 7
    ```
    export CV_ASSUME_DISTID=OEL7.6
    ```
- Bước 17: Chạy trình cài đặt
    ```
    ./runInstaller
    ```
    
---

## 4. Cài đặt Oracle Database 19c

Khi cửa sổ Oracle Database 19c Installer hiện lên:
- Database Installation Options: chọn "Create and configure a single instance database. This option creates a starter database.".
- System Class: chọn "Server class".
- Database Edition: chọn "Enterprise Edition".
- Database Identifyers: sửa "Global database name" thành "orcl".
- Database Storage: đổi "Specify database file location" thành "/u02/oradata".
- Recovery options: chọn "Enable Recovery".
- Schema passwords: chọn "Use the same password for all accounts" và nhập mật khẩu.
- Root script execution: chọn "Automatically run configuration scripts" và "Use root user_credential" và nhập mật khẩu.
- Chờ cài đặt.

Sau khi cài đặt thành công, ta cần cấu hình một số thứ:
- Mở đường dẫn: /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/tnsname.ora thêm đoạn sau:
    ```
    ORCLPDB = 
        (DESCRIPTION = 
            (ADDRESS = (PROTOCOL = TCP) (HOST = OL8-19.localdomain) (PORT = 1521))
            (CONNECT_DATA = 
                (SERVER = DEDICARED)
                (SERVER_NAME = orclpdb)
            )
        )
    ```
- Mở lệnh "netmgr", mở cây và chọn "LISTENER" -> chọn "Database Services" -> "Add Database" -> đổi "Global database name" thành "orcl" -> Save.

---

## 5. Triển khai Cấu Trúc Database (Schema)

Xem mục: [text](02_Database_Design.md)

---

## 6. Triển khai ETL & Nạp Dữ liệu

Xem mục: [text](03_ETL_Flow.md)

---

## 7. Kết luận

Tài liệu hướng dẫn này cung cấp toàn bộ quy trình triển khai hệ thống từ việc chuẩn bị môi trường, cài đặt database, thiết lập cấu trúc schema, nạp dữ liệu ETL đến kiểm tra sau triển khai. Quy trình được thiết kế để đảm bảo:
- Có thể lặp lại
- Dễ kiểm soát
- Tự động hóa cao
- Phù hợp cho dự án DBA / Data Engineer cấp độ Portfolio

Việc triển khai thành công giúp đảm bảo môi trường hoạt động ổn định và sẵn sàng cho các bước tiếp theo như chạy ETL định kỳ, monitoring và tối ưu hóa.