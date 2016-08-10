#!/usr/bin/env bash

# Exit on the first failed line.
set -e

echo '----------------------------'
echo '  /var/aegir   '
ls -la /var/aegir

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
