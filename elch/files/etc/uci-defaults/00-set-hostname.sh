#!/bin/sh

# hostid already set:
if test ! -e /etc/hostid ;then
  dd if=/dev/urandom count=50 bs=1 | md5sum  | cut -d\  -f 1  > /etc/hostid
fi

mapped_id=$(grep  "$(hostid)" /etc/elchmap | awk '{print $2}')
if [ -n "$mapped_id" ];then
  hn=elch_${mapped_id}
  uci set elchos.core.elchid=${mapped_id}
else
  hn=elch_$(hostid | cut -c1-3 )
fi

uci set system.@system[0].hostname=$hn
uci commit
# add the hostname to /etc/hosts for proftpd to stop whining
sed -i "s/^127\.0\.0\.1.*/127.0.0.1 $hn localhost/" /etc/hosts
rm -f /etc/elchmap
