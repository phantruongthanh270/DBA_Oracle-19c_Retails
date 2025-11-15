# utils/id_tracker.py
import json
import os
import random

BASE_DIR = os.path.dirname(__file__)
TRACK_FILE = os.path.join(BASE_DIR, "id_tracker.json")

def load_all_ids():
    """Đọc toàn bộ file JSON, xử lý khi file bị trống hoặc lỗi."""
    if not os.path.exists(TRACK_FILE):
        return {}
    try:
        with open(TRACK_FILE, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return data if isinstance(data, dict) else {}
    except (json.JSONDecodeError, ValueError):
        print("[WARN] id_tracker.json bị hỏng hoặc trống → reset lại.")
        return {}

def save_ids(table_name, ids):
    """Ghi đè danh sách ID của một bảng."""
    data = load_all_ids()
    data[table_name] = ids
    with open(TRACK_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    print(f"[SAVE] {table_name}: {len(ids)} IDs")

def append_ids(table_name, new_ids):
    """Thêm ID mới vào danh sách cũ."""
    data = load_all_ids()
    existing = set(data.get(table_name, []))
    existing.update(new_ids)
    data[table_name] = sorted(existing)
    with open(TRACK_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
    print(f"[APPEND] {table_name}: +{len(new_ids)} IDs (tổng {len(existing)})")

def load_ids(table_name):
    """Đọc danh sách ID đã lưu."""
    data = load_all_ids()
    return data.get(table_name, {})

def get_random_id(table_name):
    """Lấy 1 ID ngẫu nhiên (dùng để sinh khóa ngoại)."""
    ids = load_ids(table_name)
    if not ids:
        raise ValueError(f"Không có ID nào cho bảng {table_name}")
    return random.choice(ids)
