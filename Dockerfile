FROM php:5.6.30-fpm

MAINTAINER Andras Debreczeni <andras.debreczeni@db-n.com>

ENV DEBIAN_FRONTEND="noninteractive" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

# SET PECL PROXY accordingly
# the ENV variabl should come from the gitlab runner config.toml file
RUN if [ $HTTP_PROXY ]; then pear config-set http_proxy $HTTP_PROXY; fi

# Locales + common
RUN apt-get update && apt-get install -y \
		git \
		libbz2-dev \
		libicu-dev \
		locales \
		openssl \
        imagemagick \
        libfreetype6-dev \
        libgd-dev \
        libjpeg62-turbo-dev \
        libmagickwand-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libmemcached11 \
        libpng12-dev \
        libssl-dev \
        libxml2-dev \
        libxslt-dev \
        zlib1g-dev \
        zlib1g-dev \
		&& dpkg-reconfigure locales \
		&& locale-gen C.UTF-8 \
		&& /usr/sbin/update-locale LANG=C.UTF-8 \
		echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
		&& locale-gen \
		&& docker-php-ext-configure intl \
		&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
		&& docker-php-ext-install intl \
		    dom \
        	xsl \
            bz2 \
            gd \
            gettext \
            mcrypt \
            zip \
            exif \
            ftp \
            mbstring \
            mysqli \
            pdo \
            pdo_mysql \
            soap \
            sysvshm \
        && pecl install imagick  memcached-2.2.0 \
        && docker-php-ext-enable imagick memcached \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

# Composer + Deployer
RUN apt-get update && apt-get install -y \
		# Install composer and put binary into $PATH
        && curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer \
        && curl -LO https://deployer.org/deployer.phar \
        && mv deployer.phar /usr/local/bin/dep \
        && chmod +x /usr/local/bin/dep \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*


# JAVA
RUN apt-get update && apt-get install -y \
    openjdk-7-jre-headless \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

ADD php.ini /usr/local/etc/php/conf.d/docker-php.ini
