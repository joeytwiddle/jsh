#!/bin/sh
data="echo -e \"#!/bin/sh\ndata=\"\$data\"\"\\n\$data"
echo -e "#!/bin/sh\ndata=\"$data\"\n$data"
