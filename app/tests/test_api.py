import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from src.main import app


def test_health():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_get_products():
    client = app.test_client()
    response = client.get("/api/products")

    assert response.status_code == 200
    assert len(response.json) == 3


def test_get_product_by_id():
    client = app.test_client()
    response = client.get("/api/products/1")

    assert response.status_code == 200
    assert response.json["id"] == 1


def test_product_not_found():
    client = app.test_client()
    response = client.get("/api/products/999")

    assert response.status_code == 404
