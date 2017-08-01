FROM aegir/hostmaster:local
USER root
ENV DOCKER_VERSION 1.9.1
ENV DOCKER_COMPOSE_VERSION 1.9.0


# Install the docker client.
RUN wget -q https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION && \
    cp docker-1.9.1 /usr/bin/docker && \
    chmod +x /usr/bin/docker

# Install docker-compose.
RUN  wget -q "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" && \
    cp "docker-compose-$(uname -s)-$(uname -m)" /usr/bin/docker-compose && \
    chmod +x /usr/bin/docker-compose

# Add the docker group and add aegir to it.
ARG DOCKER_GID=1001
RUN addgroup --gid $DOCKER_GID docker
RUN adduser aegir docker

USER aegir