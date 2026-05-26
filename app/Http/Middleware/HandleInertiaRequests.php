<?php

namespace App\Http\Middleware;

use App\Models\Cart;
use Illuminate\Http\Request;
use Inertia\Middleware;
use Tightenco\Ziggy\Ziggy;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that is loaded on the first page visit.
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determine the current asset version.
     */
    public function version(Request $request): string|null
    {
        return parent::version($request);
    }

    /**
     * Define the props that are shared by default.
     *
     * @return array<string, mixed>
     */
    // public function share(Request $request): array
    // {
    //     return array_merge(parent::share($request), [
    //         'auth' => [
    //             'user' => $request->user(),
    //         ],
    //         'ziggy' => function () use ($request) {
    //             return array_merge((new Ziggy)->toArray(), [
    //                 'location' => $request->url(),
    //             ]);
    //         },
    //     ]);
    // }

    // En App\Http\Middleware\HandleInertiaRequests
    public function share(Request $request): array
    {
        $cart = null;
        if ($user = $request->user()) {
            $cart = Cart::where('user_id', $user->id)
                ->where('status', 'active')
                ->with('items.product')
                ->first();

            if ($cart) {
                $cart = [
                    'items' => $cart->items->map(fn($item) => [
                        'id'       => $item->id,
                        'name'     => $item->product->name,
                        'price'    => $item->unit_price,
                        'quantity' => $item->quantity,
                        'image'    => $item->product->image_url ?? null,
                    ]),
                    'total' => $cart->total_amount,
                ];
            }
        }

        return array_merge(parent::share($request), [
            'auth' => fn() => $request->user()?->only('id', 'name', 'email', 'avatar'),
            'cart' => $cart,
        ]);
    }
}
