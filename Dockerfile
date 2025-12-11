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

# 5. Instala las dependencias de PHP (sin paquetes de desarrollo)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 6. Configura permisos para carpetas de Laravel
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# 7. Expone el puerto 80
EXPOSE 80

# 8. Comando para iniciar Apache (el servidor web)
CMD ["apache2-foreground"]
