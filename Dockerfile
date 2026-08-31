FROM archont94/counter-strike1.6:latest

COPY server.cfg /hlds/cstrike/server.cfg

EXPOSE 27015/udp
EXPOSE 27015/tcp

CMD ["/hlds/hlds_run", "-game", "cstrike", "+ip", "0.0.0.0", "+port", "27015", "+map", "de_dust2", "+maxplayers", "32", "-strictportbind", "-noipx", "-heapsize", "256000", "+sv_lan", "0"]
