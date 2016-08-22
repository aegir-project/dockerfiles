#!/usr/bin/env bash

# Exit on the first failed line.
set -e

# Copy provision source, if it exists.
if [ -f /source/provision/provision.drush.inc ]; then
  mkdir -p /var/aegir/.drush/commands
  echo "Copying Provision from /source/provision"
  cp -rf /source/provision /var/aegir/.drush/commands/provision
fi

# Prepare hostmaster
exec "docker-entrypoint.sh"

# Run some tests.
echo "Preparing tests..."

if [[ -w /var/aegir/tests ]];
  cd /var/aegir/tests
then
  cp -rf /var/aegir/tests /var/aegir/tests-writable
  cd /var/aegir/tests-writable
fi

composer update
composer install
bin/behat
