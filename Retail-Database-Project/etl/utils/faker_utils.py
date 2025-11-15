# utils/faker_utils.py
from faker import Faker
import random
from datetime import datetime, timedelta
import unicodedata
import re

faker = Faker('vi_VN')

def random_date(start_year=2015, end_year=2025, as_date=True):
    """Sinh ngày hoặc datetime ngẫu nhiên."""
    start = datetime(start_year, 1, 1)
    end = datetime(end_year, 12, 31)
    delta = end - start
    result = start + timedelta(days=random.randint(0, delta.days))
    return result.date() if as_date else result

def random_phone():
    """Sinh số điện thoại Việt Nam hợp lệ."""
    return f"+84{random.randint(100000000, 999999999)}"

def normalize_text(text):
    """Loại bỏ dấu tiếng Việt và ký tự đặc biệt."""
    nfkd_form = unicodedata.normalize('NFKD', text)
    only_ascii = nfkd_form.encode('ASCII', 'ignore').decode('ASCII')
    return re.sub(r'[^a-zA-Z0-9]', '', only_ascii)

def random_email(name=None):
    """Sinh email hợp lệ từ tên."""
    if not name:
        name = faker.first_name() + faker.last_name()
    name = normalize_text(name)
    return f"{name.lower()}@example.com"

def random_price(min_price=10, max_price=500):
    """Sinh giá ngẫu nhiên."""
    return round(random.uniform(min_price, max_price), 2)

def random_status_name(options=None):
    """Sinh tên trạng thái từ danh sách cho trước hoặc mặc định."""
    default = ['Active', 'Inactive', 'Suspended', 'Pending']
    return random.choice(options or default)

def random_description():
    """Sinh mô tả ngắn."""
    return faker.sentence(nb_words=10)
