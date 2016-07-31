#!/bin/bash

HOSTNAME=`hostname --fqdn`

# Returns true once @hostmaster hosting_queued module is enabled.
# Thanks to http://askubuntu.com/questions/697798/shell-script-how-to-run-script-after-mysql-is-ready
hostmaster_ready() {
    drush @hostmaster status > /dev/null 2>&1
}

function hostmaster_pm_list_ready() {
    drush @hostmaster pm-list > /dev/null 2>&1
}

function hostmaster_queued_ready() {
    drush @hostmaster pm-list --pipe --type=module --status=enabled --no-core | grep 'hosting_queued' &> /dev/null 2>&1
}

while !(hostmaster_ready)
do
   sleep 5
   echo "waiting for Hostmaster site to come online..."
done

echo "Hostmaster detected!"
echo "waiting for Hostmaster Queue Daemon module to be enabled..."

while !(hostmaster_pm_list_ready)
do
  echo "drush pm-list command failed... waiting."
  sleep 5
done

while !(hostmaster_queued_ready)
do
  sleep 3
  echo "waiting for Hostmaster Queue Daemon module to be enabled..."
done

echo "Hostmaster Queue ready! running drush @hostmaster hosting-queued"

# Run whatever is the Docker CMD.
drush @hostmaster hosting-queued -v