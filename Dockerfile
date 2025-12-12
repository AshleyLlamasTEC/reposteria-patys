# Dockerfile CORREGIDO - Con libzip-dev para extensión zip
FROM php:8.2-apache
WORKDIR /var/www/html

COPY . .

# Instala TODAS las dependencias necesarias (incluyendo libzip-dev)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    libzip-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring gd zip \
    && a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data /var/www/html
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/*.conf

CMD ["apache2-foreground"]
