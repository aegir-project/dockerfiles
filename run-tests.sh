#!/bin/bash

echo "run-tests.sh | Running composer update..."
composer update

echo "run-tests.sh | Running composer install..."
composer install

echo "run-tests.sh | Running bin/behat..."
bin/behat