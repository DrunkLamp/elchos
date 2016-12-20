#!/bin/sh
hn=log.nsupdate.info
uci set system.@system[0].log_remote=true

logip=$(nslookup $hn | grep -A1 $hn | grep Address | cut -d\  -f 3)
uci set system.@system[0].log_ip=${logip:-127.0.0.1}
