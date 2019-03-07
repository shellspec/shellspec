#!/bin/sh

#ghostplay silent
# ttyrec -e "ghostplay contrib/demo.sh"
# seq2gif -l 3000 -h 32 -i ttyrecord -o demo.gif
#ghostplay end

cd contrib/demo
cat mylib.sh
cat spec/demo_spec.sh

#ghostplay sleep 3

shellspec -f d
