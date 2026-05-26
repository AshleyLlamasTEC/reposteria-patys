import { useState, useEffect, useRef, useCallback } from "react";
import { motion } from "framer-motion";
import { ChevronLeft, ChevronRight } from "lucide-react";
import ProductCard from "./ProductCard";

export default function ProductCarousel({ products = [], onSelectProduct }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const autoPlayRef = useRef(null);

  // ─── Responsive: cuántas tarjetas mostrar ─────────────────────
  const getVisibleItems = () => {
    if (typeof window === "undefined") return 4;
    if (window.innerWidth < 640) return 1;
    if (window.innerWidth < 1024) return 2;
    if (window.innerWidth < 1280) return 3;
    return 4;
  };

  const [visibleItems, setVisibleItems] = useState(getVisibleItems());

  useEffect(() => {
    const handleResize = () => setVisibleItems(getVisibleItems());
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  // ─── Navegación ───────────────────────────────────────────────
  const maxIndex = Math.max(products.length - visibleItems, 0);

  const goTo = useCallback(
    (index) => {
      setCurrentIndex(index);
      // Reiniciar auto‑slide tras interacción manual
      resetAutoPlay();
    },
    [maxIndex]
  );

  const nextSlide = useCallback(() => {
    setCurrentIndex((prev) => (prev >= maxIndex ? 0 : prev + 1));
    resetAutoPlay();
  }, [maxIndex]);

  const prevSlide = useCallback(() => {
    setCurrentIndex((prev) => (prev <= 0 ? maxIndex : prev - 1));
    resetAutoPlay();
  }, [maxIndex]);

  // ─── Auto‑slide inteligente ──────────────────────────────────
  const startAutoPlay = useCallback(() => {
    if (autoPlayRef.current) clearInterval(autoPlayRef.current);
    if (!products.length) return;
    autoPlayRef.current = setInterval(() => {
      setCurrentIndex((prev) => (prev >= maxIndex ? 0 : prev + 1));
    }, 4500);
  }, [maxIndex, products.length]);

  const resetAutoPlay = useCallback(() => {
    if (autoPlayRef.current) clearInterval(autoPlayRef.current);
    startAutoPlay();
  }, [startAutoPlay]);

  useEffect(() => {
    startAutoPlay();
    return () => clearInterval(autoPlayRef.current);
  }, [startAutoPlay]);

  // ─── Estado vacío ────────────────────────────────────────────
  if (!products.length) {
    return (
      <div className="py-24 text-center text-gray-500">
        No hay productos destacados.
      </div>
    );
  }

  // ─── Ancho de cada slide (porcentaje) ────────────────────────
  const itemWidth = 100 / visibleItems;

  return (
    <div className="relative w-full">
      {/* LEFT GRADIENT (decorativo, no bloquea eventos) */}
      <div className="absolute left-0 top-0 bottom-0 w-24 z-20 bg-gradient-to-r from-white to-transparent pointer-events-none" />

      {/* RIGHT GRADIENT */}
      <div className="absolute right-0 top-0 bottom-0 w-24 z-20 bg-gradient-to-l from-white to-transparent pointer-events-none" />

      {/* BOTÓN ANTERIOR */}
      <button
        onClick={prevSlide}
        className="absolute left-2 md:left-6 top-1/2 -translate-y-1/2 z-30 w-12 h-12 md:w-14 md:h-14 rounded-full bg-white/90 backdrop-blur-xl border border-pink-100 shadow-xl flex items-center justify-center hover:scale-110 hover:bg-pink-50 transition-all duration-300"
        aria-label="Anterior"
      >
        <ChevronLeft className="w-5 h-5 md:w-6 md:h-6 text-pink-600" />
      </button>

      {/* BOTÓN SIGUIENTE */}
      <button
        onClick={nextSlide}
        className="absolute right-2 md:right-6 top-1/2 -translate-y-1/2 z-30 w-12 h-12 md:w-14 md:h-14 rounded-full bg-white/90 backdrop-blur-xl border border-pink-100 shadow-xl flex items-center justify-center hover:scale-110 hover:bg-pink-50 transition-all duration-300"
        aria-label="Siguiente"
      >
        <ChevronRight className="w-5 h-5 md:w-6 md:h-6 text-pink-600" />
      </button>

      {/* TRACK DEL CARRUSEL */}
      <div className="overflow-hidden px-4 md:px-16">
        <motion.div
          className="flex"
          animate={{ x: `-${currentIndex * itemWidth}%` }}
          transition={{ type: "spring", stiffness: 120, damping: 18 }}
        >
          {products.map((product) => (
            <div
              key={product.id}
              style={{ minWidth: `${itemWidth}%` }}
              className="px-3 py-8 flex-shrink-0"
            >
              <ProductCard
                product={product}
                onSelect={() => onSelectProduct(product)}
              />
            </div>
          ))}
        </motion.div>
      </div>

      {/* INDICADORES (solo si hay más de una página) */}
      {maxIndex > 0 && (
        <div className="flex justify-center items-center gap-3 mt-8">
          {Array.from({ length: maxIndex + 1 }).map((_, index) => (
            <button
              key={index}
              onClick={() => goTo(index)}
              className={`transition-all duration-300 rounded-full ${
                index === currentIndex
                  ? "w-10 h-3 bg-pink-500"
                  : "w-3 h-3 bg-pink-200 hover:bg-pink-300"
              }`}
              aria-label={`Ir a slide ${index + 1}`}
            />
          ))}
        </div>
      )}
    </div>
  );
}
