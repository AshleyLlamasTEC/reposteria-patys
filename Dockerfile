# Dockerfile CORREGIDO - Sintaxis correcta para apt-get
FROM php:8.2-apache
WORKDIR /var/www/html

# 1. Copia TODO
COPY . .

# 2. Instala dependencias del sistema (UNA sola línea RUN)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring gd zip \
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
