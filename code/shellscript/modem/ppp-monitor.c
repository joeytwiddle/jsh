// Please let Joey know if this is a security risk!
// Shell scripts are illegal under Linux.
// This requires trusting tail and grep I suppose.

#include <stdio.h>
void main() {
  system("/usr/bin/tail -f /var/log/messages | /bin/grep -E \"pppd|PPP|chat\"");
}
