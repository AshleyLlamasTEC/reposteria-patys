<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use App\Models\Cart;
use App\Models\CartItem;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CartController extends Controller
{
    /**
     * Muestra el carrito activo del usuario.
     * Retorna un DTO normalizado para React.
     */
    public function index()
    {
        $cart = $this->getOrCreateCart();

        $items = $cart->items()->with('product.category')->get()->map(function ($item) {
            return [
                'id'         => $item->id,
                'name'       => $item->product->name,
                'image'      => $item->product->image_url ?? null,
                'category'   => $item->product->category?->name,
                'unit_price' => (float) $item->unit_price,
                'quantity'   => (int) $item->quantity,
                'subtotal'   => (float) $item->subtotal,
            ];
        });

        return Inertia::render('Cart/Index', [
            'items'     => $items,
            'cartTotal' => (float) $cart->total_amount,
        ]);
    }

    /**
     * Agrega un producto usando el stored procedure sp_add_to_cart.
     */
    public function addItem(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity'   => 'required|integer|min:1',
        ]);

        try {
            DB::statement('CALL sp_add_to_cart(?, ?, ?)', [
                Auth::id(),
                $request->product_id,
                $request->quantity,
            ]);

            return redirect()->route('cart.index')
                ->with('success', 'Producto agregado al carrito.');
        } catch (\Exception $e) {
            Log::error('Error al agregar producto al carrito: ' . $e->getMessage());
            return back()->withErrors(['error' => 'No se pudo agregar el producto. Inténtalo de nuevo.']);
        }
    }

    /**
     * Actualiza la cantidad de un ítem y recalcula el total mediante función SQL.
     */
    public function updateItem(Request $request, $itemId)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $cart = $this->getCurrentCart();
        $item = $cart->items()->findOrFail($itemId);

        // Validar stock usando la función SQL
        $stockResult = DB::select(
            'SELECT fn_product_stock_available(?, ?) AS available',
            [$item->product_id, $request->quantity]
        );

        if (!$stockResult[0]->available) {
            return back()->withErrors(['quantity' => 'No hay suficiente stock para esa cantidad.']);
        }

        $item->quantity = $request->quantity;
        $item->subtotal = $request->quantity * $item->unit_price;
        $item->save();

        // Recalcular total del carrito con función SQL
        $totalResult = DB::select('SELECT fn_calculate_cart_total(?) AS total_amount', [$cart->id]);
        $cart->update(['total_amount' => $totalResult[0]->total_amount]);

        return redirect()->route('cart.index')
            ->with('success', 'Cantidad actualizada.');
    }

    /**
     * Elimina un ítem usando el stored procedure sp_remove_from_cart.
     */
    public function removeItem($itemId)
    {
        $cart = $this->getCurrentCart();

        $item = $cart->items()->where('id', $itemId)->first();
        if (!$item) {
            abort(404, 'El ítem no pertenece a tu carrito.');
        }

        try {
            DB::statement('CALL sp_remove_from_cart(?)', [$itemId]);
            return redirect()->route('cart.index')
                ->with('success', 'Producto eliminado del carrito.');
        } catch (\Exception $e) {
            Log::error('Error al eliminar ítem del carrito: ' . $e->getMessage());
            return back()->withErrors(['error' => 'No se pudo eliminar el producto.']);
        }
    }

    /**
     * Vacía el carrito usando el stored procedure sp_clear_cart.
     */
    public function clear()
    {
        $cart = $this->getCurrentCart();

        DB::statement('CALL sp_clear_cart(?)', [$cart->id]);

        return redirect()->route('cart.index')
            ->with('success', 'Carrito vaciado.');
    }

    /**
     * Aplica un cupón de descuento (ejemplo).
     */
    public function applyCoupon(Request $request)
    {
        $request->validate([
            'code' => 'required|string|max:50',
        ]);

        $cart = $this->getCurrentCart();

        if ($request->code === 'PATY10') {
            $discount = $cart->total_amount * 0.10;
            session(['coupon_discount' => $discount, 'coupon_code' => $request->code]);

            return back()->with('coupon_success', "Cupón aplicado. Descuento de $" . number_format($discount, 2) . ".");
        }

        return back()->withErrors(['code' => 'Cupón inválido o expirado.']);
    }

    // ─── Métodos auxiliares ──────────────────────────────────────────────────

    private function getOrCreateCart(): Cart
    {
        $user = Auth::user();
        return Cart::firstOrCreate(
            ['user_id' => $user->id, 'status' => 'active'],
            ['total_amount' => 0.00]
        );
    }

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
}
