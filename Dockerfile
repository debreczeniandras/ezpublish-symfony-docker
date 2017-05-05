FROM php:5.6.30-fpm

MAINTAINER Andras Debreczeni <andras.debreczeni@db-n.com>

ENV DEBIAN_FRONTEND="noninteractive" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

# SET PECL PROXY accordingly
# the ENV variabl should come from the gitlab runner config.toml file
RUN if [ $HTTP_PROXY ]; then pear config-set http_proxy $HTTP_PROXY; fi

# Locales
RUN apt-get update && apt-get install -y \
		locales \
		libicu-dev \
		&& dpkg-reconfigure locales \
		&& locale-gen C.UTF-8 \
		&& /usr/sbin/update-locale LANG=C.UTF-8 \
		echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
		&& locale-gen \
		&& docker-php-ext-configure intl \
		&& docker-php-ext-install intl \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

# Common
RUN apt-get update && apt-get install -y \
		openssl \
		git \
		# Install composer and put binary into $PATH
        && curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

# php modules
RUN apt-get update && apt-get install -y \
		libbz2-dev \
		libssl-dev \
		libxml2-dev \
		libxslt-dev \
        libmcrypt-dev \
        zlib1g-dev \
		&& docker-php-ext-install \
			dom \
			xsl \
        	bz2 \
        	gettext \
        	mcrypt \
        	zip \
            ftp \
            mbstring \
            mysqli \
            pdo \
            pdo_mysql \
            soap \
            sysvshm \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

# image modules
RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libgd-dev \
		imagemagick \
        libmagickwand-dev \
		&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
		&& docker-php-ext-install \
			gd \
			exif \
		&& pecl install imagick \
		&& docker-php-ext-enable imagick \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

# Memcached
RUN apt-get update && apt-get install -y \
		libmemcached-dev \
		libmemcached11 \
		zlib1g-dev \
		&& pecl install memcached-2.2.0 \
        && docker-php-ext-enable memcached \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

# JAVA
RUN apt-get update && apt-get install -y \
    openjdk-7-jre-headless \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

ADD php.ini /usr/local/etc/php/conf.d/docker-php.ini
