#!/bin/sh
cd /home/vagrant/petatube/app
exec 2>&1
exec /home/vagrant/.anyenv/envs/plenv/versions/5.18.1/bin/carton exec -- start_server --port=9001 \
-- plackup -s Starlet -E development \
--max-workers=3 \
--max-keepalive-reqs=1 \
--max-reqs-per-child=10000 \
/home/vagrant/petatube/app/app.psgi
