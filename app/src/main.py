import os
from decimal import Decimal

import psycopg
from psycopg.rows import dict_row
from flask import Flask, jsonify, render_template

app = Flask(__name__)


def get_db_connection():
    return psycopg.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=int(os.environ.get("DB_PORT", "5432")),
        dbname=os.environ.get("DB_NAME", "cloudcart"),
        user=os.environ.get("DB_USER", "cloudcart"),
        password=os.environ["DB_PASSWORD"],
        row_factory=dict_row,
        connect_timeout=5,
    )


def serialize_product(product):
    if product is None:
        return None

    return {
        **product,
        "price": float(product["price"])
        if isinstance(product["price"], Decimal)
        else product["price"],
    }


@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "cloudcart-api"
    }), 200


@app.get("/ready")
def ready():
    try:
        with get_db_connection() as conn:
            conn.execute("SELECT 1")

        return jsonify({"status": "ready"}), 200

    except psycopg.Error:
        app.logger.exception("Database readiness check failed")
        return jsonify({"status": "not_ready"}), 503


@app.get("/api/products")
def get_products():
    try:
        with get_db_connection() as conn:
            products = conn.execute(
                "SELECT id, name, price, stock FROM products ORDER BY id"
            ).fetchall()

        return jsonify([
            serialize_product(product) for product in products
        ]), 200

    except psycopg.Error:
        app.logger.exception("Failed to retrieve products")
        return jsonify({"error": "Database unavailable"}), 503


@app.get("/api/products/<int:product_id>")
def get_product(product_id):
    try:
        with get_db_connection() as conn:
            product = conn.execute(
                "SELECT id, name, price, stock FROM products WHERE id = %s",
                (product_id,),
            ).fetchone()

        if product is None:
            return jsonify({"error": "Product not found"}), 404

        return jsonify(serialize_product(product)), 200

    except psycopg.Error:
        app.logger.exception("Failed to retrieve product")
        return jsonify({"error": "Database unavailable"}), 503

@app.get("/")
def storefront():
        return render_template("index.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

