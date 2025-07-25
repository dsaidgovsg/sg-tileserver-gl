ARG TILESERVER_GL_VERSION="v3.1.1"
FROM maptiler/tileserver-gl:${TILESERVER_GL_VERSION} AS native

# This must be run after setup.sh
# /data should already be the WORKDIR in the base image
COPY ./data /data

FROM native AS openresty

USER root

# Fix Buster repository URLs
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list

# This section assume the distro underlying tileserver-gl is Debian (buster at the moment)
# Verify debian as the distro first
RUN . /etc/os-release && test $ID = "debian"

# Guide: https://openresty.org/en/linux-packages.html#debian
RUN apt-get update && \
    apt-get -y install --no-install-recommends wget gnupg ca-certificates && \
    wget -O - https://openresty.org/package/pubkey.gpg | apt-key add - && \
    codename=`grep -Po 'VERSION="[0-9]+ \(\K[^)]+' /etc/os-release` && \
    echo "deb http://openresty.org/package/debian $codename openresty" \
        | tee /etc/apt/sources.list.d/openresty.list && \
    apt-get update && \
    apt-get -y install --no-install-recommends openresty supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    :

RUN addgroup svisor && \
    adduser -u 1001 --no-create-home --disabled-password --gecos "" svisor --ingroup svisor && \
    :

RUN mkdir -p /var/run/supervisor /var/log/supervisor/ && \
    chown -R svisor:svisor \
        /etc/openresty/ /usr/local/openresty/ \
        /var/run/supervisor/ /var/log/supervisor/ && \
    :

COPY supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord/nginx.conf /etc/openresty/nginx.conf

USER 1001

CMD ["/usr/bin/supervisord"]
