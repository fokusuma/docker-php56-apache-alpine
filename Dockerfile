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

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 20M/" /usr/local/etc/php/php.ini
RUN sed -i "s/post_max_size = .*/post_max_size = 20M/" /usr/local/etc/php/php.ini

RUN echo "php_admin_value[date.timezone] = \"Asia/Makassar\"">>/usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_value[display_errors] = On">>/usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_value[error_reporting] = E_ALL & ~E_DEPRECATED">>/usr/local/etc/php-fpm.d/www.conf

COPY ./CRM /var/www/html/CRM
RUN chown -R www-data:www-data /var/www/html/CRM/application/cache/session

EXPOSE 80
EXPOSE 8989

RUN mkdir /run/apache2

ENTRYPOINT ["sh", "-c", "httpd && nohup php /var/www/html/CRM/index.php RatchetServer & php-fpm -F"]