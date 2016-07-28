What is Aegir?
==============

Aegir is a free and open source hosting system for Drupal, CiviCRM, and Wordpress.

Designed for mass Drupal hosting, Aegir can launch new sites with a single form submission or API call (See [Hosting Services](http://drupal.org/project/hosting_services).

Aegir itself is built on Drupal and Drush, allowing you to tap into the large contributed module community.

For more information, visit aegirproject.org

How to use this image
=====================

## Manual launch:

    $ docker run --name database -d -e MYSQL_ROOT_PASSWORD=12345 mariadb 
    $ docker run --name hostmaster --hostname aegir.local.computer -e MYSQL_ROOT_PASSWORD=12345 --link database:mysql -p 80:80 aegir/hostmaster
    
## docker-compose launch:

  1. Create a docker-compose.yml file:

    ```yml
    version: '2'
    services:
    
      hostmaster:
        image: aegir/hostmaster
        ports:
          - 80:80
        hostname: local.computer
        links:
          - database
        depends_on:
          - database
        environment:
          MYSQL_ROOT_PASSWORD: strongpassword

      database:
        image: mariadb
        environment:
          MYSQL_ROOT_PASSWORD: strongpassword
    ```
  2. run `docker-compose up`.
  
## Important parts:

  - MYSQL_ROOT_PASSWORD: 12345.  This must match for database and hostmaster containers.  If launching in production, choose a secure password.
  - --hostname aegir.local.computer.  The hostname of the container must be set to a fully qualified domain that resolves to the host machine.  *.local.computer resolves to 127.0.0.1, so it is useful to use for launching locally.
  - -p 80:80.  Since this one container is going to host numerous websites for you, it expects to be assigned to port 80 (unless you are hooking up another container like varnish or a load balancer on the same machine.)

# Environment Variables

## AEGIR_CLIENT_NAME 

*Default: admin*

The username of UID1 and the client node.

## AEGIR_CLIENT_EMAIL 
*Default: aegir@aegir.docker*

The email for UID1. The welcome email for user 1 gets sent to this address.

## AEGIR_MAKEFILE
*Defalt: /var/aegir/.drush/provision/aegir.make*

The makefile to use for building the front-end drupal dashboard.  Defaults to hostmaster.

May use https://raw.githubusercontent.com/opendevshop/devshop/1.x/build-devmaster.make to build a devmaster instance.

## AEGIR_PROFILE 
*Default: hostmaster*

The install profile to run for the drupal front-end. Defaults to hostmaster.

May use "devmaster" if you used the devmaster makefile.


# DEVELOPMENT

# Aegir on Docker

This project is an experiment to (finally) get Aegir working *inside* Docker.

This is not a project to get Aegir deploying docker (yet)

An official Aegir docker image will make it really easy to fire up an aegir instance for production or just to try.

This image will also make contributing and testing much, much easier.

## Launching

### Requirements:

 - [Docker](https://docs.docker.com/engine/installation/) & [Docker Compose 2](https://docs.docker.com/compose/install/).

### Launching:

1. Clone this repo:


    git clone git@github.com:jonpugh/aegir-dockerfile.git

2. Change directories into the codeabase.


    cd aegir-dockerfile

3. Edit your `/etc/hosts` file to add the container's hostname, which is set in `docker-compose.yml` (aegir.docker by default).  It must point at your docker host.


    127.0.0.1  aegir.docker  # If running native linux
    192.168.99.100  aegir.docker  # If running on OSx, or using default docker-machine

4. Build the image. (Optional)

  If you made your own changes to the dockerfile, you can build your own image:

    docker build -t aegir/hostmaster -f Dockerfile.ubuntu.14.04 .

4. Run docker compose up.


    docker-compose up

  If this is the first time, it will download the base images and hostmaster will install. If not, the database will be read from the volume as already having installed, so it will just run the drush commands to prepare the server.

  You will see the hostmaster install success output:

      hostmaster_1 | ==============================================================================
      hostmaster_1 |
      hostmaster_1 |
      hostmaster_1 | Congratulations, Aegir has now been installed.
      hostmaster_1 |
      hostmaster_1 | You should now log in to the Aegir frontend by opening the following link in your web browser:
      hostmaster_1 |
      hostmaster_1 | http://aegir.docker/user/reset/1/1468333477/iKwXpRJ7xhHeiPwhiE2oe5UcswlLeS_fZVALR9EvKZg/login
      hostmaster_1 |
      hostmaster_1 |
      hostmaster_1 | ==============================================================================

  Visit that link, but change the port if you had to change it in docker-compose.

  http://aegir.docker:12345/user/reset/1/abscdf....abcde/login

  That's it!

  You can access the container via terminal with docker exec:

        docker exec -ti aegirdocker_hostmaster_1 bash

  Since the user of the container is already set to `aegir`, you can just run "bash".

## Tech Notes

### Developing Dockerfiles

It can be confusing and monotonous to build the image, docker compose up, kill, remove, then rebuild, repeat...

 So I use the following command to ensure fully deleted containers and volumes, a rebuilt image, and a quick exit if things fail (--abort-on-container-exit)

    docker-compose kill ; docker-compose rm -vf ; docker build -t aegir/hostmaster ../ ; docker-compose up --abort-on-container-exit

You only need to run this full command if you change the Dockerfile or the docker-entrypoint-*.sh files.

If you are only changing the docker-compose.yml file, sometimes you can just run:

    docker-compose restart

Or you can kill then up the containers if you need the "CMD" or "command" to run again:

    docker-compose kill; docker-compose up

### Hostnames

The trickiest part of getting Aegir Hostmaster running in docker was the hostname situation. Aegir installs itself based on the servers hostname. This hostname is used for the server nodes and for the drupal front-end,

I've worked around that for now by using a docker-entrypoint.sh file that does the hostmaster installation at run time.

### Services

A stock hostmaster requires mysql, apache and supervisor in order to have a responsive queue. The "docker way" is to separate services out.

I was able to use an external database container for MySQL.

Apache automatically gets started when Hostmaster is verified, so docker-entrypoint.sh doesn't have to do it.

Finally, instead of Supervisor, I realized we could use docker itself to run `drush @hostmaster hosting-queued`, so that is at the end of docker-entrypoint.sh.

Turns out, this results in a REALLY fast Aegir server!

# Next Steps

1. Figure out how to install Hostmaster in the image, then use docker-entrypoint.sh to change the hostname and root mysql password dynamically.
  UPDATES: 
    - If we keep the database as a second container, then hostmaster must always be installed at runtime, because the DB doesn't even exist until then.
    - If we want to release Aegir as a self-contained product, we should think about figuring out how to include everything in one container.  See Rancher Server as an example of this: their container includes a MySQL server: https://github.com/rancher/rancher/tree/master/server
2. Publish to http://hub.docker.com. DONE: https://hub.docker.com/r/aegir/hostmaster/
3. Create multiple tagged versions for various OSes, PHP versions, and Aegir releases.
