FROM ubuntu:16.04

MAINTAINER binbin@ukex.com

ENV PHP_VERSION 7.2.19
ENV PHPREDIS_VERSION 5.0.0
ENV PHPGRPC_VERSION 1.19.0
ENV PHPPROTOBUF_VERSION 3.6.1
ENV PHPAMQP_VERSION 1.9.4
ENV GRPC_ENABLE_FORK_SUPPORT 1
ENV GRPC_POLL_STRATEGY epoll1
ENV BUILD_ROOT /usr/local/src/php
ENV PATH /usr/local/php/sbin/:/usr/local/php/bin:$PATH

RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak \
        && sed -i "s/archive\.ubuntu\.com/mirrors\.163\.com/g" /etc/apt/sources.list \
	&& apt-get update && apt-get install -y libcurl4-gnutls-dev  wget g++ libxslt-dev gcc make openssl curl libbz2-dev libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev libpng-dev libzip-dev libssl-dev libevent-dev autoconf cmake \
	&& mkdir -p $BUILD_ROOT \
	&& cd $BUILD_ROOT \
#	&& wget -O $BUILD_ROOT/php-$PHP_VERSION.tar.gz https://www.php.net/distributions/php-$PHP_VERSION.tar.gz \
#	&& wget -O bison-3.0.4.tar.gz  http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.gz \
	&& wget -O $BUILD_ROOT/php-$PHP_VERSION.tar.gz http://mirrors.sohu.com/php/php-$PHP_VERSION.tar.gz \
	&& wget -O php-fpm.conf https://raw.githubusercontent.com/zhangtiantian222/php/master/php-fpm.conf \
	&& wget -O php.ini https://raw.githubusercontent.com/zhangtiantian222/php/master/php.ini \
	&& wget https://github.com/alanxz/rabbitmq-c/archive/v0.9.0-master.tar.gz \
	&& tar -xf v0.9.0-master.tar.gz && cd rabbitmq-c-0.9.0-master \
	&& cmake . -DCMAKE_INSTALL_PREFIX=/usr/lib/ && cmake --build . --target install && cd .. \
#	&& tar -xf bison-3.0.4.tar.gz \
#	&&  cd bison-* \
#	&& ./configure	\
#	&& make && make install \
#	&& cd .. \
	&& tar -xf php-$PHP_VERSION.tar.gz \
	&& cd php-$PHP_VERSION \
	&& export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu/ \
	&& ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib \
	&& ldconfig \
	&&  BUILD_CONFIG="\
		--prefix=/usr/local/php \
		--with-config-file-path=/usr/local/php/etc \
		--with-config-file-scan-dir=/usr/local/php/conf.d \
		--enable-fpm \
		--with-fpm-user=www-data \
		--with-fpm-group=www-data \
		--enable-mysqlnd \
		--with-mysqli=mysqlnd \
		--with-pdo-mysql=mysqlnd \
		--with-iconv-dir \
		--with-freetype-dir=/opt/freetype \
		--with-jpeg-dir \
		--with-png-dir \
		--with-zlib \
		--with-libxml-dir=/usr \
		--enable-xml \
		--disable-rpath \
		--enable-bcmath \
		--enable-shmop \
		--enable-sysvsem \
		--enable-inline-optimization \
		--with-curl \
		--enable-mbregex \
		--enable-mbstring \
		--enable-intl \
		--enable-ftp \
		--with-gd \
		--with-openssl \
		--with-mhash \
		--enable-pcntl \
		--enable-sockets \
		--with-xmlrpc \
		--enable-zip \
		--enable-soap \
		--with-gettext \
		--disable-fileinfo \
		--enable-opcache \
		--with-xsl \
		" \
	&& ./configure $BUILD_CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& pecl install event redis amqp apcu protobuf \
	&& mv ../php-fpm.conf ../php.ini /usr/local/php/etc/ \
	&& echo  "extension="redis.so"\nextension="amqp.so"\nextension="event.so"\nextension="apcu.so"\nextension=protobuf.so">> /usr/local/php/etc/php.ini 
EXPOSE 9000
#CMD ["php-fpm", "-f", "/usr/local/php/etc/php-fpm.conf"]
CMD ["tail", "-f", "/dev/null"]

