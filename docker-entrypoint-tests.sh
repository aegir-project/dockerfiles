#!/usr/bin/env bash

# The || exit $? is so that this script returns a non-zero exit code if any of the lines fails.

# Prepare hostmaster
bash docker-entrypoint.sh || exit $?

# Run some tests.
cd /var/aegir/tests || exit $?
composer update     || exit $?
composer install    || exit $?
bin/behat           || exit $?
