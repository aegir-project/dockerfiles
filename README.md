What is Aegir?
==============

Aegir is a free and open source hosting system for Drupal, CiviCRM, and Wordpress.

Designed for mass Drupal hosting, Aegir can launch new sites with a single form submission or API call (See [Hosting Services](http://drupal.org/project/hosting_services).

Aegir itself is built on Drupal and Drush, allowing you to tap into the large contributed module community.

For more information, visit aegirproject.org

How to use this image
=====================

This image requires a database server, and uses the MYSQL_ROOT_PASSWORD environment variable to install.

    $ docker run --name my_hostmaster --link database:mysql -d  -e MYSQL_ROOT_PASSWORD -p 80:80 aegir/hostmaster


# DEVELOPMENT

# Aegir on Docker

This project is an experiment to (finally) get Aegir working *inside* Docker.

This is not a project to get Aegir deploying docker.

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

4. Build the image. (This won't be needed once we publish.)


    docker build -t aegir -f Dockerfile.ubuntu.14.04 .

4. Run docker compose up.


    docker-compose up

  If this is the first time, hostmaster will install. If not, the database will be read from the volume as already having installed, so it will just run the drush commands to prepare the server.

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

  Visit that link, but change the port to 12345. This is set in the docker-compose.yml file. You may change it if you wish.

  http://aegir.docker:12345/user/reset/1/abscdf....abcde/login

  That's it!

  You can access the container via terminal with docker exec:

        docker exec -ti aegirdocker_hostmaster_1 bash

  Since the user of the container is already set to `aegir`, you can just run "bash".

## Tech Notes

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
