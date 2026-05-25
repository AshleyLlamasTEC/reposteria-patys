<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Support\Facades\Auth;

class CartController extends Controller
{
    /**
     * Muestra el carrito del usuario autenticado.
     * Retorna los items formateados y el total.
     */
    public function index()
    {
        $cart = $this->getOrCreateCart();

        $items = $cart->items()->with('product')->get()->map(function ($item) {
            return [
                'id'       => $item->id,
                'name'     => $item->product->name,
                'image'    => $item->product->image,
                'category' => $item->product->category,
                'price'    => $item->product->price, // precio unitario
                'quantity' => $item->quantity,
            ];
        });

        // El total se puede recalcular desde el backend o utilizar el almacenado
        $cartTotal = $cart->total;

        return Inertia::render('Cart/Index', [
            'items'     => $items,
            'cartTotal' => $cartTotal,
        ]);
    }

    /**
     * Agrega un producto al carrito.
     * (Invocable desde una llamada AJAX o al hacer clic en "Agregar al carrito")
     */
    public function addItem(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity'   => 'required|integer|min:1',
        ]);

        $cart = $this->getOrCreateCart();
        $product = Product::findOrFail($request->product_id);

        // Validar stock disponible
        if ($product->stock < $request->quantity) {
            return back()->withErrors(['quantity' => 'Stock insuficiente.']);
        }

        // Verificar si el producto ya está en el carrito
        $existingItem = $cart->items()->where('product_id', $product->id)->first();

        if ($existingItem) {
            // Actualizar cantidad evitando duplicados
            $existingItem->quantity += $request->quantity;
            $existingItem->save();
        } else {
            CartItem::create([
                'cart_id'    => $cart->id,
                'product_id' => $product->id,
                'quantity'   => $request->quantity,
                'unit_price' => $product->price,
            ]);
        }

        // Recalcular el total del carrito
        $this->recalculateTotal($cart);

        return redirect()->route('cart.index')->with('success', 'Producto agregado al carrito.');
    }

    /**
     * Actualiza la cantidad de un ítem del carrito.
     */
    public function updateItem(Request $request, $itemId)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $cart = $this->getCurrentCart();
        $item = $cart->items()->findOrFail($itemId);

        // Validar que la nueva cantidad no supere el stock
        if ($item->product->stock < $request->quantity) {
            return back()->withErrors(['quantity' => 'No hay suficiente stock para esa cantidad.']);
        }

        $item->quantity = $request->quantity;
        $item->save();

        $this->recalculateTotal($cart);

        return redirect()->route('cart.index')->with('success', 'Cantidad actualizada.');
    }

    /**
     * Elimina un ítem del carrito.
     */
    public function removeItem($itemId)
    {
        $cart = $this->getCurrentCart();
        $item = $cart->items()->findOrFail($itemId);
        $item->delete();

        $this->recalculateTotal($cart);

        return redirect()->route('cart.index')->with('success', 'Producto eliminado del carrito.');
    }

    /**
     * Vacía completamente el carrito.
     */
    public function clear()
    {
        $cart = $this->getCurrentCart();
        $cart->items()->delete();

        $cart->update([
            'total' => 0.00,
            'status' => 'active', // opcional, mantiene el carrito activo
        ]);

        return redirect()->route('cart.index')->with('success', 'Carrito vaciado.');
    }

    /**
     * Aplica un cupón de descuento (lógica de ejemplo).
     * Puedes expandirlo según tu tabla de cupones.
     */
    public function applyCoupon(Request $request)
    {
        $request->validate([
            'code' => 'required|string|max:50',
        ]);

        $cart = $this->getCurrentCart();

        // Lógica de descuento: aquí deberías consultar tu modelo Cupon
        if ($request->code === 'PATY10') {
            $discount = $cart->total * 0.10;
            // Guardar el descuento aplicado (podrías almacenarlo en sesión o en una tabla)
            session(['coupon_discount' => $discount, 'coupon_code' => $request->code]);

            return back()->with('coupon_success', "Cupón aplicado. Descuento de $discount.");
        }

        return back()->withErrors(['code' => 'Cupón inválido o expirado.']);
    }

    // ─── Métodos auxiliares ──────────────────────────────────────────────────

    /**
     * Obtiene el carrito activo del usuario o crea uno nuevo.
     */
    private function getOrCreateCart(): Cart
    {
        $user = Auth::user();
        $cart = Cart::firstOrCreate(
            ['user_id' => $user->id, 'status' => 'active'],
            ['total' => 0.00]
        );
        return $cart;
    }

    /**
     * Obtiene el carrito activo actual (lanza error si no existe).
     */
    private function getCurrentCart(): Cart
    {
        $user = Auth::user();
        $cart = Cart::where('user_id', $user->id)
                    ->where('status', 'active')
                    ->first();

        if (!$cart) {
            abort(404, 'No tienes un carrito activo.');
        }
        return $cart;
    }

    /**
     * Recalcula el total del carrito sumando los ítems.
     */
    private function recalculateTotal(Cart $cart): void
    {
        $total = $cart->items->sum(function ($item) {
            return $item->quantity * $item->unit_price;
        });

        $cart->update([
            'total' => $total,
        ]);
    }
}
