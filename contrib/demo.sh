#!/bin/sh

#ghostplay silent
# ttyrec -e "ghostplay contrib/demo.sh"
# seq2gif -l 3000 -h 32 -w 139 -p win -i ttyrecord -o demo.gif
GP_HOSTNAME=ubuntu
#ghostplay end

shellspec

#ghostplay sleep 3

cd contrib/demo
#ghostplay sleep 1
highlight -l -O xterm256 mylib.sh
#ghostplay sleep 1
highlight -l -O xterm256 spec/demo_spec.sh

#ghostplay sleep 3

shellspec -f d
