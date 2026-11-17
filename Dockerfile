FROM node:22.21.1-alpine3.22@sha256:b2358485e3e33bc3a33114d2b1bdb18cdbe4df01bd2b257198eb51beb1f026c5 AS frontend-build
WORKDIR /build/frontend
COPY frontend/package*.json ./
RUN npm ci --legacy-peer-deps
COPY frontend/ ./
RUN npm run build

FROM composer:2.11.2@sha256:5bcb28b8d0edc4091125f8218f9d088f998bdfc843f8fbb9a4beb4dcd8625684 AS composer-bin

FROM php:8.5.12-fpm-alpine3.23@sha256:619ba0e2ca1c5debd940479226bd419e9db0931154d2b002fdc94e28fa341c55 AS php-base
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && docker-php-ext-install pdo_mysql \
    && apk del .build-deps
COPY docker/php.ini /usr/local/etc/php/conf.d/zz-ensibuuko.ini
WORKDIR /var/www/html

FROM php-base AS backend-build
COPY --from=composer-bin /usr/bin/composer /usr/local/bin/composer
COPY app/ ./
RUN composer install --no-dev --no-interaction --no-progress --prefer-dist --optimize-autoloader \
    && rm -rf tests .phpunit.cache

FROM php-base AS api
COPY --from=backend-build --chown=www-data:www-data /var/www/html /var/www/html
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache
USER www-data
EXPOSE 9000
CMD ["php-fpm", "-F"]

FROM nginx:1.28.0-alpine3.21@sha256:30f1c0d78e0ad60901648be663a710bdadf19e4c10ac6782c235200619158284 AS web
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=frontend-build /build/frontend/dist /usr/share/nginx/html
EXPOSE 8080
