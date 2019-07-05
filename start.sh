#!/bin/bash
/etc/rc.d/init.d/nagios start
/usr/sbin/httpd -k start
tail -f /var/log/httpd/access_log /var/log/httpd/error_log
