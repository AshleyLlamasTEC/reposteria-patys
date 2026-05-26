import { useState } from "react";
import { router } from "@inertiajs/react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Minus, Plus, ShoppingCart, Loader2 } from "lucide-react";

export default function ProductModal({ isOpen, product, onClose, onAddToCartSuccess }) {
  const [quantity, setQuantity] = useState(1);
  const [isAdding, setIsAdding] = useState(false);
  const [error, setError] = useState("");

  if (!product) return null;

  const imageUrl = product.image_url || "/images/default-cake.jpg";
  const subtotal = quantity * Number(product.base_price);
  const isOutOfStock = product.stock <= 0;

  const handleAddToCart = () => {
    if (isOutOfStock) return;

    setIsAdding(true);
    setError("");

    router.post(
      route("cart.add"),
      {
        product_id: product.id,
        quantity: quantity,
      },
      {
        onSuccess: () => {
          setIsAdding(false);
          onAddToCartSuccess(`¡${product.name} agregado al carrito!`);
        },
        onError: (errors) => {
          setIsAdding(false);
          setError(errors.error || "No se pudo agregar al carrito.");
        },
        preserveScroll: true,
      }
    );
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
        >
          <motion.div
            className="bg-white rounded-3xl overflow-hidden max-w-2xl w-full mx-auto shadow-2xl"
            initial={{ scale: 0.9, opacity: 0, y: 20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            exit={{ scale: 0.9, opacity: 0, y: 20 }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex flex-col md:flex-row">
              {/* Imagen */}
              <div className="md:w-1/2 bg-gray-100 relative">
                <img
                  src={imageUrl}
                  alt={product.name}
                  className="w-full h-64 md:h-full object-cover"
                  onError={(e) => {
                    e.target.style.display = "none";
                    const fallback = document.createElement("div");
                    fallback.className =
                      "w-full h-full bg-gradient-to-br from-pink-200 to-purple-200 flex items-center justify-center text-6xl";
                    fallback.innerHTML = "🎂";
                    e.target.parentNode.appendChild(fallback);
                  }}
                />
                {product.popular && (
                  <div className="absolute top-4 left-4 bg-pink-500 text-white px-3 py-1 rounded-full text-sm font-semibold">
                    Más vendido
                  </div>
                )}
              </div>

              {/* Detalles */}
              <div className="md:w-1/2 p-6 md:p-8">
                <div className="flex justify-between items-start mb-4">
                  <h3 className="text-2xl font-bold text-gray-800">{product.name}</h3>
                  <button
                    onClick={onClose}
                    className="text-gray-400 hover:text-gray-600 transition-colors"
                  >
                    <X className="w-6 h-6" />
                  </button>
                </div>

                <p className="text-gray-600 mb-4">{product.description}</p>

                {/* Categoría y stock */}
                <div className="flex items-center gap-2 text-sm text-gray-500 mb-4">
                  <span className="bg-pink-50 text-pink-600 px-2 py-1 rounded-full">
                    {product.category?.name || "Sin categoría"}
                  </span>
                  <span
                    className={`ml-2 ${
                      isOutOfStock ? "text-red-500" : "text-green-600"
                    }`}
                  >
                    {isOutOfStock
                      ? "Agotado"
                      : `Stock: ${product.stock} disponibles`}
                  </span>
                </div>

                {/* Selector de cantidad */}
                <div className="flex items-center justify-between mb-4">
                  <span className="text-3xl font-bold text-pink-500">
                    ${Number(product.base_price).toFixed(2)}
                  </span>
                  <div className="flex items-center gap-3">
                    <button
                      onClick={() => setQuantity(Math.max(1, quantity - 1))}
                      className="w-10 h-10 rounded-full border border-gray-300 flex items-center justify-center hover:bg-gray-50"
                      disabled={isOutOfStock}
                    >
                      <Minus className="w-4 h-4" />
                    </button>
                    <span className="text-lg font-semibold">{quantity}</span>
                    <button
                      onClick={() => setQuantity(quantity + 1)}
                      className="w-10 h-10 rounded-full border border-gray-300 flex items-center justify-center hover:bg-gray-50"
                      disabled={isOutOfStock}
                    >
                      <Plus className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                {/* Subtotal */}
                <div className="border-t border-gray-100 pt-4 mb-6">
                  <div className="flex justify-between items-center text-sm">
                    <span className="text-gray-500">Subtotal</span>
                    <span className="font-semibold text-gray-800">
                      ${subtotal.toFixed(2)}
                    </span>
                  </div>
                </div>

                {/* Error */}
                {error && (
                  <div className="mb-4 p-3 bg-red-50 text-red-700 rounded-xl text-sm">
                    {error}
                  </div>
                )}

                {/* Botón de agregar */}
                <button
                  onClick={handleAddToCart}
                  disabled={isOutOfStock || isAdding}
                  className="w-full bg-pink-500 hover:bg-pink-600 text-white py-3 rounded-xl font-semibold flex items-center justify-center gap-2 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isAdding ? (
                    <Loader2 className="w-5 h-5 animate-spin" />
                  ) : (
                    <ShoppingCart className="w-5 h-5" />
                  )}
                  {isOutOfStock
                    ? "Producto agotado"
                    : isAdding
                    ? "Agregando..."
                    : `Agregar al Carrito - $${subtotal.toFixed(2)}`}
                </button>
              </div>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
