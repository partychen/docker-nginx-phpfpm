FROM ubuntu:bionic
LABEL partychen <partychen.acm@gmail.com>

ENV OS_LOCALE="en_US.UTF-8" \
    DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y locales && locale-gen ${OS_LOCALE}
ENV LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE}

ENV PHP_RUN_DIR=/run/php \
    PHP_LOG_DIR=/var/log/php \
    PHP_CONF_DIR=/etc/php/7.3 \
    PHP_DATA_DIR=/var/lib/php \
    NGINX_CONF_DIR=/etc/nginx \
    SUPERVISOR_CONF_DIR=/etc/supervisor

RUN \
    BUILD_DEPS='software-properties-common gnupg apt-utils' \
    && dpkg-reconfigure locales \
    # Install common libraries
    && apt-get install --no-install-recommends -y $BUILD_DEPS \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    # Install PHP libraries
    && apt-get install -y curl php7.3-fpm php7.3-readline php7.3-mbstring php7.3-zip php7.3-intl php7.3-json php7.3-xml php7.3-curl php7.3-gd php7.3-pgsql php7.3-mysql php-pear \
    # Install composer
    && curl -sS https://getcomposer.org/installer | php -- --version=1.8.4 --install-dir=/usr/local/bin --filename=composer \
    && mkdir -p ${PHP_LOG_DIR} ${PHP_RUN_DIR} \
    # Install nginx
    && apt-get install -y nginx \
    && rm -rf ${NGINX_CONF_DIR}/sites-enabled/* ${NGINX_CONF_DIR}/sites-available/* \
    # Install supervisor
    && apt-get install -y supervisor && mkdir -p /var/log/supervisor \
    # Cleaning
    && apt-get purge -y --auto-remove $BUILD_DEPS \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./configs/supervisord.conf ${SUPERVISOR_CONF_DIR}/conf.d/
COPY ./configs/php-fpm.conf ${PHP_CONF_DIR}/fpm/php-fpm.conf
COPY ./configs/www.conf ${PHP_CONF_DIR}/fpm/pool.d/www.conf
COPY ./configs/php.ini ${PHP_CONF_DIR}/fpm/conf.d/custom.ini
COPY ./configs/nginx.conf ${NGINX_CONF_DIR}/nginx.conf
COPY ./configs/app.conf ${NGINX_CONF_DIR}/sites-enabled/app.conf

RUN sed -i "s~PHP_RUN_DIR~${PHP_RUN_DIR}~g" ${PHP_CONF_DIR}/fpm/php-fpm.conf \
    && sed -i "s~PHP_LOG_DIR~${PHP_LOG_DIR}~g" ${PHP_CONF_DIR}/fpm/php-fpm.conf \
    && chown www-data:www-data ${PHP_DATA_DIR} -Rf

VOLUME ["${PHP_RUN_DIR}", "${PHP_DATA_DIR}"]

WORKDIR /var/www/app/

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]
