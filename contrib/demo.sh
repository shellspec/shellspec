#!/bin/sh

#ghostplay silent
# ttyrec -e "ghostplay contrib/demo.sh"
# seq2gif -l 5000 -h 32 -w 139 -p win -i ttyrecord -o demo.gif
# seq2gif -l 5000 -h 19 -w 83 -p win -i ttyrecord -o sns.gif
GP_HOSTNAME=ubuntu
highlight() {
  command highlight -l -O xterm256 --syntax "$1"
}
#ghostplay end

shellspec

#ghostplay sleep 3

# parallel execution
shellspec --jobs 4

#ghostplay sleep 3

cd contrib/demo

#ghostplay sleep 1

cat spec/demo_spec.sh | highlight sh

#ghostplay sleep 3

shellspec --dry-run --format documentation

#ghostplay sleep 5

# coverage and generate junit xml
shellspec --kcov --output junit

#ghostplay sleep 5

cat report/results_junit.xml | highlight xml


