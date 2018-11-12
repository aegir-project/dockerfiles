#!/bin/bash

HOSTNAME=`hostname --fqdn`

echo 'ÆGIR | Hello! '
echo 'ÆGIR | When the database is ready, we will install Aegir with the following options:'
echo "ÆGIR | -------------------------"
echo "ÆGIR | Hostname: $HOSTNAME"
echo "ÆGIR | Version: $AEGIR_VERSION"
echo "ÆGIR | Provision Version: $PROVISION_VERSION"
echo "ÆGIR | Database Host: $AEGIR_DATABASE_SERVER"
echo "ÆGIR | Web Server Type: $AEGIR_HTTP_SERVICE_TYPE"
echo "ÆGIR | Makefile: $AEGIR_MAKEFILE"
echo "ÆGIR | Profile: $AEGIR_PROFILE"
echo "ÆGIR | Root: $AEGIR_HOSTMASTER_ROOT"
echo "ÆGIR | Client Name: $AEGIR_CLIENT_NAME"
echo "ÆGIR | Client Email: $AEGIR_CLIENT_EMAIL"
echo "ÆGIR | Working Copy: $AEGIR_WORKING_COPY"
echo "ÆGIR | -------------------------"
echo "ÆGIR | TIP: To receive an email when the container is ready, add the AEGIR_CLIENT_EMAIL environment variable to your docker-compose.yml file."
echo "ÆGIR | -------------------------"
echo 'ÆGIR | Checking /var/aegir...'
ls -lah /var/aegir
echo "ÆGIR | -------------------------"
echo 'ÆGIR | Checking /var/aegir/.drush/...'
ls -lah /var/aegir/.drush
echo "ÆGIR | -------------------------"
echo 'ÆGIR | Checking drush status...'
drush status
echo "ÆGIR | -------------------------"


# Use drush help to determnine if Provision is installed anywhere on the system.
drush help provision-save > /dev/null 2>&1
if [ ${PIPESTATUS[0]} == 0 ]; then
    echo "ÆGIR | Provision Commands found."
else
    echo "ÆGIR | Provision Commands not found! Installing..."
    drush dl provision-$PROVISION_VERSION --destination=/var/aegir/.drush/commands -y
fi

echo "ÆGIR | -------------------------"
echo "ÆGIR | Starting apache2 now to reduce downtime."
sudo apache2ctl graceful

# Returns true once mysql can connect.
# Thanks to http://askubuntu.com/questions/697798/shell-script-how-to-run-script-after-mysql-is-ready
mysql_ready() {
    mysqladmin ping --host=$AEGIR_DATABASE_SERVER --user=root --password=$MYSQL_ROOT_PASSWORD > /dev/null 2>&1
}

while !(mysql_ready)
do
   sleep 3
   echo "ÆGIR | Waiting for database host '$AEGIR_DATABASE_SERVER' ..."
done

echo "ÆGIR | Database active! Checking for Hostmaster Install..."

# Check if @hostmaster is already set and accessible.
drush @hostmaster vget site_name > /dev/null 2>&1
if [ ${PIPESTATUS[0]} == 0 ]; then
  echo "ÆGIR | Hostmaster site found... Checking for upgrade platform..."

  # Only upgrade if site not found in current containers platform.
  if [ ! -d "$AEGIR_HOSTMASTER_ROOT/sites/$HOSTNAME" ]; then
      echo "ÆGIR | Site not found at $AEGIR_HOSTMASTER_ROOT/sites/$HOSTNAME, upgrading!"
      echo "ÆGIR | Running 'drush @hostmaster hostmaster-migrate $HOSTNAME $AEGIR_HOSTMASTER_ROOT -y'...!"
      drush @hostmaster hostmaster-migrate $HOSTNAME $AEGIR_HOSTMASTER_ROOT -y
  else
      echo "ÆGIR | Site found at $AEGIR_HOSTMASTER_ROOT/sites/$HOSTNAME"
  fi

# if @hostmaster is not accessible, install it.
else
  echo "ÆGIR | Hostmaster not found. Continuing with install!"

  echo "ÆGIR | -------------------------"
  echo "ÆGIR | Running: drush cc drush"
  drush cc drush

  echo "ÆGIR | -------------------------"
  echo "ÆGIR | Running: drush hostmaster-install"

  set -ex
  drush hostmaster-install -y --strict=0 $HOSTNAME \
    --aegir_db_host=$AEGIR_DATABASE_SERVER \
    --aegir_db_pass=$MYSQL_ROOT_PASSWORD \
    --aegir_db_port=3306 \
    --aegir_db_user=root \
    --aegir_db_grant_all_hosts=1 \
    --aegir_host=$HOSTNAME \
    --client_name=$AEGIR_CLIENT_NAME \
    --client_email=$AEGIR_CLIENT_EMAIL \
    --http_service_type=$AEGIR_HTTP_SERVICE_TYPE \
    --makefile=$AEGIR_MAKEFILE \
    --profile=$AEGIR_PROFILE \
    --root=$AEGIR_HOSTMASTER_ROOT \
    --working-copy=$AEGIR_WORKING_COPY

fi

sleep 3


# Exit on the first failed line.
set -e

echo "ÆGIR | Running 'drush cc drush' ... "
drush cc drush

echo "ÆGIR | Enabling hosting queued..."
drush @hostmaster en hosting_queued -y

ls -lah /var/aegir

# We need a ULI here because aegir only outputs one on install, not on subsequent verify.
echo "ÆGIR | Getting a new login link ... "
drush @hostmaster uli

echo "ÆGIR | Clear Hostmaster caches ... "
drush cc drush
drush @hostmaster cc all

# Run whatever is the Docker CMD, typically drush @hostmaster hosting-queued
echo "ÆGIR | Running Docker Command '$@' ..."

exec "$@"