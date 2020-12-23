FROM alpine:3.10
ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/lastbyte32/docker-alpine-web"
      
RUN apk -U upgrade && apk add --no-cache \
    curl \
    nginx \
    php7-fpm \
    tzdata \
    && ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm \
    && addgroup -S php \
    && adduser -S -G php php \
    && rm -rf /var/cache/apk/* /etc/nginx/conf.d/* /etc/php7/conf.d/* /etc/php7/php-fpm.d/*

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv; \
    apk -U --no-cache add \
        php \
        php7-bcmath \
        php-curl \
        php-dom \
        php-exif \
        php-gd \
        php-iconv \
        php-intl \
        php-json \
        php-mbstring \
        php-pcntl \
        php-pdo_mysql \
        php-phar \
        php-posix \
        php7-tokenizer \
        php7-xmlwriter \
        php7-fileinfo \
        php-session \
        php-xml \
        php-zip \
    && rm -rf /var/cache/apk/*
   # \
   # && ln -s /usr/bin/php7 /usr/bin/php

COPY conf/general conf/php7 /
RUN curl -sL -o /tmp/s6-overlay-amd64.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz && \
    tar zxf /tmp/s6-overlay-amd64.tar.gz -C /
    
# Enable options supported by this version of PHP-FPM
RUN sed '/decorate_workers_output/s/^; //g' /etc/php7/php-fpm.conf

# See https://github.com/docker-library/php/issues/240
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php


ENTRYPOINT ["/init"]

EXPOSE 80

HEALTHCHECK --interval=5s --timeout=5s CMD curl -f http://127.0.0.1/php-fpm-ping || exit 1
