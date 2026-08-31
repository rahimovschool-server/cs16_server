FROM debian:bullseye-slim

ENV USER=root

# Install dependencies required for steamcmd and hlds
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wget curl lib32gcc-s1 lib32stdc++6 unzip

WORKDIR /server

# Download and extract SteamCMD using curl
RUN mkdir -p /server/steamcmd && \
    cd /server/steamcmd && \
    curl -sqL "https://steamcmd.steamcommunity.com/sq/steamcmd_linux.tar.gz" | tar zxvf -

# Download CS 1.6 server (running twice to fix app 90 bug)
RUN /server/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server/hlds +app_update 90 validate +quit || true
RUN /server/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server/hlds +app_update 90 validate +quit || true

WORKDIR /server/hlds

# Install Metamod
RUN mkdir -p cstrike/addons/metamod/dlls && \
    curl -sqL "https://github.com/Bots-United/metamod-p/releases/download/v1.21p37/metamod-P-1.21p37-linux_i586.tar.gz" | tar -xzf - -C cstrike/addons/metamod/dlls && \
    echo "linux addons/metamod/dlls/metamod_i386.so" > cstrike/addons/metamod/plugins.ini

# Edit liblist.gam to load Metamod instead of default CS dll
RUN sed -i 's/gamedll_linux "dlls\/cs.so"/gamedll_linux "addons\/metamod\/dlls\/metamod_i386.so"/g' cstrike/liblist.gam

# Install AmxModX
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz" | tar -xzf - -C cstrike/ && \
    curl -sqL "http://www.amxmodx.org/release/amxmodx-1.8.2-cstrike-linux.tar.gz" | tar -xzf - -C cstrike/

# Enable AmxModX in Metamod
RUN echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> cstrike/addons/metamod/plugins.ini

# Fix Steam client error
RUN mkdir -p ~/.steam/sdk32 && ln -s /server/steamcmd/linux32/steamclient.so ~/.steam/sdk32/steamclient.so

# Copy server configuration
COPY server.cfg /server/hlds/cstrike/server.cfg

EXPOSE 27015/udp
EXPOSE 27015/tcp

# Start the server
CMD ["./hlds_run", "-game", "cstrike", "-strictportbind", "+ip", "0.0.0.0", "+port", "27015", "+map", "de_dust2", "+maxplayers", "32"]
