# Dockerfile CORRECTO - React YA está compilado en public/build/
FROM php:8.2-apache
WORKDIR /var/www/html

# 1. Copia TODO (incluyendo public/build/ compilado)
COPY . .

# 2. Instala SOLO PHP (NO Node.js - React YA compilado)
RUN apt-get update && apt-get install -y \
    libpng-dev libonig-dev libxml2-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring gd \
    && a2enmod rewrite

# 3. Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Dependencias PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 5. Permisos básicos
RUN chown -R www-data:www-data /var/www/html

# 6. Configura Apache MÍNIMA
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/*.conf

# 7. Inicia Apache
CMD ["apache2-foreground"]
