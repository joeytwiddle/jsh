#include <stdio.h>
void main(int argc,char **argv) {
  if (argc<=1)
    printf("makechat <isp name> : no <isp name> provided!\n");
  else {
    char *isp=argv[1];
    char com[64];
    int i=sprintf(com,"cp /etc/ppp/chat-script.%s /etc/ppp/chat-script\n",isp);
    system(com);
    printf("makechat: chat-script.%s\n",isp);
  }
}
