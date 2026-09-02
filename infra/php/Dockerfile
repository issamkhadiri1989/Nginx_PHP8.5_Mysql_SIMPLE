FROM php:8.5-fpm

# set main params
ARG BUILD_ARGUMENT_ENV=dev

ENV APP_HOME=/var/www/html

# install system dependencies
RUN set -eux; \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            $PHPIZE_DEPS \
            bash-completion \
            fish \
            procps \
            nano \
            git \
            unzip \
            libicu-dev \
            zlib1g-dev \
            libxml2 \
            libxml2-dev \
            libreadline-dev \
            supervisor \
            cron \
            sudo \
            libzip-dev \
            wget \
            librabbitmq-dev \
            libxslt-dev \
            libldap2-dev \
            libssl-dev; \
        rm -rf /var/lib/apt/lists/*

# build and enable PHP extensions
RUN set -eux; \
        pecl install amqp; \
        docker-php-ext-enable amqp; \
        docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
        docker-php-ext-configure intl; \
        docker-php-ext-install \
            pdo_mysql \
            sockets \
            intl \
            zip

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# Enable Composer autocompletion
RUN composer completion bash > /etc/bash_completion.d/composer

# set working directory
WORKDIR $APP_HOME

# Installer APCu
RUN mkdir -p /usr/src/php/ext/apcu && \
    curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 && \
    docker-php-ext-install apcu

# Installer Xdebug
RUN pecl install xdebug-3.5.1 && \
    docker-php-ext-enable xdebug

# Installer l'extension Redis
RUN pecl install redis && \
   docker-php-ext-enable redis

# Installer MongoDB
RUN pecl install mongodb && docker-php-ext-enable mongodb

# Installer les extensions PHP
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions gd bcmath zip xsl ldap

# Install the Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
   mv /root/.symfony5/bin/symfony /usr/local/bin/symfony && \
   mv /root/.symfony5 /root/.config/symfony-cli

USER root
