#!/bin/sh

#ghostplay silent
# ttyrec -e "ghostplay contrib/demo.sh"
# seq2gif -l 3000 -h 32 -w 139 -p win -i ttyrecord -o demo.gif
# seq2gif -l 3000 -h 19 -w 83 -p win -i ttyrecord -o sns.gif
GP_HOSTNAME=ubuntu
highlight() {
  command highlight -l -O xterm256 --syntax sh
}
#ghostplay end

shellspec

#ghostplay sleep 3

cd contrib/demo

#ghostplay sleep 1

cat mylib.sh | highlight

#ghostplay sleep 1

cat spec/demo_spec.sh | highlight

#ghostplay sleep 3

shellspec -f d
