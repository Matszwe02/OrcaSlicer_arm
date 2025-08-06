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


FROM kasmweb/core-ubuntu-jammy:aarch64-1.16.0

USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

COPY --from=BUILDER /opt/OrcaSlicer/build/package /opt/orca-slicer
COPY --from=BUILDER /opt/OrcaSlicer/linux.d   /opt/orca-slicer/linux.d
RUN sed -i 's/libwebkit2gtk-4.0-dev/libwebkit2gtk-4.*-dev/' /opt/orca-slicer/linux.d/debian

RUN sed -i '1i#!/bin/bash\nUPDATE_LIB="1"' /opt/orca-slicer/linux.d/debian
RUN chmod +x /opt/orca-slicer/linux.d/debian

RUN apt-get update && \
    /opt/orca-slicer/linux.d/debian && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/orca-slicer/bin/:$PATH"
ENV KASM_SVC_AUDIO=0
ENV START_PULSEAUDIO=0
ENV KASM_SVC_AUDIO_INPUT=0
ENV KASM_SVC_GAMEPAD=0
ENV KASM_SVC_WEBCAM=0
ENV KASM_SVC_PRINTER=1

RUN sed -i "/function start_printer (){/,/^}/c\function start_printer (){\n\t\t\/opt\/orca-slicer\/bin\/orca-slicer \&\n\t\tKASM_PROCS\['kasm_printer'\]=\$!\n\n\t\tif \[\[ \$DEBUG == true \]\]; then\n\t\t\techo -e \"\\n------------------ Started OrcaSlicer  ----------------------------\"\n\t\t\techo \"OrcaSlicer PID: \${KASM_PROCS\['kasm_printer'\]}\";\n\t\tfi\n}" /dockerstartup/vnc_startup.sh


RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN cp /usr/share/backgrounds/bg_kasm.png /usr/share/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel


######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000