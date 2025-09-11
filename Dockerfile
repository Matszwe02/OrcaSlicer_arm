FROM kasmweb/core-ubuntu-jammy:aarch64-1.17.0 AS BUILDER
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    xvfb \
    x11vnc \
    fluxbox \
    libdbus-1-dev \
    --no-install-recommends

RUN git clone https://github.com/SoftFever/OrcaSlicer.git --depth 1 /opt/OrcaSlicer
WORKDIR /opt/OrcaSlicer

# RUN sed -i 's/libwebkit2gtk-4.0-dev/libwebkit2gtk-4.*-dev/' linux.d/debian
RUN ./build_linux.sh -u
RUN set -x && ./build_linux.sh -d
RUN ./build_linux.sh -sr

RUN chown 1000:0 /opt/OrcaSlicer/build/package/bin/orca-slicer

FROM ghcr.io/linuxserver/baseimage-kasmvnc:arm64v8-ubuntunoble-8076605d-ls70
ENV TITLE=OrcaSlicer \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN apt-get update && apt-get install -y \
    libwebkit2gtk-4.1-dev \
    mesa-utils \
    libgl1-mesa-dri \
    libegl-mesa0 && \
    echo "deb http://ports.ubuntu.com/ubuntu-ports/ jammy main universe" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y libwebkit2gtk-4.0-37 libjavascriptcoregtk-4.0-18 libicu70 libsoup2.4-1 && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

COPY --from=BUILDER /opt/OrcaSlicer/build/package /opt/orca-slicer

RUN curl -o /kclient/public/icon.png https://raw.githubusercontent.com/SoftFever/OrcaSlicer/main/resources/images/OrcaSlicer.png \
    touch /orcaslicer_init && echo '#!/bin/sh -e' > /orcaslicer_init && echo "while true; do /opt/orca-slicer/bin/orca-slicer; done;" >> /orcaslicer_init && chmod +x /orcaslicer_init \
    sed -i '/server {/,$!b;/location \/ {/i   location /favicon.ico {\n    alias /kclient/public/icon.png;\n  }' /defaults/default.conf \
    sed -i "/# root, can be a normal user)./a chown -R abc:abc /config/.config/OrcaSlicer" /init

ENV MAX_RES=1920x1080
ENV NO_DECOR=true

COPY ./root/defaults /defaults

EXPOSE 3000