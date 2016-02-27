#!/bin/sh

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

su -c '/usr/pgsql-9.5/bin/pg_ctl -D /home/pgdata/osm start' postgres
sleep 20

if [ ! -f /etc/osm_import_complete ]; then
  cd ~/osm2pgsql
  curl -O http://download.geofabrik.de/europe/germany/hamburg-latest.osm.pbf
  /usr/local/bin/osm2pgsql -m --slim --flat-nodes flat.nodes --drop --cache 6000 --number-processes 4 -d gis *.osm.* -U gis
  rm flat.nodes
  touch /etc/osm_import_complete
fi

sleep infinity

# stop service and clean up here
su -c '/usr/pgsql-9.5/bin/pg_ctl -D /home/pgdata/osm stop' postgres

echo "exited $0"
