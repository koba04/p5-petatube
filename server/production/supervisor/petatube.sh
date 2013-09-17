#!/bin/sh
cd /home/koba04/petatube/app
exec /home/koba04/perl5/perlbrew/perls/perl-5.18.1/bin/carton exec -- start_server --port=9001 \
-- plackup -s Starlet -E production \
--max-workers=3 \
/home/koba04/petatube/app/app.psgi
