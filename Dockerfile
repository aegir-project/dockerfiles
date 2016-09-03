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

# Use --build-arg option when running docker build to set these variables.
# If wish to "mount" a volume to your host, set AEGIR_UID and AEGIR_GIT to your local user's UID.
# There are both ARG and ENV lines to make sure the value persists.
# See https://docs.docker.com/engine/reference/builder/#/arg
ARG AEGIR_UID=12345
#ENV AEGIR_UID ${AEGIR_UID:-12345}

ARG AEGIR_GID=12345
#ENV AEGIR_GID ${AEGIR_GID:-12345}

RUN echo "Creating user aegir with UID $AEGIR_UID and GID $AEGIR_GID"

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

# Install the docker client into the container.
RUN wget -q https://get.docker.com/builds/Linux/x86_64/docker-1.9.1 && \
    cp docker-1.9.1 /usr/bin/docker && \
    chmod +x /usr/bin/docker

# Add the docker group and add aegir to it.
ARG DOCKER_GID=1001
RUN addgroup --gid $DOCKER_GID docker
RUN adduser aegir docker

USER aegir

# You may change this environment at run time. User UID 1 is created with this email address.
ENV AEGIR_CLIENT_EMAIL aegir@aegir.docker
ENV AEGIR_CLIENT_NAME admin
ENV AEGIR_PROFILE hostmaster
ENV AEGIR_VERSION 7.x-3.x
ENV PROVISION_VERSION 7.x-3.x
WORKDIR /var/aegir

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