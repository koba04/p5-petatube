#!/bin/sh
exec 2>&1
exec /home/vagrant/.anyenv/envs/plenv/versions/5.18.1/bin/start_server --port=9001 -- \
/home/vagrant/.anyenv/envs/plenv/versions/5.18.1/bin/plackup -s Starlet -E development \
--max-workers=3 \
--max-keepalive-reqs=1 \
--max-reqs-per-child=10000 \
-a /home/vagrant/petatube/app.psgi
