FROM php:8.1-fpm

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive

# Default PHP Extensions
# libxrender1 & libfontconfig - for pdf
RUN apt-get clean; \
  rm -rf /var/lib/apt/lists/*; \
  apt-get clean; \
  apt-get update --fix-missing; \
  apt-get upgrade -y; \
  apt-get install -y \
    apt \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    dirmngr \
    git \
    gnupg2 \
    inetutils-ping \
    libc-client-dev \
    libicu-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libonig-dev \
    libpq-dev \
    libxslt-dev \
    libzip-dev \
    lsb-release \
    make \
    unzip \
    wget \
    supervisor \
    libxrender1 \
    libfontconfig \
    zip; \
  rm -rf /var/lib/apt/lists/*

# Development php.ini
RUN if [ ${DEVELOP} = true ]; then \
        mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"; \
    else \
        mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"; \
    fi

# Zip
RUN docker-php-ext-install zip; \
    rm -rf /var/lib/apt/lists/*

# Redis
RUN pecl install -o -f redis; \
    rm -rf /tmp/pear; \
    docker-php-ext-enable redis

# Install Postgre PDO
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

# MbString
RUN docker-php-ext-install mbstring

# Memcached
RUN pecl install memcached; \
  docker-php-ext-enable memcached

# BcMath
RUN docker-php-ext-install bcmath

# Sockets
#RUN docker-php-ext-install sockets
RUN docker-php-source extract ; curl -fsSL https://raw.githubusercontent.com/php/php-src/6a6c8a60965c6fc3f145870a49b13b719ebd4a72/ext/sockets/config.m4 -o /usr/src/php/ext/sockets/config.m4 ; docker-php-ext-install sockets

# FileInfo
RUN docker-php-ext-install fileinfo

# Ext Intl
RUN docker-php-ext-install intl

# Curl
RUN apt-get clean; \
  apt-get update --fix-missing; \
  apt-get install -y curl libcurl4-gnutls-dev; \
  rm -rf /var/lib/apt/lists/*; \
  wget -P /etc/ssl/certs https://curl.haxx.se/ca/cacert.pem; \
  sed -i '/;curl.cainfo =/curl.cainfo = /etc/ssl/certs/cacert.pem' /usr/local/etc/php/php.ini

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN wget --no-check-certificate -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu

# Vim
ARG DEVELOP
RUN if [ ${DEVELOP} = true ]; then \
    apt-get clean && \
    apt-get update --fix-missing && \
    apt-get install -y vim \
;fi

###########################################################################
# xDebug:
###########################################################################

ARG INSTALL_XDEBUG
RUN if [ ${INSTALL_XDEBUG} = true ]; then \
  # Install the xdebug extension, php 8.1 require >= 3.1.0
  if [ $(php -r "echo PHP_MAJOR_VERSION;") = "8" ]; then \
    pecl install xdebug-3.1.2; \
  else \
    if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
      pecl install xdebug-2.5.5; \
    else \
      if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
        pecl install xdebug-2.9.0; \
      else \
        pecl install xdebug-2.9.8; \
      fi \
    fi \
  fi && \
  docker-php-ext-enable xdebug && \
  touch /var/log/xdebug.log \
;fi

# Copy xdebug configuration for remote debugging
COPY ./conf.d/00-xdebug.ini /usr/local/etc/php/conf.d/00-xdebug.ini
COPY ./conf.d/50-custom.ini         /usr/local/etc/php/conf.d/
COPY ./php-fpm.pool.conf  /usr/local/etc/php-fpm.d/
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./supervisor.dev/ /etc/supervisor/conf.d/

# Configure non-root user.
ARG PUID=1000
ENV PUID ${PUID}
ARG PGID=1000
ENV PGID ${PGID}

RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

RUN cp -r /etc/skel /home/www-data \
    && mkdir -p /home/www-data/.composer \
    && chown -R www-data:www-data /home/www-data \
    && usermod -d /home/www-data www-data \
    && sed -i "s/var\/run\/supervisor.sock/home\/www-data\/supervisor.sock/" /etc/supervisor/supervisord.conf \
    && mkdir -p /var/log/supervisor \
    && chown www-data:www-data -R /var/log/supervisor/

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    chown www-data:www-data /var/log/xdebug.log \
;fi

# Configure locale.
ARG LOCALE=POSIX
ENV LC_ALL ${LOCALE}

WORKDIR /var/www

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE 9000
