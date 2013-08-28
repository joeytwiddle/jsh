# From: http://www.commandlinefu.com/commands/view/148/capture-video-of-a-linux-desktop

# -sameq gives you high quality; remove if you want compression (smaller file, reduced quality)

ffmpeg -f x11grab -r 25 -s `getxwindimensions` -i :0.0 -sameq /tmp/outputFile.mpg

# Capturing audio, compress as x264
#ffmpeg -y -f alsa -ac 2 -i pulse -f x11grab -r 30 -s `xdpyinfo | grep 'dimensions:'|awk '{print $2}'` -i :0.0 -acodec pcm_s16le output.wav -an -vcodec libx264 -threads 0 output.mp4

