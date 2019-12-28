FROM php:7.2-fpm

LABEL maintainer="Aldo Okware"

RUN apt-get update && apt-get install -y \
    zip \
    unzip \
    git \
    curl

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl

COPY . ./

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN composer update

VOLUME /app
