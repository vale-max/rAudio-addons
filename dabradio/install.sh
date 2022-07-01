#!/bin/bash

. /srv/http/bash/addons.sh

installstart "$1"

curl -sL https://github.com/vale-max/rAudio-addons/raw/main/dabradio/dabradio.tar.xz | bsdtar xvf - -C /
pacman --noconfirm -Sy rtl-sdr gcc-libs
[[ -e /etc/rtsp-simple-server.yml ]] || cp /usr/lib/dab-subsystem/rtsp-simple-server.yml_start /etc/rtsp-simple-server.yml
systemctl daemon-reload
systemctl enable --now rtsp-simple-server
chown -R http:http /srv/http/data/webradios*
count=$( find -L $dirdata/webradios -type f | wc -l )
sed -i 's/\("webradio": \).*/\1'$count'/' /srv/http/data/mpd/counts

installfinish
