FROM aegir/hostmaster

ENV AEGIR_VERSION 7.x-3.120
ENV PROVISION_VERSION 7.x-3.120
ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir-release.make?h=$AEGIR_VERSION

ENV AEGIR_HOSTMASTER_ROOT /var/aegir/$AEGIR_PROFILE-$AEGIR_VERSION

# Prepare next hostmaster platform.
# This is done in the Dockerfile so that we can ship upgrades with the codebase, then run hostmaster-migrate when a new
# version is detected.

RUN drush make $AEGIR_MAKEFILE $AEGIR_HOSTMASTER_ROOT
RUN drush dl provision-$AEGIR_VERSION --destination=/var/aegir/.drush/commands -y
