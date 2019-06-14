FROM php:7.3-fpm

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

RUN apt-get update && apt-get install -y libpq-dev zip unzip libzip-dev libpq-dev gnupg2 build-essential \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install zip opcache pgsql pdo_pgsql bcmath \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# The defaults in this opcache.ini are for a generic prod setup
# and can be changed in a dev project's docker-compose file to
# better fit a dev environment
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

EXPOSE 9000