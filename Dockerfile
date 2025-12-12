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

# 8. CONFIGURACIÓN APACHE CORREGIDA (sin \n\)
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Crea la configuración de Apache CORRECTAMENTE
RUN echo '<VirtualHost *:80>' > /etc/apache2/sites-available/000-default.conf && \
    echo '    ServerAdmin webmaster@localhost' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    DocumentRoot /var/www/html/public' >> /etc/apache2/sites-available/000-default.conf && \
    echo '' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    <Directory /var/www/html/public>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        Options -Indexes +FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf && \
    echo '        DirectoryIndex index.php index.html' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# 9. Habilita el sitio
RUN a2ensite 000-default.conf

# 10. Comando para iniciar Apache (el servidor web)
CMD ["apache2-foreground"]
