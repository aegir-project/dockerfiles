#!/usr/bin/env bash

HOSTNAME=`hostname --fqdn`

sleep 5
echo "Hostname: $HOSTNAME"
echo "Waiting 5 seconds..."

drush hostmaster-install $HOSTNAME --aegir_db_host=database --aegir_db_pass=$MYSQL_ROOT_PASSWORD --aegir_db_port=3306 --aegir_db_user=root --aegir_host=$HOSTNAME -y

# Run the hosting queue
drush @hostmaster en hosting_queued -y
drush @hostmaster hosting-queued