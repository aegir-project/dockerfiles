#!/usr/bin/env bash

# The || exit $? is so that this script returns a non-zero exit code if any of the lines fails.

# Prepare hostmaster
bash docker-entrypoint.sh || exit $?

# Run some tests.
echo "Preparing tests..."

if [[ -w /var/aegir/tests ]];
  cd /var/aegir/tests
then
  cp -rf /var/aegir/tests /var/aegir/tests-writable
  cd /var/aegir/tests-writable
fi

composer update     || exit $?
composer install    || exit $?
bin/behat           || exit $?
