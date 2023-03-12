FROM php:8.0-cli-alpine
#FROM composer:2

ENV COMPOSERUSER=laravel
ENV COMPOSERGROUP=laravel

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

#RUN apt-get update && apt-get install -y libzip-dev libpng-dev libcurl4-openssl-dev libmcrypt-dev libxml2-dev libxslt-dev
#RUN docker-php-ext-install curl json zip gd bcmath mbstring mcrypt pdo pdo_mysql xml xsl


RUN adduser -g ${COMPOSERGROUP} -s /bin/sh/ -D ${COMPOSERUSER}
#RUN addgroup ${COMPOSERGROUP}
#RUN adduser --ingroup ${COMPOSERGROUP} --shell /bin/sh --disabled-password ${COMPOSERUSER}

RUN docker-php-ext-install pdo pdo_mysql

# Configure Xdebug
RUN echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=develop,coverage,gcstats" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.log=/var/www/html/xdebug.log" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Set to composer version 1, remove this when passed to version 2
RUN /usr/local/bin/composer self-update --1

#CMD ["/usr/local/bin/composer"]
ENTRYPOINT ["php", "artisan"]
