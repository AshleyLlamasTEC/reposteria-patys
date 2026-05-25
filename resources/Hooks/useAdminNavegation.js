import { useMemo } from 'react';
import { usePage } from '@inertiajs/react';
import { navigationConfig } from '@/Utils/admin.navigation';

export function useAdminNavigation() {
  const { url, component } = usePage();

  const breadcrumbs = useMemo(() => {
    // Lógica simple: se puede expandir con navegación anidada
    const currentItem = navigationConfig.find(item => 
      url.startsWith(item.href) || (item.pattern && new RegExp(item.pattern).test(url))
    );
    return currentItem ? [currentItem] : [];
  }, [url]);

  const activeRoute = breadcrumbs.length > 0 ? breadcrumbs[breadcrumbs.length - 1].name : 'Dashboard';

  return { breadcrumbs, activeRoute };
}