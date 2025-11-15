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