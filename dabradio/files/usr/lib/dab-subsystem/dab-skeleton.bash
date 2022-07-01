#!/bin/bash
RADIO_LIST="/usr/lib/dab-subsystem/dabradios.txt"
BASE_YML="/usr/lib/dab-subsystem/rtsp-simple-server.yml_start"
NEW_YML="/etc/rtsp-simple-server.yml"
MYNAME=$(hostname -f)

#Create DAB subdir if not existing 
if [ ! -d /srv/http/data/webradios/DAB ]; 
   then 
   mkdir /srv/http/data/webradios/DAB
fi

/usr/bin/dab-scanner-rtlsdr -F $RADIO_LIST

#this is needed to consider the lowercase accented chars outside of "alnum"
LC_CTYPE=C

trim() {
    local var="$*"
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

readarray -t services < $RADIO_LIST
cp $BASE_YML $NEW_YML
rm -f /srv/http/data/webradios/DAB/rtsp\:\|\|$MYNAME\:8554*
rm -f /srv/http/data/webradiosimg/rtsp\:\|\|$MYNAME\:8554*
for service in "${services[@]}"; do
   if grep -q "^audioservice" <<< $service; then
      readarray -d ';' -t field <<< $service
      service_name=$(trim "${field[1]}")
      service_chan=$(trim "${field[2]}")
      service_id=$(trim "${field[3]}")
      legal_nameU=${service_name//[^[:alnum:]]/_}
#rtsp simple server does not like all uppercase service names neither all numbers names
      legal_name=${legal_nameU,,}
      if [ "$legal_name" -eq "$legal_name" ] 2>/dev/null; then
         legal_name=R${legal_name}
      fi
      #echo "$service_name" legale $legal_name su canale "$service_chan"
      #add services to rtsp daemon config file      
#    "runOnDemand: dab-rtlsdr-3 -P \""$service_name"\" -C "$service_chan'|ffmpeg -re -ar 48000 -ac 2 -f s16le  -i - -vn -c:a mp3 -f rtsp rtsp://localhost:$RTSP_PORT/$RTSP_PATH'
#    runOnDemand: dab-rtlsdr-3 -P "$service_name" -C $service_chan|ffmpeg -re -ar 48000 -ac 2 -f s16le  -i - -vn -c:a aac -b:a 160k -f rtsp rtsp://localhost:\$RTSP_PORT/\$RTSP_PATH

cat <<EOT >>$NEW_YML
  $legal_name:
    runOnDemand: /usr/lib/dab-subsystem/dabstart.bash $service_id $service_chan  \$RTSP_PORT \$RTSP_PATH
    runOnDemandRestart: yes
    runOnDemandStartTimeout: 15s
    runOnDemandCloseAfter: 3s
EOT
echo "$service_name" >/srv/http/data/webradios/DAB/rtsp\:\|\|${MYNAME}\:8554\|$legal_name
ln -s /srv/http/data/webradiosimg/dablogo.jpg /srv/http/data/webradiosimg/rtsp\:\|\|$MYNAME\:8554\|${legal_name}.jpg
ln -s /srv/http/data/webradiosimg/dablogo-thumb.jpg /srv/http/data/webradiosimg/rtsp\:\|\|$MYNAME\:8554\|${legal_name}-thumb.jpg

echo fatto per $legal_name
   fi
done
#updates webradios count
chown -R http:http /srv/http/data/webradios*
count=$( find -L /srv/http/data/webradios -type f | wc -l )
sed -i 's/\("webradio": \).*/\1'$count'/' /srv/http/data/mpd/counts
