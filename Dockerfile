FROM debian:jessie
MAINTAINER Daniel D <djx339@gmail.com>

ENV NGINX_VERSION 1.9.3
ENV NGINX_USER nginx

RUN apt-get update && apt-get install -y \
        ca-certificates \
        gcc \
        git \
        libldap2-dev \
        libpcre3-dev \
        libssl-dev \
        make \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-login --gecos 'Nginx' ${NGINX_USER} \
    && passwd -d ${NGINX_USER}

RUN mkdir /var/log/nginx \
    && cd ~ \
    && git clone -b release-${NGINX_VERSION} --depth 1 \
    https://github.com/nginx/nginx.git

RUN cd ~ \
    && git clone --depth 1 \
    https://github.com/kvspb/nginx-auth-ldap.git

RUN cd ~/nginx/ \
    && ./auto/configure \
    --add-module=../nginx-auth-ldap \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_spdy_module \
    --with-cc-opt='-g -O2 \
    -fstack-protector-strong \
    -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2'\
    --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
    --with-ipv6 \
    && make install \
    && cd .. \
    && rm -rf nginx nginx-auth-ldap

ADD ./assets/config/nginx.conf /etc/nginx/nginx.conf
ADD ./assets/config/default.conf /etc/nginx/conf.d/default.conf

# clean cache
RUN apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
