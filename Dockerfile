# Railway (ARM64) serverlarida xato bermasligi uchun amd64 ni majburlaymiz
FROM --platform=linux/amd64 debian:bullseye-slim

ENV USER=root

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wget curl lib32gcc-s1 lib32stdc++6 unzip ca-certificates

WORKDIR /server

RUN mkdir -p /server/steamcmd && \
    cd /server/steamcmd && \
    curl -sL -o steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -zxvf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

RUN /server/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server/hlds +app_update 90 validate +quit || true
RUN /server/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server/hlds +app_update 90 validate +quit || true

WORKDIR /server/hlds

RUN mkdir -p cstrike/addons/metamod/dlls && \
    curl -sL -o metamod.tar.gz https://sourceforge.net/projects/metamod-p/files/Metamod-P%20Binaries/1.21p37/metamod-p-1.21p37-linux_i686.tar.gz/download && \
    tar -xzf metamod.tar.gz -C cstrike/addons/metamod/dlls && \
    rm metamod.tar.gz && \
    echo "linux addons/metamod/dlls/metamod_i386.so" > cstrike/addons/metamod/plugins.ini

RUN sed -i 's/gamedll_linux "dlls\/cs.so"/gamedll_linux "addons\/metamod\/dlls\/metamod_i386.so"/g' cstrike/liblist.gam

RUN curl -sL -o base.tar.gz http://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz && \
    tar -xzf base.tar.gz -C cstrike/ && rm base.tar.gz && \
    curl -sL -o cstrike.tar.gz http://www.amxmodx.org/release/amxmodx-1.8.2-cstrike-linux.tar.gz && \
    tar -xzf cstrike.tar.gz -C cstrike/ && rm cstrike.tar.gz

RUN echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> cstrike/addons/metamod/plugins.ini

RUN mkdir -p ~/.steam/sdk32 && ln -s /server/steamcmd/linux32/steamclient.so ~/.steam/sdk32/steamclient.so

COPY server.cfg /server/hlds/cstrike/server.cfg

EXPOSE 27015/udp
EXPOSE 27015/tcp

CMD ["./hlds_run", "-game", "cstrike", "-strictportbind", "+ip", "0.0.0.0", "+port", "27015", "+map", "de_dust2", "+maxplayers", "32"]
