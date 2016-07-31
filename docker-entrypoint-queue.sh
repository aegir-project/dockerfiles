#!/bin/bash

HOSTNAME=`hostname --fqdn`

# Returns true once @hostmaster
# Thanks to http://askubuntu.com/questions/697798/shell-script-how-to-run-script-after-mysql-is-ready
hostmaster_ready() {
    drush @hostmaster status > /dev/null 2>&1
}

while !(hostmaster_ready)
do
   sleep 3
   echo "waiting for hostmaster ..."
done

echo "Hostmaster ready! running drush @hostmaster hosting-queued"

# Run whatever is the Docker CMD.
drush @hostmaster hosting-queued -v --debug