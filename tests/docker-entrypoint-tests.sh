#!/usr/bin/env bash

mkdir /var/aegir/tests
cp -rf /var/aegir/tests-source/* tests

bash docker-entrypoint.sh exit

# Run some tests.
cd /var/aegir/tests
composer update
composer install
bin/behat
