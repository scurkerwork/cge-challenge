FROM php:8.0-fpm-alpine
#FROM php:7.1-fpm

ENV PHP_UPLOAD_LIMIT=20M
ENV PHPGROUP=laravel
ENV PHPUSER=laravel

RUN apk add --update libzip-dev curl curl-dev libpng-dev libmcrypt-dev libxml2-dev  libxslt-dev python3 py3-pip python3-dev libsodium php8-pecl-imagick imagemagick-dev autoconf libtool gcc g++ make libffi-dev
RUN (yes | pecl install imagick)
#RUN docker-php-ext-enable imagick
#RUN docker-php-ext-install curl json zip gd bcmath mbstring pdo pdo_mysql xml xsl
RUN docker-php-ext-install mysqli
RUN python3 -m pip install --upgrade pip
RUN pip3 install pynacl
RUN apk del autoconf libtool gcc g++ make python3-dev libffi-dev

# Add xdebug
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS
RUN apk add --update linux-headers
RUN pecl install xdebug-3.1.5
RUN docker-php-ext-enable xdebug
RUN apk del -f .build-deps

RUN adduser -g ${PHPGROUP} -s /bin/sh -D ${PHPUSER}
#RUN addgroup ${PHPGROUP}
#RUN adduser --ingroup ${PHPGROUP} --shell /bin/sh --disabled-password ${PHPUSER}
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN sed -i "s/upload_max_filesize = .*$/upload_max_filesize = ${PHP_UPLOAD_LIMIT}/g" $PHP_INI_DIR/php.ini
RUN sed -i "s/user = www-data/user = ${PHPUSER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/user = ${PHPUSER}/g" /usr/local/etc/php-fpm.d/www.conf
RUN mkdir -p /var/www/html/public
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-install pdo pdo_mysql

# Configure Xdebug
RUN echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=develop,coverage,gcstats" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.log=/var/www/html/xdebug.log" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini

#CMD ["/usr/local/bin/docker-php-entrypoint", "-y", "/usr/local/etc/php-fpm.conf", "-R", "-F"]
#CMD ["/usr/local/bin/entrypoint.sh","php-fpm","-F"]
