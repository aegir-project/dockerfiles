#!/usr/bin/env bash

bash docker-entrypoint.sh exit

# Run the outstanding hosting-tasks
drush @hostmaster hosting-tasks

# Run some tests.
cd /var/aegir/tests
composer update
composer install
bin/behat
