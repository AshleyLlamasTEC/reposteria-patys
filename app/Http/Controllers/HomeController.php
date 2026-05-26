<?php

namespace App\Http\Controllers;

use Inertia\Inertia;
use App\Models\Product;

class HomeController extends Controller
{
    public function index()
    {
        $featuredProducts = Product::query()
            ->with('category:id,name')
            ->where('popular', true)
            ->where('active', true)
            ->where('stock', '>', 0)
            ->select([
                'id',
                'name',
                'base_price',
                'image_url',
                'description',
                'stock',
                'rating',
                'popular',
                'category_id',
            ])
            ->limit(6)
            ->get()
            ->map(function ($product) {
                return [
                    'id' => $product->id,
                    'name' => $product->name,
                    'base_price' => (float) $product->base_price,
                    'image_url' => $product->image_url,
                    'description' => $product->description,
                    'stock' => (int) $product->stock,
                    'rating' => (float) ($product->rating ?? 4.5),
                    'popular' => (bool) $product->popular,
                    'category' => $product->category?->name,
                ];
            });

        return Inertia::render('Welcome/Index', [
            'featuredProducts' => $featuredProducts,
        ]);
    }
}
