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

# 4. Copia TODO tu código al contenedor
COPY . .

# 5. Asegurar permisos base para que Composer funcione
RUN chown -R www-data:www-data /var/www/html

# 6. Instala las dependencias de PHP (sin paquetes de desarrollo)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 7. Configura permisos específicos para carpetas de Laravel
RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

# 8. CONFIGURACIÓN APACHE MÁS DIRECTA Y SEGURA
# 8.1 Establece ServerName
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# 8.2 Crea una NUEVA configuración de Apache desde cero
RUN echo '<VirtualHost *:80>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html/public\n\
    \n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
        Options -Indexes +FollowSymLinks\n\
        DirectoryIndex index.php index.html\n\
    </Directory>\n\
    \n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# 8.3 Habilita el sitio
RUN a2ensite 000-default.conf

# 8.4 Deshabilita configuraciones por defecto conflictivas
RUN a2dissite 000-default.conf 2>/dev/null || true
RUN a2ensite 000-default.conf

# 9. Comando para iniciar Apache (el servidor web)
CMD ["apache2-foreground"]
