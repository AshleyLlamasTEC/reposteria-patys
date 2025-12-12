# Usa PHP 8.2 con Apache
FROM php:8.2-apache

# 1. Establece el directorio de trabajo
WORKDIR /var/www/html

# 2. Instala Node.js 18 PRIMERO (antes de PHP para mejor caché)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && apt-get install -y \
    nodejs \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev

# 3. Instala extensiones de PHP
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd && \
    a2enmod rewrite

# 4. Copia e instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Copia SOLO los archivos de configuración primero (para mejor caché)
COPY composer.json composer.lock package.json package-lock.json* ./

# 6. Instala dependencias de PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 7. Instala dependencias de Node.js (SIN dev dependencies)
RUN npm ci --omit=dev

# 8. Copia TODO el resto del código
COPY . .

# 9. Asegurar permisos base
RUN chown -R www-data:www-data /var/www/html

# 10. COMPILA REACT/Vite (corregido)
RUN npm run build

# 11. Configura permisos específicos para carpetas de Laravel
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# 12. CONFIGURACIÓN APACHE
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www/html/public' >> /etc/apache2/sites-available/000-default.conf && \
    echo '' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html/public>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Options -Indexes +FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        DirectoryIndex index.php index.html' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# 13. Habilita el sitio
RUN a2ensite 000-default.conf

# 14. Comando para iniciar Apache
CMD ["apache2-foreground"]
