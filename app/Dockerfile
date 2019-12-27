FROM php:7.2-fpm-alpine

LABEL maintainer="Aldo Okware"

RUN apk add --no-cache $PHPIZE_DEPS && \
    pecl install xdebug && docker-php-ext-enable xdebug && \
    docker-php-ext-install pdo pdo_mysql

COPY . ./

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN composer install

VOLUME /app
