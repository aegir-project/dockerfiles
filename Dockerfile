FROM ubuntu:14.04

RUN apt-get update -qq && apt-get install -y -qq\
  apache2 \
  php5 \
  php5-cli \
  php5-gd \
  php5-mysql \
  php-pear \
  php5-curl \
  postfix \
  sudo \
  rsync \
  git-core \
  unzip \
  wget \
  mysql-client
ARG AEGIR_UID=12345
ENV AEGIR_UID ${AEGIR_UID:-12345}

ARG AEGIR_GID=12345
ENV AEGIR_GID ${AEGIR_GID:-12345}

RUN addgroup --gid $AEGIR_GID aegir
RUN adduser --uid $AEGIR_UID --gid $AEGIR_GID --system --home /var/aegir aegir
RUN adduser aegir www-data
RUN a2enmod rewrite
RUN ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf
RUN ln -s /etc/apache2/conf-available/aegir.conf /etc/apache2/conf-enabled/aegir.conf

COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chmod 0440 /etc/sudoers.d/aegir

RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- --quiet
RUN cp composer.phar /usr/local/bin/composer

RUN wget http://files.drush.org/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY docker-entrypoint-tests.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-tests.sh

COPY docker-entrypoint-queue.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-queue.sh

# Prepare Aegir Logs folder.
RUN mkdir /var/log/aegir
RUN chown aegir:aegir /var/log/aegir
RUN echo 'Hello, Aegir.' > /var/log/aegir/system.log

USER aegir

# You may change this environment at run time. User UID 1 is created with this email address.
ENV AEGIR_CLIENT_EMAIL aegir@aegir.docker
ENV AEGIR_CLIENT_NAME admin
ENV AEGIR_PROFILE hostmaster
ENV AEGIR_VERSION 7.x-3.x
ENV PROVISION_VERSION 7.x-3.x

# The Hostname of the database server to use
ENV AEGIR_DATABASE_SERVER database

# For dev images (7.x-3.x branch)
ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir.make

# For Releases:
# ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir-release.make?h=$AEGIR_VERSION

VOLUME /var/aegir

# This isn't working, I think because /var/aegir is set as a volume.
# I've moved it bak to the docker-entrypoint.sh which allows us to dynamially set the version as an environment variable.
# Since we have to wait for the MySQL container to initiate also, this does not result in any further delay.

# Install Provision
#RUN mkdir -p /var/aegir/.drush/commands
#RUN drush dl --destination=/var/aegir/.drush/commands provision-$PROVISION_VERSION -y
#RUN drush cc drush

# Prepare hostmaster platform.
# RUN drush make $AEGIR_MAKEFILE /var/aegir/$AEGIR_PROFILE-$AEGIR_VERSION

# docker-entrypoint.sh waits for mysql and runs hostmaster install
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["drush @hostmaster hosting-queued"]