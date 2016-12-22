#!/bin/sh

/etc/init.d/uhttpd disable
/etc/init.d/uhttpd stop
/etc/init.d/fstab enable
/etc/init.d/fstab start
