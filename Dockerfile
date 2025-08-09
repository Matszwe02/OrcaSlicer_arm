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

RUN sed -i 's/libwebkit2gtk-4.0-dev/libwebkit2gtk-4.*-dev/' linux.d/debian
RUN ./build_linux.sh -u
RUN ./build_linux.sh -d
RUN ./build_linux.sh -sr

RUN chown 1000:0 /opt/OrcaSlicer/build/package/bin/orca-slicer


FROM ghcr.io/linuxserver/baseimage-selkies:arm64v8-ubuntunoble-7b3ee6a7-ls67

ENV TITLE="OrcaSlicer"


COPY --from=BUILDER /opt/OrcaSlicer/build/package /opt/orca-slicer
COPY --from=BUILDER /opt/OrcaSlicer/resources/images/OrcaSlicer.png /usr/share/selkies/www/icon.png

RUN apt-get update && \
    apt-get install -y libwebkit2gtk-4.1-dev && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

ENV PATH="/opt/orca-slicer/bin/:$PATH"
ENV MAX_RES=1920x1080
ENV NO_DECOR=true

COPY ./root/defaults /defaults

EXPOSE 3000
VOLUME /config