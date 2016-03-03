#!/bin/sh

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

su -c '/usr/pgsql-9.5/bin/pg_ctl -D /home/pgdata/osm start' postgres
sleep 20

if [ ! -f /etc/osm_import_complete ]; then
  cd ~/osm2pgsql
  curl -O http://planet.osm.org/planet/planet-latest.osm.bz2
  /usr/local/bin/osm2pgsql -m --slim --flat-nodes flat.nodes --drop --cache 6000 --number-processes 4 -d gis planet-latest.osm.bz2 -U gis
  touch /etc/osm_import_complete
  rm flat.nodes
  rm planet-latest.osm.bz2
fi

sleep infinity

# stop service and clean up here
su -c '/usr/pgsql-9.5/bin/pg_ctl -D /home/pgdata/osm stop' postgres

echo "exited $0"
