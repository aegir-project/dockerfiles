#!/usr/bin/env bash

# Exit on the first failed line.
set -e

# Copy provision source, if it exists.
if [ -d /source/provision ]; then
  mkdir -p /var/aegir/.drush/commands
  echo "Copying Provision from /source/provision"
  cp -rf /source/provision /var/aegir/.drush/commands/provision
fi

# Build hostmaster from source, if it exists
if [ -d /source/hostmaster ]; then
  drush make http://cgit.drupalcode.org/provision/plain/aegir.make?h=$AEGIR_VERSION /var/aegir/hostmaster-$AEGIR_VERSION

  # Copy hostmaster source into codebase.
  cp -rf /source/hostmaster/* /var/aegir/hostmaster-$AEGIR_VERSION/profiles/hostmaster
fi

# Prepare hostmaster
bash docker-entrypoint.sh

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
