----------------------------TRIGGER---------------------------------
--Tự động cập nhật tổng tiền đơn hàng khi thêm/chỉnh sửa/xóa Order_Details
CREATE OR REPLACE TRIGGER trg_update_order_total
FOR INSERT OR UPDATE OR DELETE ON Order_Details
COMPOUND TRIGGER

  TYPE t_order_ids IS TABLE OF NUMBER;
  g_order_ids t_order_ids := t_order_ids();

  BEFORE EACH ROW IS
  BEGIN
    IF INSERTING OR UPDATING THEN
      g_order_ids.EXTEND;
      g_order_ids(g_order_ids.COUNT) := :NEW.OrderID;
    ELSIF DELETING THEN
      g_order_ids.EXTEND;
      g_order_ids(g_order_ids.COUNT) := :OLD.OrderID;
    END IF;
  END BEFORE EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    -- Xử lý từng OrderID riêng lẻ
    FOR idx IN 1 .. g_order_ids.COUNT LOOP
      BEGIN
        UPDATE Orders o
        SET o.TotalAmount = (
          SELECT NVL(SUM(Quantity * UnitPrice), 0)
          FROM Order_Details
          WHERE OrderID = g_order_ids(idx)
        )
        WHERE o.OrderID = g_order_ids(idx);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL; -- nếu không có OrderID
      END;
    END LOOP;
  END AFTER STATEMENT;

END trg_update_order_total;
/

------------------------Sequences----------------------
--Tạo các sequence dùng trong procedures và package đã tạo

CREATE SEQUENCE Product_Prices_SEQ
START WITH 30040
INCREMENT BY 1
NOCACHE;

CREATE SEQUENCE Invoices_SEQ
START WITH 2000001
INCREMENT BY 1
NOCACHE;
    
CREATE SEQUENCE Payments_SEQ
START WITH 2667044
INCREMENT BY 1
NOCACHE;
    
CREATE SEQUENCE Order_Invoices_SEQ
START WITH 2000001
INCREMENT BY 1
NOCACHE;