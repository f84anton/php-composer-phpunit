FROM: php:7.0-cli

RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini \
 && echo "date.timezone=${PHP_TIMEZONE:-Europe/Moscow}" > "$PHP_INI_DIR/conf.d/date_timezone.ini"

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -qy \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libbz2-dev \
    libxslt-dev \
    libldap2-dev \
    php-pear \
    curl \
    git \
    subversion \
    unzip \
    wget \
  --no-install-recommends && rm -r /var/lib/apt/lists/*

#RUN docker-php-ext-install bcmath mcrypt zip bz2 mbstring pcntl xsl \
#  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#  && docker-php-ext-install gd \
#  && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
#  && docker-php-ext-install ldap

ENV PATH "/composer/vendor/bin:$PATH"
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION 1.4.1

RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/da290238de6d63faace0343efbdd5aa9354332c5/web/installer \
 && php -r " \
    \$signature = '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
        unlink('/tmp/installer.php'); \
        echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
        exit(1); \
    }" \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    && rm /tmp/installer.php \
    && composer --ansi --version --no-interaction

WORKDIR /app
