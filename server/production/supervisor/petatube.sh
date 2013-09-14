#!/bin/sh
cd /home/vagrant/petatube/app
exec 2>&1
exec /home/koba04/perl5/perlbrew/perls/perl-5.18.1/bin/carton exec -- start_server --port=9001 \
-- plackup -s Starlet -E production \
--max-workers=3 \
--max-keepalive-reqs=1 \
--max-reqs-per-child=10000 \
/home/koba04/work/p5-petatube/app/app.psgi
