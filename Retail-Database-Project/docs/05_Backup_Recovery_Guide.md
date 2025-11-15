# 05. Hướng dẫn Backup & Recovery cho RetailDB (Oracle 19c)

Tài liệu mô tả cơ chế backup RMAN được triển khai cho dự án RetailDB, bao gồm:
- Thiết lập thư mục và FRA
- Cấu hình RMAN
- Script backup FULL / INCREMENTAL / ARCHIVELOG
- Script bảo trì RMAN
- Thiết lập crontab
- Quy trình phục hồi (Recovery Workflow)

## 1. Chuẩn bị Thư mục Backup

```
sudo mkdir -p /u01/backup/rman
sudo chown oracle:dba /u01/backup/rman
chmod 750 /u01/backup/rman
```

---

## 2. Cấu hình FRA (Fast Recovery Area)

```sql
ALTER SYSTEM SET db_recovery_file_dest='/u01/app/oracle/recovery_area';
ALTER SYSTEM SET db_recovery_file_dest_size=200G;
```

---

## 3. Cấu hình Chính cho RMAN

- Kết nối RMAN: rman target /
- Thiết lập RMAN:
    ```
    CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
    CONFIGURE CONTROLFILE AUTOBACKUP ON;
    CONFIGURE DEVICE TYPE DISK PARALLELISM 4;
    CONFIGURE COMPRESSION ALGORITHM 'MEDIUM';
    CONFIGURE BACKUP OPTIMIZATION ON;
    CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u01/backup/rman/%d_%U';
    ```
- Ý nghĩa:
    + 7 ngày retention → giữ backup & archivelog trong 7 ngày
    + Autobackup controlfile → đảm bảo có thể phục hồi ngay cả khi controlfile mất
    + Parallelism 4 → tăng tốc độ backup
    + Compression → tiết kiệm dung lượng backup
    + Backup optimization → bỏ qua các file không đổi (archivelog đã backup)

---

## 4. Script Backup RMAN

Tất cả script được đặt ở: /home/oracle/scripts/

### 4.1. Backup FULL hàng tuần
rman_full_weekly.sh
```
#!/bin/bash
. /home/oracle/.bash_profile

export ORACLE_SID=orcl
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

rman target / <<'RMAN_EOF'
RUN {
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK FORMAT '/u01/backup/rman/%d_FULL_%U';
  ALLOCATE CHANNEL c2 DEVICE TYPE DISK FORMAT '/u01/backup/rman/%d_FULL_%U';

  BACKUP AS COMPRESSED BACKUPSET INCREMENTAL LEVEL 0 DATABASE
    FORMAT '/u01/backup/rman/%d_FULL_%U';

  BACKUP AS COMPRESSED BACKUPSET CURRENT CONTROLFILE;

  SQL 'ALTER SYSTEM ARCHIVE LOG CURRENT';

  BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL DELETE INPUT;

  RELEASE CHANNEL c1;
  RELEASE CHANNEL c2;
}
RMAN_EOF
```

### 4.2. Backup INCREMENTAL Level 1 hằng ngày
rman_inc_daily.sh
```
#!/bin/bash
. /home/oracle/.bash_profile

export ORACLE_SID=orcl
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

rman target / <<'RMAN_EOF'
RUN {
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK FORMAT '/u01/backup/rman/%d_INC_%U';

  BACKUP AS COMPRESSED BACKUPSET INCREMENTAL LEVEL 1 DATABASE;

  BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL DELETE INPUT;

  RELEASE CHANNEL c1;
}
RMAN_EOF
```

### 4.3. Backup ARCHIVELOG mỗi 30 phút
rman_arch_hourly.sh
```
#!/bin/bash
. /home/oracle/.bash_profile

export ORACLE_SID=orcl
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

rman target / <<'RMAN_EOF'
BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL DELETE INPUT;
RMAN_EOF
```

### 4.4. Script bảo trì RMAN (Crosscheck + Delete expired/obsolete)
rman_maint.sh
```
#!/bin/bash
. /home/oracle/.bash_profile

export ORACLE_SID=orcl
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

rman target / <<'RMAN_EOF'
CROSSCHECK BACKUP;
DELETE NOPROMPT EXPIRED BACKUP;
DELETE NOPROMPT OBSOLETE;
REPORT OBSOLETE;
RMAN_EOF
```

---

## 5. Cấp quyền thực thi script

```
chmod +x /home/oracle/scripts/*.sh
```

---

## 6. Thiết lập Lịch Backup qua Cron

```
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/u01/app/oracle/product/19.0.0/dbhome_1/bin

# Full backup vào Chủ nhật 02:00
0 2 * * 0 /home/oracle/scripts/rman_full_weekly.sh >> /var/log/rman_full.log 2>&1

# Incremental hàng ngày 03:00 (trừ Chủ nhật)
0 3 * * 1-6 /home/oracle/scripts/rman_inc_daily.sh >> /var/log/rman_inc.log 2>&1

# Backup archivelog mỗi 30 phút
*/30 * * * * /home/oracle/scripts/rman_arch_hourly.sh >> /var/log/rman_arch.log 2>&1

# Crosscheck hàng ngày 03:30
30 3 * * * /home/oracle/scripts/rman_maint.sh >> /var/log/rman_maint.log 2>&1
```

---

## 7. Quy trình Phục hồi (Recovery Procedure)

### 7.1. Phục hồi Control File
Khi mất controlfile:
```
rman target /

RESTORE CONTROLFILE FROM AUTOBACKUP;
ALTER DATABASE MOUNT;
```

### 7.2. Phục hồi Database từ backup FULL + Incremental
```
RUN {
  RESTORE DATABASE;
  RECOVER DATABASE;
}
```

### 7.3. Mở Database sau khi phục hồi
```sql
ALTER DATABASE OPEN RESETLOGS;
```

---

## 8. Kiểm tra tình trạng Backup

```
LIST BACKUP SUMMARY;
REPORT OBSOLETE;
CROSSCHECK BACKUP;
```

## 9. Vị trí lưu log

| Script | Log |
|--------|-----|
| FULL | /var/log/rman_full.log |
| Incremental | /var/log/rman_inc.log |
| Archivelog | /var/log/rman_arch.log |
| Maintenance | /var/log/rman_maint.log |

---

## 10. Kết luận
Hệ thống backup đã bao gồm:
- Full weekly
- Incremental daily
- Archivelog mỗi 30 phút
- Quét dọn backup tự động
- Khả năng phục hồi đầy đủ từ mọi mức độ sự cố