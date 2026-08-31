FROM archont94/counter-strike1.6:latest

# Server konfiguratsiyasini ko'chirish
COPY server.cfg /hlds/cstrike/server.cfg

EXPOSE 27015/udp
EXPOSE 27015/tcp
EXPOSE 80/tcp
