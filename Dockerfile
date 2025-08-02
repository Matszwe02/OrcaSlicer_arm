FROM kasmweb/core-ubuntu-jammy:1.17.0

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


RUN cp -r /opt/OrcaSlicer/build/package /opt/orca-slicer
RUN rm -rf /opt/OrcaSlicer

RUN chown 1000:0 /opt/orca-slicer/bin/orca-slicer
RUN apt-get clean && \ 
    rm -rf /var/lib/apt/lists/*

RUN echo "/usr/bin/desktop_ready && /opt/orca-slicer/bin/orca-slicer &" > $STARTUPDIR/custom_startup.sh \
&& chmod +x $STARTUPDIR/custom_startup.sh


######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000

