FROM cm2network/steamcmd:latest

USER root

WORKDIR /home/steam

# Cache bust: 2026-08-31
# HLDS yuklab olish (xatolar ko'rinsin deb || true olib tashlandi)
RUN ./steamcmd.sh +login anonymous +force_install_dir /home/steam/hlds +app_update 90 validate +quit && \
    echo "HLDS 1-chi marta yuklandi" && \
    ls /home/steam/hlds/cstrike/ || echo "CSTRIKE topilmadi!"

RUN ./steamcmd.sh +login anonymous +force_install_dir /home/steam/hlds +app_update 90 validate +quit && \
    echo "HLDS 2-chi marta yuklandi" && \
    ls /home/steam/hlds/cstrike/

WORKDIR /home/steam/hlds

# Metamod o'rnatish
RUN apt-get update && apt-get install -y curl ca-certificates && \
    mkdir -p cstrike/addons/metamod/dlls && \
    curl -sL -o metamod.tar.gz "https://sourceforge.net/projects/metamod-p/files/Metamod-P%20Binaries/1.21p37/metamod-p-1.21p37-linux_i686.tar.gz/download" && \
    tar -xzf metamod.tar.gz -C cstrike/addons/metamod/dlls && \
    rm metamod.tar.gz && \
    echo "linux addons/metamod/dlls/metamod_i386.so" > cstrike/addons/metamod/plugins.ini

# liblist.gam ni yangilash
RUN if [ -f cstrike/liblist.gam ]; then \
        sed -i 's/gamedll_linux "dlls\/cs.so"/gamedll_linux "addons\/metamod\/dlls\/metamod_i386.so"/g' cstrike/liblist.gam; \
        echo "liblist.gam yangilandi!"; \
    else \
        echo "XATO: liblist.gam topilmadi! HLDS to'liq yuklanmagan."; \
        ls -la cstrike/ || echo "cstrike papkasi ham yo'q!"; \
        exit 1; \
    fi

# AmxModX o'rnatish
RUN curl -sL -o base.tar.gz http://www.amxmodx.org/release/amxmodx-1.8.2-base-linux.tar.gz && \
    tar -xzf base.tar.gz -C cstrike/ && rm base.tar.gz && \
    curl -sL -o cstrike.tar.gz http://www.amxmodx.org/release/amxmodx-1.8.2-cstrike-linux.tar.gz && \
    tar -xzf cstrike.tar.gz -C cstrike/ && rm cstrike.tar.gz

RUN echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> cstrike/addons/metamod/plugins.ini

RUN mkdir -p ~/.steam/sdk32 && \
    ln -sf /home/steam/.steam/sdk32/steamclient.so ~/.steam/sdk32/steamclient.so || true

COPY server.cfg /home/steam/hlds/cstrike/server.cfg

EXPOSE 27015/udp
EXPOSE 27015/tcp

CMD ["./hlds_run", "-game", "cstrike", "-strictportbind", "+ip", "0.0.0.0", "+port", "27015", "+map", "de_dust2", "+maxplayers", "32"]
