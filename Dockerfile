FROM php:8.3-cli

# UID/GID do host para o usuário www-data (evita problemas de permissão)
ARG UID=1000
ARG GID=1000

# Dependências básicas + Node + libs PHP
RUN apt-get update && apt-get install -y \
    ca-certificates \
    gnupg \
    curl \
    sudo \
    libpng-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libmagickwand-dev \
    libpq-dev \
    libsqlite3-dev \
    pkg-config \
    zip \
    unzip \
    nano \
    iputils-ping \
    wget \
    locales \
    libnspr4 \
    libnss3 \
    chromium \
    git \
    && echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen pt_BR.UTF-8

# Node LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Extensões PHP (separadas para facilitar debug no CI)
RUN set -eux; \
    docker-php-ext-configure gd --with-jpeg

RUN set -eux; \
    docker-php-ext-install -j"$(nproc)" \
        pdo \
        pdo_mysql \
        pgsql \
        pdo_pgsql

RUN set -eux; \
    docker-php-ext-install -j"$(nproc)" \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        calendar

RUN set -eux; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*


# Imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Composer
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

# Ajustar usuário/grupo padrão www-data com UID/GID do host
RUN groupmod -g ${GID} www-data \
    && usermod -u ${UID} -g ${GID} www-data \
    && mkdir -p /var/www \
    && chown -R www-data:www-data /var/www \
    && echo "www-data ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/www-data \
    && chmod 0440 /etc/sudoers.d/www-data

# Locale
ENV LANG=pt_BR.UTF-8
ENV LANGUAGE=pt_BR:pt
ENV LC_ALL=pt_BR.UTF-8

WORKDIR /var/www/html

USER www-data

EXPOSE 8000
