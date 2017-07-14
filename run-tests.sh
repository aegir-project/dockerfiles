#!/bin/bash

set -e

# If /var/aegir/tests does't already exist, clone it.
echo "run-tests.sh | Starting run-tests.sh..."

if [ ! -d /var/aegir/tests ]; then
  echo "run-tests.sh | /var/aegir/tests not found.  Cloning... "
  git clone https://github.com/aegir-project/tests.git /var/aegir/tests
fi

cd /var/aegir/tests

echo "run-tests.sh | Running composer update..."
composer update

echo "run-tests.sh | Running composer install..."
composer install

echo "run-tests.sh | Running bin/behat..."
bin/behat