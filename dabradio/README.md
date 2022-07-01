files needed in the webradio archive:
tar cJvf dabradio.tar.xz /usr/lib/dab-subsystem/ /usr/lib/systemd/system/rtsp-simple-server.service /usr/bin/dab-rtlsdr-3 /usr/bin/dab-scanner-rtlsdr /usr/bin/rtsp-simple-server /srv/http/data/webradiosimg/dablogo*

the modifications to the rAudio files are in repo https://github.com/vale-max/rAudio-1.git 

to compile the dab tools for other platforms that raspi4 64bit

install
pacman -S base-devel rtl-sdr fftw git cmake

clone repo https://github.com/vale-max/dab-cmdline.git

compile dab-scanner and example-3:

cd dab-cmdline/dab-scanner
mkdir build
cd build
cmake .. -DRTLSDR=ON

same for dab-cmdline/example-3

copy dab-scanner-rtlsdr and dab-rtlsdr-3 to /usr/bin

get rtsp-simple-server from https://github.com/aler9/rtsp-simple-server and
copy to /usr/bin



the flow is:
rtsp-simple-server starts at boot
dab-scanner from dab-cmdline is used to scan (on demand) the available channels and create a list on txt file.
Syntax: dab-scanner -F dabradios.txt

UPDATE: dab channel scan has been added to dab-skeleton.bash script

Once the file is created a script, I called it dab-skeleton.bash, parses the channel list and
1 - creates a webradio file for each channel found
2 - adds a path configuration stanza to a base rtsp-simple-server file and puts it in /etc

When one of these "webradios" is played and opens the stream, rtsp-simple-server starts "dabstart.bash" with the appropriate parameters.
dabstart.bash launches dab-rtlsdr-3 which tunes to the requested channel and streams the audio to rtsp-simple-server which forwards it.
dab-rtlsdr-3 also can save the radio dynamic label and the current slide (if present) to a couple of files that could be used as title and album art.

As the music is stopped the rtsp server sees the connection is closed and stops the dab tuner.
What is not optimal in this process is that the aac frames in DAB+ are not standard and can't be decoded directly by ffmpeg, so they are decoded to raw pcm by the dab tuner program and this pcm is then fetched to ffmpeg to reencode it in a format understandable to mpd.

I haven't found a way to stream the raw pcm or the same pcm in wav or other lossless formats.

about the advantages over internet radio, first of all it does not need internet, so if you have your sound system somewhere without connection you can listen the radio anyways, second you don't have to add the services one by one (in Rome for example there are around 130 DAB radio channels available) and, last but not least, no other player has it as far as I know.

