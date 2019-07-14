#!/bin/sh

# Replace /bin/sh to target shell to easy test.

if [ "${SH% *}" = "busybox" ]; then
  # Avoid unsupported busybox 0.60.5 freeze
  busybox ash -c 'busybox ash -c false' && exit 1

  ln -snf /bin/busybox /bin/ash
  rm /bin/sh
  echo '#!/bin/ash' > /bin/sh
else
  mv /bin/sh /bin/default-shell
  echo '#!/bin/default-shell' > /bin/sh
fi
echo 'exec $SH "$@"' >> /bin/sh
chmod +x /bin/sh

mkdir -p /usr/local/bin
ln -s $PWD/shellspec /usr/local/bin/shellspec

if [ "$1" = "shellspec" ]; then
  shellspec --task fixture:stat:prepare
fi
"$@"
