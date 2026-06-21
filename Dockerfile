FROM php:8.2-apache

WORKDIR /var/www/html

COPY . .

# Install dependencies + PostgreSQL driver
RUN apt-get update && apt-get install -y \
    unzip zip curl libpng-dev libonig-dev libxml2-dev libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# Enable Apache rewrite
RUN a2enmod rewrite

# Set Laravel public folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf \
 && sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf

# Allow .htaccess
RUN echo "<Directory /var/www/html/public>\n\
    AllowOverride All\n\
</Directory>" >> /etc/apache2/apache2.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Permissions (important for Laravel)
RUN chmod -R 777 storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache

EXPOSE 80