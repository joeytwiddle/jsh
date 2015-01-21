# @sourceme

if test "$3x" = "x"; then
  echo "soundcardinit <baseio> <irq> <dma>"
  exit 1
fi

IO="$1"
IRQ="$2"
DMA="$3"

cat /root/pnpdump.txt |
  replaceline "# IOsetting"  "(IO 0 (SIZE 8) (BASE 0x0$IO))" |
  replaceline "# IRQsetting" "(INT 0 (IRQ $IRQ (MODE +E)))" |
  replaceline "# DMAsetting" "(DMA $DMA (CHANNEL 0))" > /root/pnpdump2.txt
  
/sbin/rmmod ad1848
/sbin/rmmod mpu401
/sbin/rmmod sound
/sbin/rmmod soundcore
/sbin/rmmod soundlow

isapnp /mnt/pod2/etc/isapnp.conf
# isapnp /root/pnpdump2.txt
# isapnp /etc/isapnp.conf
# isapnp /root/pnpdump.txt

/sbin/insmod -L soundcore
/sbin/insmod -L soundlow
/sbin/insmod -L sound dmabuf=$DMA # used to be 1
/sbin/modprobe sb io=0x$IO irq=$IRQ dma=$DMA # soundpro=1
#/sbin/insmod -L ad1848 io=0x$IO irq=$IRQ dma=$DMA # soundpro=1
#/sbin/insmod -L mpu401 io=0x330 irq=9

/sbin/modprobe sound
# /sbin/modprobe midi
/sbin/modprobe -s -k synth0

aumix -v50

nice -n -15 mpg123 -v $JPATH/tracks/test.mp3
