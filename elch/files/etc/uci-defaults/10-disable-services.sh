#!/bin/sh

## config dnsmasq
##   option rebind_protection '0'
# or:
/etc/init.d/dnsmasq stop
/etc/init.d/dnsmasq disable

# we start collectd manually
/etc/init.d/collectd disable
