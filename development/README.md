Aegir Development Environment
=============================

The files in this folder can be used to launch an aegir development environment.

It differs in the stock aegir container in that the volume mount is set to this folder and we pre-populate the codebase with git repos for easy editing.

The docker-compose.yml file in this folder will launch a running aegir hostmaster stack.

## Setup

0. Install pre-requisites:
  - git
  - drush (locally, for building the stack).
  - docker
  - docker-compose

1. Clone this repo and enter the 'development' folder:


    git clone http://github.com/jonpugh/aegir-docker
    cd aegir-docker

2. Build the base aegir image:


    docker build -t aegir -f Dockerfile.ubuntu-14.04 .


3. Run the `prepare-host.sh` script.


    bash prepare-host.sh


  This script does the following:

  - Creates an "aegir" folder and opens permissions. This maps to `/var/aegir` in the container.
  - Builds a hostmaster stack with the aegir.make file and uses "working copy" so all sub projects are git clones.
  - Clones provision and registry rebuild into the .drush folder.

4. Set /etc/hosts file for aegir.docker and any domains you will end up using:


    127.0.0.1  aegir.docker  # If running native linux
    192.168.99.100  aegir.docker  # If running on OSx, or using default docker-machine

4. Run `docker-compose up`:

  This will download and launch mysql and aegir containers.

  The hostmaster installation takes place during the `up` phase. Wait for a login link.

  Once running, you can edit the files in ./aegir/hostmaster-7.x-3.x and get live when loading the site at http://aegir.docker:43917/