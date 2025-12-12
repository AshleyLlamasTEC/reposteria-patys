# Usa PHP 8.2 con Apache
FROM php:8.2-apache

# 1. Establece el directorio de trabajo
WORKDIR /var/www/html

# 2. Instala dependencias del sistema, Composer y extensiones de PHP
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd \
    && a2enmod rewrite

# 3. Copia e instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Copia todo tu código al contenedor
COPY . .

# 5. Asegurar permisos base para que Composer funcione
RUN chown -R www-data:www-data /var/www/html

# 6. Instala las dependencias de PHP (sin paquetes de desarrollo)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 7. Configura permisos específicos para carpetas de Laravel
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# 8. CONFIGURACIÓN CRÍTICA - Apache debe apuntar a /public
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf && \
    sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 9. Comando para iniciar Apache (el servidor web)
CMD ["apache2-foreground"]
