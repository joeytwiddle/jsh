# export DISPLAY=:0
# br=8 PREVIEW="-ss 0:00:00 -endpos 02:00"

# URL='rtsp://rmv8.bbc.net.uk/news/olmedia/n5ctrl/progs/question_time/latest.rm?start="00:00.0"'
# URL='rtsp://rmv8.bbc.net.uk/news/olmedia/n5ctrl/tvseq/news_ost/bb_news10.rm?start="00:00.0"'
URL='rtsp://rmv8.bbc.net.uk/news/olmedia/n5ctrl/progs/panorama/latest.rm?start="00:00.0"'

# mencoder rtsp://rmv8.bbc.net.uk/news/olmedia/n5ctrl/progs/question_time/latest.rm?start="00:00.0" -o question_time.rm -oac mp3lame -lameopts br=8 -ovc lavc $PREVIEW # -lavcopts abitrate=8:acodec=mp2
mencoder "$URL" -o panorama.rm -oac pcm -ovc lavc $PREVIEW # -lavcopts abitrate=8:acodec=mp2
# -vf pp=de/hb/vb/dr/al/lb/tn:1:2:3
# mencoder "./dune - original movie - directors cut.avi" -o "preview-1.avi" -oac copy -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=117105:vhq:vpass=1:vqmin=2:vqmax=10 -ss 0:19:00 -endpos 02:30 -vf scale=618:432,pp=de/hb/vb/dr/al/lb/tn:1:2:3 -ni -nobps -mc 1
