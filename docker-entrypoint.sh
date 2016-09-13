#!/bin/bash

HOSTNAME=`hostname --fqdn`

echo 'ÆGIR | Hello! '
echo 'ÆGIR | When the database is ready, we will install Aegir with the following options:'
echo "ÆGIR | -------------------------"
echo "ÆGIR | Hostname: $HOSTNAME"
echo "ÆGIR | Database Host: $AEGIR_DATABASE_SERVER"
echo "ÆGIR | Makefile: $AEGIR_MAKEFILE"
echo "ÆGIR | Profile: $AEGIR_PROFILE"
echo "ÆGIR | Version: $AEGIR_VERSION"
echo "ÆGIR | Client Name: $AEGIR_CLIENT_NAME"
echo "ÆGIR | Client Email: $AEGIR_CLIENT_EMAIL"
echo "ÆGIR | -------------------------"
echo "ÆGIR | TIP: To receive an email when the container is ready, add the AEGIR_CLIENT_EMAIL environment variable to your docker-compose.yml file."
echo "ÆGIR | -------------------------"
echo 'ÆGIR | Checking /var/aegir...'
ls -lah /var/aegir
echo "ÆGIR | -------------------------"
echo 'ÆGIR | Checking /var/aegir/.drush/...'
ls -lah /var/aegir/.drush
echo "ÆGIR | -------------------------"


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

echo "ÆGIR | Database active! Commencing Hostmaster Install..."
echo "ÆGIR | -------------------------"
echo "ÆGIR | Running: drush cc drush "
drush cc drush

echo "ÆGIR | -------------------------"
echo "ÆGIR | Running: drush hostmaster-install"
drush hostmaster-install -y --strict=0 $HOSTNAME \
  --aegir_db_host=$AEGIR_DATABASE_SERVER \
  --aegir_db_pass=$MYSQL_ROOT_PASSWORD \
  --aegir_db_port=3306 \
  --aegir_db_user=root \
  --aegir_host=$HOSTNAME \
  --client_name=$AEGIR_CLIENT_NAME \
  --client_email=$AEGIR_CLIENT_EMAIL \
  --makefile=$AEGIR_MAKEFILE \
  --profile=$AEGIR_PROFILE \
  --version=$AEGIR_VERSION

  # The option "version" in this command simply defines the folder that the
  # platform is placed in.
  #
  #   /var/aegir/$AEGIR_PROFILE-$AEGIR_VERSION becomes
  #   /var/aegir/hostmaster-7.x-3.x
  #
  # Since we are using docker volumes, and we don't yet have a
  # strategy for using hostmaster-migrate for upgrades, we are hard coding the
  # AEGIR_VERSION to 'docker' to simplify the upgrade process.

# Exit on the first failed line.
set -e

echo "ÆGIR | -------------------------"
echo "ÆGIR | Enabling Hosting Task Queue..."
drush @hostmaster en hosting_queued -y

echo "ÆGIR | -------------------------"
echo "ÆGIR | Hostmaster Log In Link:  "
drush @hostmaster uli

echo "ÆGIR | Running: drush cc drush "
drush cc drush

# Run whatever is the Docker CMD.
echo "ÆGIR | -------------------------"
echo "ÆGIR | Running $@ ..."
`$@`