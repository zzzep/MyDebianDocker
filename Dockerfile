FROM ulsmith/debian-apache-php
MAINTAINER Giuseppe Fechio <giuseppe.fechio@hotmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN pwd
RUN ls -lha

# Add my_init script and help scripts 
ADD bin/my_init /
ADD bin/my_service /
RUN chmod +x /my_*

# Set environment variables.
ENV HOME /root

## Install base packages
RUN apt-get upgrade
RUN apt-get update 
#RUN apt-get -yq install \
#		apache2 \
#		php5 \
#		libapache2-mod-php5 \
#		curl \
#		ca-certificates \
#		php5-curl \
#		php5-json \
#		php5-odbc \
#		php5-sqlite \
#		php5-mysql \
#		php5-mcrypt && \
#	apt-get clean && \
#    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archive/*.deb

RUN /usr/sbin/php5enmod mcrypt && a2enmod rewrite && mkdir -p /bootstrap

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
ADD start.sh /bootstrap/start.sh
RUN chmod 755 /bootstrap/start.sh && chown -R www-data:www-data /var/www/html

RUN apt-get install net-tools
RUN apt-get install -y openssh-server 
RUN apt-get install -y supervisor
RUN apt-get install -y bash

ADD sshd.conf /etc/supervisor/conf.d/sshd.conf


# configure supervisor
ADD ./supervisor/supervisord.conf /etc/supervisor/
ADD ./supervisor/conf.d/crond.conf /etc/supervisor/conf.d/
ADD ./supervisor/conf.d/syslog-ng.conf /etc/supervisor/conf.d/

RUN mkdir -p /var/run/sshd

RUN echo "root:root" | chpasswd

EXPOSE 22

CMD /usr/bin/supervisord -n

ADD bin/fix.sh /fix.sh
#RUN /bin/bash fix.sh && rm /fix.sh

EXPOSE 80
ENTRYPOINT ["/bootstrap/start.sh"]

# Define default command.
CMD ["/my_init"]



