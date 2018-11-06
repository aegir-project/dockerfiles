FROM aegir/hostmaster:php7

USER root

RUN apt-get update && \
  apt-get install php-dev -y -qq

ENV PHP_CONFIG_PATH /etc/php/7.0

RUN yes | pecl install xdebug-2.5.5 \
        && echo "zend_extension=xdebug.so" >> $PHP_CONFIG_PATH/mods-available/xdebug.ini \
        && echo "xdebug.remote_host=172.17.0.1" >> $PHP_CONFIG_PATH/mods-available/xdebug.ini \
        && echo "xdebug.remote_enable=on" >> $PHP_CONFIG_PATH/mods-available/xdebug.ini \
        && echo "xdebug.remote_autostart=off" >> $PHP_CONFIG_PATH/mods-available/xdebug.ini \
        && ln -s $PHP_CONFIG_PATH/mods-available/xdebug.ini $PHP_CONFIG_PATH/apache2/conf.d/00-xdebug.ini \
        && ln -s $PHP_CONFIG_PATH/mods-available/xdebug.ini $PHP_CONFIG_PATH/cli/conf.d/00-xdebug.ini

USER aegir