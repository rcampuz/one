#!/bin/sh

set -e

# give up after two minutes
TIMEOUT=120

#
# functions
#

. /usr/share/one/supervisor/scripts/lib/functions.sh

#
# run service
#

for envfile in \
    /etc/default/supervisor/sched \
    ;
do
    if [ -f "$envfile" ] ; then
        . "$envfile"
    fi
done

if [ -f /var/lib/one/.one/one_auth ] ; then
    msg "Found one_auth - we can start service"
else
    msg "No one_auth - wait for oned to create it..."
    if ! wait_for_file /var/lib/one/.one/one_auth ; then
        err "Timeout!"
        exit 1
    fi
    msg "File created - continue"
fi

msg "Rotate log to start with an empty one"
/usr/sbin/logrotate -s /var/lib/one/.logrotate.status \
    -f /etc/logrotate.d/opennebula-scheduler || true

msg "Service started!"
exec /usr/bin/mm_sched
