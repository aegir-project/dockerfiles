FROM ubuntu:16.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y -qq\
  apache2 \
  cron \
  curl \
  libpcre3-dev \
  git-core \
  mysql-client \
  postfix \
  rsync \
  sudo \
  unzip \
  vim \
  wget

ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
RUN apt-get update -qq && apt-get install -y -qq\
  software-properties-common

RUN add-apt-repository ppa:ondrej/php && \
    add-apt-repository ppa:ondrej/apache2 && \
    apt-get update -qq

# PHP 7.2
RUN apt-get install -y -qq \
    php7.2 \
    php7.2-cli \
    php7.2-curl \
    php7.2-fpm \
    php7.2-gd \
    php7.2-json \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-sqlite3 \
    php7.2-xml

# PHP 7.1
RUN apt-get install -y -qq \
    php7.1 \
    php7.1-cli \
    php7.1-curl \
    php7.1-fpm \
    php7.1-gd \
    php7.1-json \
    php7.1-mbstring \
    php7.1-mysql \
    php7.1-sqlite3 \
    php7.1-xml

# PHP 7.0
RUN apt-get install -y -qq \
    php7.0 \
    php7.0-cli \
    php7.0-curl \
    php7.0-fpm \
    php7.0-gd \
    php7.0-json \
    php7.0-mbstring \
    php7.0-mysql \
    php7.0-sqlite3 \
    php7.0-xml

# PHP 5.6
RUN apt-get install -y -qq \
    php5.6 \
    php5.6-cli \
    php5.6-curl \
    php5.6-fpm \
    php5.6-gd \
    php5.6-json \
    php5.6-mbstring \
    php5.6-mysql \
    php5.6-sqlite3 \
    php5.6-xml

RUN a2enmod mpm_event proxy_fcgi setenvif

# Use --build-arg option when running docker build to set these variables.
# If wish to "mount" a volume to your host, set AEGIR_UID and AEGIR_GIT to your local user's UID.
# There are both ARG and ENV lines to make sure the value persists.
# See https://docs.docker.com/engine/reference/builder/#/arg
ARG AEGIR_UID=1000
ENV AEGIR_UID ${AEGIR_UID:-1000}

RUN echo "Creating user aegir with UID $AEGIR_UID and GID $AEGIR_GID"

RUN addgroup --gid $AEGIR_UID aegir
RUN adduser --uid $AEGIR_UID --gid $AEGIR_UID --system --shell /bin/bash --home /var/aegir aegir
RUN adduser aegir www-data
RUN a2enmod rewrite
RUN a2enmod ssl
RUN ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf
RUN ln -s /etc/apache2/conf-available/aegir.conf /etc/apache2/conf-enabled/aegir.conf

COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chmod 0440 /etc/sudoers.d/aegir

RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/35ca72b506eba32c0baed4d283a5f834968e5ade/web/installer -O - -q | php -- --quiet
RUN cp composer.phar /usr/local/bin/composer

RUN wget https://github.com/drush-ops/drush/releases/download/8.1.16/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush

# Install fix-permissions and fix-ownership scripts
RUN wget http://cgit.drupalcode.org/hosting_tasks_extra/plain/fix_permissions/scripts/standalone-install-fix-permissions-ownership.sh
RUN bash standalone-install-fix-permissions-ownership.sh

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY run-tests.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-tests.sh

#COPY docker-entrypoint-tests.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/docker-entrypoint-tests.sh

COPY docker-entrypoint-queue.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-queue.sh

# Prepare Aegir Logs folder.
RUN mkdir /var/log/aegir
RUN chown aegir:aegir /var/log/aegir
RUN echo 'Hello, Aegir.' > /var/log/aegir/system.log

# Don't install provision. Downstream tags will do this with the right version.
## Install Provision for all.
#ENV PROVISION_VERSION 7.x-3.x
#RUN mkdir -p /usr/share/drush/commands
#RUN drush dl --destination=/usr/share/drush/commands provision-$PROVISION_VERSION -y
ENV REGISTRY_REBUILD_VERSION 7.x-2.5
RUN drush dl --destination=/usr/share/drush/commands registry_rebuild-$REGISTRY_REBUILD_VERSION -y

USER aegir

RUN mkdir /var/aegir/config
RUN mkdir /var/aegir/.drush

# You may change this environment at run time. User UID 1 is created with this email address.
ENV AEGIR_CLIENT_EMAIL aegir@aegir.local.computer
ENV AEGIR_CLIENT_NAME admin
ENV AEGIR_PROFILE hostmaster
ENV AEGIR_VERSION 7.x-3.x
ENV PROVISION_VERSION 7.x-3.x
ENV AEGIR_WORKING_COPY 0
ENV AEGIR_HTTP_SERVICE_TYPE apache

# Must be fixed across versions so we can upgrade containers.
ENV AEGIR_HOSTMASTER_ROOT /var/aegir/hostmaster

WORKDIR /var/aegir

# The Hostname of the database server to use
ENV AEGIR_DATABASE_SERVER database

# For dev images (7.x-3.x branch)
ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir.make

# For Releases:
# ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir-release.make?h=$AEGIR_VERSION

VOLUME /var/aegir

# docker-entrypoint.sh waits for mysql and runs hostmaster install
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["drush", "@hostmaster", "hosting-queued"]
