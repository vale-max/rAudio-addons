#!/bin/bash

alias=plsi

. /srv/http/bash/addons.sh

installstart $@

# all files include sub-directory
files=$( find /var/lib/mpd/playlists -type f 2> /dev/null )
if [[ ! $files ]]; then
	title -l '=' "$info No playlists found."
	title -nt 'Copy *.m3u to /var/lib/mpd/playlists then run again.'
	exit
fi

title -l '=' "$bar Playlist Import ..."

(( $( mpc playlist | wc -l ) > 0 )) && php /srv/http/mpdplaylist.php save _existing
mpc -q clear

readarray -t files <<<"$files"
for file in "${files[@]}"; do
	sed -i 's/^Localstorage/SD/' "$file"
	name=$( basename "$file" .m3u )
	[[ -e "/srv/http/data/playlists/$name" ]] && name="${name}_1"
	
	sed -i 's|\\|/|g' "$file"
	mpc load "$name"
	php /srv/http/mpdplaylist.php save "$name"
done

if [[ -e /srv/http/data/playlists/_existing ]]; then
	mpc -q clear
	php /srv/http/mpdplaylist.php load _existing
	rm /srv/http/data/playlists/_existing
fi

installfinish
