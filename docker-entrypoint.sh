#!/bin/bash

HOSTNAME=`hostname --fqdn`

# Install provision
echo "Installing provision $PROVISION_VERSION..."
drush dl provision-$PROVISION_VERSION --destination=/var/aegir/.drush/commands -y

# Returns true once mysql can connect.
# Thanks to http://askubuntu.com/questions/697798/shell-script-how-to-run-script-after-mysql-is-ready
mysql_ready() {
    mysqladmin ping --host=database --user=root --password=$MYSQL_ROOT_PASSWORD > /dev/null 2>&1
}

while !(mysql_ready)
do
   sleep 3
   echo "waiting for mysql ..."
done

echo "========================="
echo "Hostname: $HOSTNAME"
echo "Database Host: $AEGIR_DATABASE_SERVER"
echo "Makefile: $AEGIR_MAKEFILE"
echo "Profile: $AEGIR_PROFILE"
echo "Version: $AEGIR_VERSION"
echo "Client Name: $AEGIR_CLIENT_NAME"
echo "Client Email: $AEGIR_CLIENT_EMAIL"

echo "-------------------------"
echo "Running: drush hostmaster-install"

# Exit on the first failed line.
set -e

drush cc drush

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

# Output a login link. If hostmaster is already installed, `drush hostmaster-install` doesn't give us a link.
drush @hostmaster uli

# Run the hosting queue
drush @hostmaster en hosting_queued -y

drush cc drush

# Run whatever is the Docker CMD.
`$@`