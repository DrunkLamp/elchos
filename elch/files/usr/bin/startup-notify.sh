#!/bin/sh
. /lib/functions/network.sh
set -ef
sleep 10
network_get_ipaddr ip wan

while test -z "$ip"; do
	sleep 1
	network_flush_cache
	network_get_ipaddr ip wan
done

# refresh logip
hn=log.nsupdate.info
logip=$(nslookup $hn | grep -A1 $hn | grep Address | cut -d\  -f 3)
uci set system.@system[0].log_ip=${logip}
uci commit
logger "refreshing log_ip: ${logip}"
/etc/init.d/log restart
/etc/init.d/cron restart

# announce
ext_ip=$(wget -qO- http://ipv4.nsupdate.info/myip)
irc-announce "Why hello there, this is $HOSTNAME. My WAN ip is $ip, my external ip is $ext_ip. Running elchOS version $(uci get elchos.core.version)@$(uci get elchos.core.builddate)"
