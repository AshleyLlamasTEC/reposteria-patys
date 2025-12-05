import React, { useState, useEffect } from 'react';
import { Link } from '@inertiajs/react';
import {
    ShoppingCart,
    ShoppingBag,
    User,
    Search,
    Heart,
    Cake,
    Menu as MenuIcon,
    X
} from 'lucide-react';

const Navbar = () => {
    const [isScrolled, setIsScrolled] = useState(false);
    const [isSearchOpen, setIsSearchOpen] = useState(false);
    const [isCartOpen, setIsCartOpen] = useState(false);
    const [isUserMenuOpen, setIsUserMenuOpen] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 20);
        };

        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const navItems = [
        { name: 'Inicio', href: '/' },
        { name: 'Pasteles', href: '/cakes' },
        { name: 'Postres', href: '/desserts' },
        { name: 'Especiales', href: '/specials' },
        { name: 'Nosotros', href: '/about' },
        { name: 'Contacto', href: '/contact' }
    ];

    // Datos del carrito con imágenes
    const cartItems = [
        {
            id: 1,
            name: "Pastel de Chocolate",
            price: 380.00,
            quantity: 1,
            image: "/images/shop/pastel-chocolate.jpg",
            color: "bg-amber-800"
        },
        {
            id: 2,
            name: "Cupcakes x6",
            price: 180.00,
            quantity: 1,
            image: "/images/shop/cupcake.jpg",
            color: "bg-pink-300"
        }
    ];

    const total = cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    const closeAllMenus = () => {
        setIsSearchOpen(false);
        setIsCartOpen(false);
        setIsUserMenuOpen(false);
        setIsMobileMenuOpen(false);
    };

    return (
        <>
            <nav className={`
                fixed top-0 left-0 right-0 z-50 transition-all duration-300
                ${isScrolled
                    ? 'bg-white/95 backdrop-blur-md shadow-sm py-3'
                    : 'bg-white/90 backdrop-blur-sm py-4'
                }
                border-b border-pink-100
            `}>
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex items-center justify-between">
                        {/* Logo */}
                            <Link
                            href="/"
                            className="flex items-center space-x-3 hover:scale-105 transition-transform duration-200"
                            onClick={closeAllMenus}
                        >
                            {/* Logo como imagen */}
                            <img
                                src="/images/logo.jpg"
                                alt="Repostería Patty's"
                                className="w-12 h-12 object-contain"
                                onError={(e) => {
                                    // Fallback si la imagen no carga
                                    e.target.style.display = 'none';
                                    e.target.nextSibling.style.display = 'block';
                                }}
                            />
                            {/* Fallback con ícono */}
                            <Cake className="w-8 h-8 text-pink-500 hidden" />

                            <div className="flex flex-col">
                                <span className="text-xl font-bold text-gray-900 tracking-tight">
                                    Repostería
                                </span>
                                <span className="text-xs text-pink-500 font-medium tracking-wide">
                                    Patty's
                                </span>
                            </div>
                        </Link>

                        {/* Desktop Navigation */}
                        <div className="hidden md:flex items-center space-x-8">
                            {navItems.map((item) => (
                                <Link
                                    key={item.name}
                                    href={item.href}
                                    className="
                                        relative text-gray-700 hover:text-pink-500 font-medium
                                        px-3 py-2 rounded-lg transition-all duration-200
                                        hover:bg-pink-50
                                        after:absolute after:bottom-0 after:left-3 after:right-3
                                        after:h-0.5 after:bg-pink-500 after:scale-x-0
                                        after:transition-transform after:duration-200
                                        hover:after:scale-x-100
                                    "
                                    onClick={closeAllMenus}
                                >
                                    {item.name}
                                </Link>
                            ))}
                        </div>

                        {/* Actions */}
                        <div className="flex items-center space-x-2">
                            {/* Search */}
                            <button
                                onClick={() => setIsSearchOpen(true)}
                                className="
                                    p-2 rounded-lg text-gray-600 hover:text-pink-500
                                    hover:bg-pink-50 transition-all duration-200
                                    hover:scale-110
                                "
                            >
                                <Search className="w-5 h-5" />
                            </button>

                            {/* Favorites */}
                            <button className="
                                p-2 rounded-lg text-gray-600 hover:text-pink-500
                                hover:bg-pink-50 transition-all duration-200
                                hover:scale-110
                            ">
                                <Heart className="w-5 h-5" />
                            </button>

                            {/* Cart */}
                            <div className="relative">
                                <button
                                    onClick={() => setIsCartOpen(!isCartOpen)}
                                    className="
                                        relative p-2 rounded-lg text-gray-600 hover:text-pink-500
                                        hover:bg-pink-50 transition-all duration-200
                                        hover:scale-110
                                    "
                                >
                                    <ShoppingCart className="w-5 h-5" />
                                    <span className="
                                        absolute -top-1 -right-1 bg-pink-500 text-white
                                        text-xs w-5 h-5 rounded-full flex items-center justify-center
                                        font-semibold
                                    ">
                                        {cartItems.reduce((sum, item) => sum + item.quantity, 0)}
                                    </span>
                                </button>

                                {/* Cart Dropdown */}
                                {isCartOpen && (
                                    <div className="absolute right-0 top-12 z-50 bg-white rounded-xl shadow-2xl p-4 min-w-80 border border-gray-100">
                                        <h3 className="text-lg font-semibold text-gray-900 mb-3">Tu Carrito</h3>

                                                {/* Lista de productos */}
                                                <div className="space-y-3 max-h-60 overflow-y-auto">
                                                    {cartItems.map((item) => (
                                                        <div key={item.id} className="flex items-center space-x-3 p-2 rounded-lg hover:bg-pink-50 cursor-pointer transition-colors">
                                                            {/* CORREGIDO: Usar etiqueta img para mostrar la imagen */}
                                                            <div className="flex-shrink-0 w-12 h-12 rounded-full overflow-hidden bg-gray-100 flex items-center justify-center shadow-md">
                                                                <img
                                                                    src={item.image}
                                                                    alt={item.name}
                                                                    className="w-full h-full object-cover"
                                                                    onError={(e) => {
                                                                        // Fallback si la imagen no carga
                                                                        e.target.style.display = 'none';
                                                                        e.target.parentElement.classList.add(item.color);
                                                                        e.target.parentElement.innerHTML = `
                                                                            <div class="w-full h-full flex items-center justify-center text-white text-lg">
                                                                                🎂
                                                                            </div>
                                                                        `;
                                                                    }}
                                                                />
                                                            </div>

                                                            {/* Información del producto */}
                                                            <div className="flex-1 min-w-0">
                                                                <div className="flex justify-between items-start">
                                                                    <span className="text-sm font-medium text-gray-700 truncate">
                                                                        {item.name}
                                                                    </span>
                                                                    <span className="text-sm font-semibold text-pink-600 ml-2">
                                                                        ${item.price.toFixed(2)}
                                                                    </span>
                                                                </div>
                                                                <div className="flex justify-between items-center mt-1">
                                                                    <span className="text-xs text-gray-500">
                                                                        Cantidad: {item.quantity}
                                                                    </span>
                                                                    <span className="text-xs font-semibold text-gray-600">
                                                                        ${(item.price * item.quantity).toFixed(2)}
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    ))}
                                                </div>

                                        {/* Línea separadora */}
                                        <div className="h-px bg-gray-100 my-3" />

                                        {/* Total */}
                                        <div className="flex justify-between items-center mb-4">
                                            <span className="text-sm font-semibold text-gray-900">Total:</span>
                                            <span className="text-lg font-bold text-pink-600">${total.toFixed(2)}</span>
                                        </div>

                                        {/* Botones */}
                                        <div className="flex justify-center space-x-2">
                                            <Link
                                                href="/cart"
                                                className="
                                                    flex items-center justify-center gap-2
                                                    bg-pink-500 text-white py-2 px-4
                                                    rounded-lg font-semibold hover:bg-pink-600
                                                    transition-colors duration-200 text-sm
                                                "
                                                onClick={closeAllMenus}
                                            >
                                                <ShoppingCart className="w-5 h-5" />
                                                Ver Carrito
                                            </Link>

                                            <button
                                                className="
                                                    flex items-center justify-center gap-2
                                                    bg-gray-800 text-white py-2 px-4
                                                    rounded-lg font-semibold hover:bg-gray-900
                                                    transition-colors duration-200 text-sm
                                                "
                                            >
                                                <ShoppingBag className="w-5 h-5" />
                                                Comprar
                                            </button>
                                        </div>

                                    </div>
                                )}
                            </div>

                            {/* User Menu */}
                            <div className="relative">
                                <button
                                    onClick={() => setIsUserMenuOpen(!isUserMenuOpen)}
                                    className="
                                        p-2 rounded-lg text-gray-600 hover:text-pink-500
                                        hover:bg-pink-50 transition-all duration-200
                                        hover:scale-110
                                    "
                                >
                                    <User className="w-5 h-5" />
                                </button>

                                {/* User Dropdown */}
                                {isUserMenuOpen && (
                                    <div className="absolute right-0 top-12 z-50 bg-white rounded-xl shadow-2xl p-2 min-w-48 border border-gray-100">
                                        <div className="flex items-center space-x-3 p-3 rounded-lg hover:bg-pink-50 cursor-pointer transition-colors">
                                            <User className="w-4 h-4" />
                                            <span className="text-sm text-gray-700">Mi Cuenta</span>
                                        </div>
                                        <div className="p-3 rounded-lg hover:bg-pink-50 cursor-pointer transition-colors text-sm text-gray-700">
                                            <Link href="/orders" onClick={closeAllMenus}>Mis Pedidos</Link>
                                        </div>
                                        <div className="p-3 rounded-lg hover:bg-pink-50 cursor-pointer transition-colors text-sm text-gray-700">
                                            <Link href="/favorites" onClick={closeAllMenus}>Favoritos</Link>
                                        </div>
                                        <div className="h-px bg-gray-100 my-2" />
                                        <div className="p-3 rounded-lg hover:bg-pink-50 cursor-pointer transition-colors text-sm text-gray-700">
                                            <Link href="/login" onClick={closeAllMenus}>Iniciar Sesión</Link>
                                        </div>
                                    </div>
                                )}
                            </div>

                            {/* Mobile Menu Button */}
                            <div className="md:hidden relative">
                                <button
                                    onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                                    className="
                                        p-2 rounded-lg text-gray-600 hover:text-pink-500
                                        hover:bg-pink-50 transition-all duration-200
                                    "
                                >
                                    <MenuIcon className="w-6 h-6" />
                                </button>

                                {/* Mobile Menu Dropdown */}
                                {isMobileMenuOpen && (
                                    <div className="fixed top-16 right-4 z-50 bg-white rounded-xl shadow-2xl p-2 min-w-48 border border-gray-100">
                                        {navItems.map((item) => (
                                            <div key={item.name} className="p-1">
                                                <Link
                                                    href={item.href}
                                                    className="
                                                        block px-4 py-3 rounded-lg text-gray-700
                                                        hover:bg-pink-50 hover:text-pink-500
                                                        transition-colors duration-200 text-sm font-medium
                                                    "
                                                    onClick={closeAllMenus}
                                                >
                                                    {item.name}
                                                </Link>
                                            </div>
                                        ))}
                                        <div className="h-px bg-gray-100 my-2" />
                                        <div className="p-1">
                                            <Link
                                                href="/login"
                                                className="
                                                    w-full text-left px-4 py-3 rounded-lg text-gray-700
                                                    hover:bg-pink-50 hover:text-pink-500
                                                    transition-colors duration-200 text-sm font-medium block
                                                "
                                                onClick={closeAllMenus}
                                            >
                                                Iniciar Sesión
                                            </Link>
                                        </div>
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            </nav>

            {/* Spacer para el contenido */}
            <div className={`${isScrolled ? 'h-20' : 'h-24'} transition-all duration-300`} />

            {/* Search Modal - Este cubrirá toda la página */}
            {isSearchOpen && (
                <div className="fixed inset-0 z-50">
                    {/* Backdrop que cubre toda la página */}
                    <div
                        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
                        onClick={() => setIsSearchOpen(false)}
                    />

                    {/* Contenido del modal */}
                    <div className="absolute inset-0 flex items-start justify-center pt-32">
                        <div className="bg-white rounded-xl shadow-2xl w-full max-w-md mx-4 border border-gray-100">
                            <div className="flex items-center p-6">
                                <Search className="w-6 h-6 text-gray-400 mr-3" />
                                <input
                                    type="text"
                                    placeholder="Buscar pasteles, postres..."
                                    className="flex-1 outline-none text-lg placeholder-gray-400 rounded-lg border-2 border-pink-500"
                                    autoFocus
                                />
                                <button
                                    onClick={() => setIsSearchOpen(false)}
                                    className="p-1 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors ml-3"
                                >
                                    <X className="w-5 h-5" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Overlay para cerrar menús al hacer clic fuera */}
            {(isCartOpen || isUserMenuOpen || isMobileMenuOpen) && (
                <div
                    className="fixed inset-0 z-40"
                    onClick={closeAllMenus}
                />
            )}
        </>
    );
};

export default Navbar;
