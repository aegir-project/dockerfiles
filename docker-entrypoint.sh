#!/usr/bin/env bash

HOSTNAME=`hostname --fqdn`

# Returns true once mysql can connect.
mysql_ready() {
	mysqladmin ping --host=database --user=root --password=MYSQL_ROOT_PASSWORD > /dev/null 2>&1
}

while !(mysql_ready)
do
   sleep 3
   echo "waiting for mysql ..."
done

echo "========================="
echo "Hostname: $HOSTNAME"
echo "Running: drush hostmaster-install"

drush hostmaster-install $HOSTNAME --aegir_db_host=database --aegir_db_pass=$MYSQL_ROOT_PASSWORD --aegir_db_port=3306 --aegir_db_user=root --aegir_host=$HOSTNAME -y

# Run the hosting queue
drush @hostmaster en hosting_queued -y
drush @hostmaster hosting-queued