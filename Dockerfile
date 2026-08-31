FROM debian:bullseye-slim

ENV USER=root

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wget curl lib32gcc-s1 lib32stdc++6 unzip ca-certificates

WORKDIR /server

# Eng kuchli Akamai CDN serveridan uzilishlarsiz tortish va arxivdan chiqarish
RUN mkdir -p /server/steamcmd && \
    cd /server/steamcmd && \
    curl -sL -O https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -zxvf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

# CS 1.6 serverini tortish
RUN /server/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server/hlds +app_update 90 validate +quit || true
RUN /server/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server/hlds +app_update 90 validate +quit || true

WORKDIR /server/hlds

# Metamod o'rnatish
RUN mkdir -p cstrike/addons/metamod/dlls && \
    curl -sL -O https://github.com/Bots-United/metamod-p/releases/download/v1.21p37/metamod-P-1.21p37-linux_i586.tar.gz && \
    tar -xzf metamod-P-1.21p37-linux_i586.tar.gz -C cstrike/addons/metamod/dlls && \
    echo "linux addons/metamod/dlls/metamod_i386.so" > cstrike/addons/metamod/plugins.ini

RUN sed -i 's/gamedll_linux "dlls\/cs.so"/gamedll_linux "addons\/metamod\/dlls\/metamod_i386.so"/g' cstrike/liblist.gam

# AmxModX o'rnatish
RUN curl -sL -O http://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz && \
    tar -xzf amxmodx-1.8.2-base-linux.tar.gz -C cstrike/ && \
    curl -sL -O http://www.amxmodx.org/release/amxmodx-1.8.2-cstrike-linux.tar.gz && \
    tar -xzf amxmodx-1.8.2-cstrike-linux.tar.gz -C cstrike/

RUN echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> cstrike/addons/metamod/plugins.ini

RUN mkdir -p ~/.steam/sdk32 && ln -s /server/steamcmd/linux32/steamclient.so ~/.steam/sdk32/steamclient.so

COPY server.cfg /server/hlds/cstrike/server.cfg

EXPOSE 27015/udp
EXPOSE 27015/tcp

CMD ["./hlds_run", "-game", "cstrike", "-strictportbind", "+ip", "0.0.0.0", "+port", "27015", "+map", "de_dust2", "+maxplayers", "32"]
