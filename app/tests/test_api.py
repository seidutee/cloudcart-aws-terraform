import sys
from pathlib import Path
from unittest.mock import MagicMock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from src.main import app


def test_health():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json["status"] == "healthy"


@patch("src.main.get_db_connection")
def test_get_products(mock_connection):
    conn = MagicMock()
    conn.execute.return_value.fetchall.return_value = [
        {"id": 1, "name": "CloudCart Laptop", "price": 899.99, "stock": 25}
    ]

    mock_connection.return_value.__enter__.return_value = conn

    response = app.test_client().get("/api/products")

    assert response.status_code == 200
    assert response.json[0]["id"] == 1


@patch("src.main.get_db_connection")
def test_get_product_by_id(mock_connection):
    conn = MagicMock()
    conn.execute.return_value.fetchone.return_value = {
        "id": 1,
        "name": "CloudCart Laptop",
        "price": 899.99,
        "stock": 25
    }

    mock_connection.return_value.__enter__.return_value = conn

    response = app.test_client().get("/api/products/1")

    assert response.status_code == 200
    assert response.json["id"] == 1


@patch("src.main.get_db_connection")
def test_product_not_found(mock_connection):
    conn = MagicMock()
    conn.execute.return_value.fetchone.return_value = None

    mock_connection.return_value.__enter__.return_value = conn

    response = app.test_client().get("/api/products/999")

    assert response.status_code == 404
