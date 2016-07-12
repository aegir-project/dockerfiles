#!/usr/bin/env bash

HOSTNAME=`hostname --fqdn`

sleep 5
echo "Hostname: $HOSTNAME"
echo "Waiting 5 seconds..."

drush hostmaster-install $HOSTNAME --aegir_db_host=database --aegir_db_pass=$MYSQL_ROOT_PASSWORD --aegir_db_port=3306 --aegir_db_user=root --aegir_host=$HOSTNAME -y

# Stolen from Apache docker image.
# https://github.com/docker-library/httpd/blob/12bf8c8883340c98b3988a7bade8ef2d0d6dcf8a/2.2/httpd-foreground
set -e

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

exec httpd -DFOREGROUND