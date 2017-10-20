# This Dockerfile is used to change the Aegir user UID to match the host system's user.
# This allows seamless file sharing via docker volumes.

# Use --build-arg option when running docker build to set the desired UID of the "aegir" user.

# Local almost always wants xdebug.
FROM aegir/hostmaster:xdebug

USER root

ARG NEW_UID=1000

RUN echo "Attempting to update aegir UID to $NEW_UID ..."
RUN usermod -u $NEW_UID aegir

RUN echo "Attempting to update aegir GID to $NEW_UID ..."
RUN groupmod -g $NEW_UID aegir

RUN echo "Attempting to change ownership of /var/aegir to $NEW_UID ..."
RUN chown $NEW_UID /var/aegir -R
RUN chgrp $NEW_UID /var/aegir -R

USER aegir