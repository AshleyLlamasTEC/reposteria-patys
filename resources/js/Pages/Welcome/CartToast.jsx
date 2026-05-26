import { motion, AnimatePresence } from "framer-motion";
import { CheckCircle, X } from "lucide-react";

export default function CartToast({ message, onClose }) {
  if (!message) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, x: 100 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: 100 }}
        className="fixed bottom-6 right-6 z-50 bg-white shadow-xl rounded-2xl p-4 flex items-center gap-3 border border-gray-100 max-w-sm"
      >
        <CheckCircle className="w-6 h-6 text-green-500" />
        <p className="text-gray-800 text-sm font-medium">{message}</p>
        <button onClick={onClose} className="ml-auto text-gray-400 hover:text-gray-600">
          <X className="w-4 h-4" />
        </button>
      </motion.div>
    </AnimatePresence>
  );
}
