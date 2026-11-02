
const cart = new Map();
const products = new Map();

const currency = value =>
  new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD"
  }).format(value);

function productIcon(name) {
  const value = name.toLowerCase();
  if (value.includes("laptop")) return "💻";
  if (value.includes("headphone")) return "🎧";
  if (value.includes("keyboard")) return "⌨️";
  return "📦";
}

async function loadProducts() {
  const grid = document.getElementById("product-grid");

  try {
    const response = await fetch("/api/products");

    if (!response.ok) {
      throw new Error("Unable to load products");
    }

    const data = await response.json();
    grid.replaceChildren();
    products.clear();

    document.getElementById("product-count").textContent =
      `${data.length} products`;

    for (const product of data) {
      products.set(product.id, product);

      const card = document.createElement("article");
      card.className = "product-card";

      const image = document.createElement("div");
      image.className = "product-image";
      image.textContent = productIcon(product.name);

      const title = document.createElement("h3");
      title.textContent = product.name;

      const price = document.createElement("p");
      price.className = "price";
      price.textContent = currency(product.price);

      const stock = document.createElement("p");
      stock.className = "stock";
      stock.textContent = `${product.stock} available`;

      const button = document.createElement("button");
      button.className = "add-button";
      button.textContent = product.stock ? "Add to Cart" : "Out of Stock";
      button.disabled = product.stock === 0;
      button.addEventListener("click", () => addToCart(product.id));

      card.append(image, title, price, stock, button);
      grid.append(card);
    }
  } catch (error) {
    grid.textContent = "Products are unavailable. Please try again.";
  }
}

function addToCart(id) {
  const product = products.get(id);
  const quantity = cart.get(id) || 0;

  if (!product || quantity >= product.stock) return;

  cart.set(id, quantity + 1);
  renderCart();
}

function renderCart() {
  const container = document.getElementById("cart-items");
  container.replaceChildren();

  let total = 0;
  let count = 0;

  if (!cart.size) {
    const empty = document.createElement("p");
    empty.className = "muted";
    empty.textContent = "Your cart is empty.";
    container.append(empty);
  }

  for (const [id, quantity] of cart) {
    const product = products.get(id);
    if (!product) continue;

    const lineTotal = product.price * quantity;
    total += lineTotal;
    count += quantity;

    const row = document.createElement("div");
    row.className = "cart-item";

    const name = document.createElement("span");
    name.textContent = `${product.name} × ${quantity}`;

    const price = document.createElement("strong");
    price.textContent = currency(lineTotal);

    row.append(name, price);
    container.append(row);
  }

  document.getElementById("cart-count").textContent = count;
  document.getElementById("cart-total").textContent = currency(total);
}

loadProducts();
