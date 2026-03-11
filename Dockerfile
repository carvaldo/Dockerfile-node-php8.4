FROM php:8.3-cli

# UID/GID do host (evita problemas de permissão)
ARG UID=1000
ARG GID=1000

# Dependências básicas + Node + libs PHP
RUN apt-get update && apt-get install -y \
    ca-certificates \
    gnupg \
    curl \
    libpng-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libmagickwand-dev \
    libpq-dev \
    pkg-config \
    zip \
    unzip \
    nano \
    iputils-ping \
    wget \
    locales \
    git \
    && echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen pt_BR.UTF-8

# Node LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Extensões PHP
RUN docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        pgsql \
        pdo_pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        calendar

# Imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Composer
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

# Criar usuário com mesmo UID do host
RUN groupadd -g ${GID} app \
    && useradd -u ${UID} -g app -m app \
    && mkdir -p /var/www \
    && chown -R app:app /var/www

# Locale
ENV LANG=pt_BR.UTF-8
ENV LANGUAGE=pt_BR:pt
ENV LC_ALL=pt_BR.UTF-8

WORKDIR /var/www/html

USER app

EXPOSE 8000
