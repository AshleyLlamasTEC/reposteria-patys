import React, { createContext, useContext, useState, useEffect } from 'react';

const AdminContext = createContext(null);

export function AdminProvider({ children }) {
    const [isAdmin, setIsAdmin] = useState(false);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Verificar si el usuario es admin
        // Puedes obtenerlo de las props de Inertia o de un endpoint
        const checkAdminStatus = async () => {
            try {
                // Ejemplo: verificar desde una variable global o props
                const isUserAdmin = false; // Cambia esto según tu lógica
                setIsAdmin(isUserAdmin);
            } catch (error) {
                console.error('Error checking admin status:', error);
                setIsAdmin(false);
            } finally {
                setLoading(false);
            }
        };

        checkAdminStatus();
    }, []);

    return (
        <AdminContext.Provider value={{ isAdmin, loading }}>
            {children}
        </AdminContext.Provider>
    );
}

export function useAdmin() {
    const context = useContext(AdminContext);
    if (!context) {
        throw new Error('useAdmin must be used within an AdminProvider');
    }
    return context;
}

export default AdminProvider;