FROM debian:jessie

RUN echo "deb http://debian.aegirproject.org unstable main" | tee -a /etc/apt/sources.list.d/aegir-unstable.list
RUN echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections
RUN echo "debconf debconf/priority select critical" | debconf-set-selections
RUN echo mysql-server-5.5 mysql-server/root_password password insecurepassword | debconf-set-selections
RUN echo mysql-server-5.5 mysql-server/root_password_again password insecurepassword | debconf-set-selections

RUN apt-get update && apt-get install --yes \
  curl \
  php5-json \

RUN curl http://debian.aegirproject.org/key.asc | apt-key add -

RUN echo "mysql-server-5.5 mysql-server/root_password password insecurepassword" | debconf-set-selections
RUN echo "aegir3-hostmaster aegir/db_password string insecurepassword" | debconf-set-selections
RUN echo "aegir3-hostmaster aegir/db_password seen true"
RUN echo "aegir3-hostmaster aegir/db_user string root" | debconf-set-selections
RUN echo "aegir3-hostmaster aegir/db_host string localhost" | debconf-set-selections
RUN echo "aegir3-hostmaster aegir/email string  aegir@example.com" | debconf-set-selections
RUN echo "aegir3-hostmaster aegir/site  string  aegir.docker" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type select Local only" | debconf-set-selections

RUN apt-get update && apt-get install --yes \ | debconf-set-selections
  aegir3

