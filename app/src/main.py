from flask import Flask, jsonify

app = Flask(__name__)

PRODUCTS = [
    {
        "id": 1,
        "name": "CloudCart Laptop",
        "price": 899.99,
        "stock": 25
    },
    {
        "id": 2,
        "name": "Wireless Headphones",
        "price": 129.99,
        "stock": 50
    },
    {
        "id": 3,
        "name": "Mechanical Keyboard",
        "price": 79.99,
        "stock": 40
    }
]


@app.get("/health")
def health():
    return jsonify({
        "status": "healthy",
        "service": "cloudcart-api"
    }), 200


@app.get("/api/products")
def get_products():
    return jsonify(PRODUCTS), 200


@app.get("/api/products/<int:product_id>")
def get_product(product_id):
    product = next(
        (item for item in PRODUCTS if item["id"] == product_id),
        None
    )

    if product is None:
        return jsonify({"error": "Product not found"}), 404

    return jsonify(product), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
