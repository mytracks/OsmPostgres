#!/bin/sh

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

su -c '/usr/pgsql-9.5/bin/pg_ctl -D /home/pgdata/osm start' postgres
sleep 5 

if [ ! -f /etc/osm_import_complete ]; then
  curl $OSM_FILE > file.osm.bz2 && /usr/local/bin/osm2pgsql -m --slim --flat-nodes flat.nodes --drop --cache 6000 --number-processes 4 -d gis file.osm.bz2 -U gis && touch /etc/osm_import_complete
  rm -f flat.nodes
  rm -f file.osm.bz2
fi

if [ -f /etc/osm_import_complete ]; then
  sleep infinity
fi

# stop service and clean up here
su -c '/usr/pgsql-9.5/bin/pg_ctl -D /home/pgdata/osm stop' postgres

echo "exited $0"
