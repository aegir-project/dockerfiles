FROM aegir/hostmaster:dev

USER root

RUN apt-get update && \
  apt-get install php5-dev -y -qq

RUN yes | pecl install xdebug-2.5.5 \
        && echo "zend_extension=xdebug.so" >> /etc/php5/mods-available/xdebug.ini \
        && echo "xdebug.remote_host=172.17.0.1" >> /etc/php5/mods-available/xdebug.ini \
        && echo "xdebug.remote_enable=on" >> /etc/php5/mods-available/xdebug.ini \
        && echo "xdebug.remote_autostart=off" >> /etc/php5/mods-available/xdebug.ini \
        && ln -s /etc/php5/mods-available/xdebug.ini /etc/php5/apache2/conf.d/00-xdebug.ini \
        && ln -s /etc/php5/mods-available/xdebug.ini /etc/php5/cli/conf.d/00-xdebug.ini

USER aegir