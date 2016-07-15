#!/usr/bin/env bash

bash docker-entrypoint.sh exit

# Run some tests.
cd /var/aegir/tests
composer update
composer install
bin/behat
