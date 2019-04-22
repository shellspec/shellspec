#!/bin/sh

if [ "${SH% *}" = "busybox" ]; then
  ln -snf /bin/busybox /bin/ash
  SH=${SH#* }
else
  mv /bin/sh /bin/default-shell
  cat <<'HERE' > /bin/sh
#!/bin/default-shell
exec $SH "$@"
HERE
  chmod +x /bin/sh
fi

mkdir -p /usr/local/bin
ln -s $PWD/shellspec /usr/local/bin/shellspec

exec "$@"
