import { motion } from "framer-motion";
import { ShoppingCart, Star } from "lucide-react";

export default function ProductCard({ product, onSelect }) {
  const imageUrl = product.image_url || "/images/default-cake.jpg";
  const isOutOfStock = product.stock <= 0;

  return (
    <motion.div
      whileHover={{ y: -5 }}
      className="bg-white border border-pink-100 rounded-2xl overflow-hidden"
    >
      {/* Imagen */}
      <div className="relative h-72 bg-gray-100 overflow-hidden">
        <img
          src={imageUrl}
          alt={product.name}
          className="w-full h-full object-cover"
          onError={(e) => {
            e.target.style.display = "none";
            const fallback = document.createElement("div");
            fallback.className =
              "w-full h-full bg-gradient-to-br from-pink-200 to-purple-200 flex items-center justify-center text-4xl";
            fallback.innerHTML = "🎂";
            e.target.parentNode.appendChild(fallback);
          }}
        />
        {product.popular && (
          <span className="absolute top-2 left-2 bg-pink-500 text-white text-xs px-2 py-1 rounded-full">
            Popular
          </span>
        )}
        {isOutOfStock && (
          <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
            <span className="text-white font-bold text-lg">Agotado</span>
          </div>
        )}
      </div>

      {/* Contenido */}
      <div className="p-6">
        <h3 className="font-bold text-gray-800 text-lg truncate">{product.name}</h3>
        <div className="flex items-center gap-1 mt-1">
          <Star className="w-4 h-4 text-yellow-400 fill-current" />
          <span className="text-sm text-gray-600">{product.rating || 4.5}</span>
        </div>
        <div className="flex items-center justify-between mt-3">
          <span className="text-xl font-bold text-pink-500">
            ${Number(product.base_price).toFixed(2)}
          </span>
          <button
            onClick={onSelect}
            disabled={isOutOfStock}
            className="bg-pink-500 hover:bg-pink-600 text-white rounded-full p-2 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ShoppingCart className="w-5 h-5" />
          </button>
        </div>
      </div>
    </motion.div>
  );
}
