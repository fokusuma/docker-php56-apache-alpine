FROM php:5-fpm-alpine

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/bin/composer

RUN apk add --update nano postgresql-dev freetype-dev libmcrypt-dev libjpeg-turbo-dev libpng-dev zlib-dev apache2-proxy

RUN docker-php-ext-install iconv mcrypt pdo pgsql pdo_pgsql opcache zip

RUN sed -i -r 's/(LoadModule.*mod_mpm_prefork.so)/#\1/' /etc/apache2/httpd.conf
RUN sed -i -r 's/#(LoadModule.*mod_mpm_event.so)/\1/' /etc/apache2/httpd.conf
RUN sed -i -r 's/#(LoadModule.*mod_rewrite.so)/\1/' /etc/apache2/httpd.conf

COPY ./artifacts/www.conf /etc/apache2/conf.d/www.conf

COPY ./CRM /var/www/html/CRM
RUN chown -R www-data:www-data /var/www/html/CRM

EXPOSE 80

RUN mkdir /run/apache2

ENTRYPOINT httpd && php-fpm -F