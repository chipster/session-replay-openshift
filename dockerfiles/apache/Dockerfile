FROM ubuntu:16.04

# install apache, shibd and java
RUN apt update -y \
	&& apt install -y apache2 curl wget \
	&& apt clean


# It's not allowed to run services with root privileges in OpenShift at the moment. 
# We have to make some adjustments to allow Apache and shibd to run as a regular user. 
# The OpenShift will create a new user (with high UID) for running these services and 
# adds that user a group ´root´, so it's enough to give necessary permissions for that group.

# By default Apache tries to bind to port 80, which isn't allowed for normal users. Let's 
# disable that by replacing the  file with an empty file. We'll add a new minimal 
# configuration file to ´sites-enabled´ to be able to test that Apache starts.

RUN mkdir -p /var/log/apache2/ /var/lock/apache2/ /var/run/apache2/ \
    && chgrp -R root /var/log/apache2/ /var/lock/apache2/ /var/run/apache2/ \
	&& chmod -R g+w /var/log/apache2/ /var/lock/apache2/ /var/run/apache2/ \
    && sed "s_Listen 80_Listen 8000_"  /etc/apache2/ports.conf -i \
    && echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf \
    && a2enconf fqdn 

CMD ["apachectl", "-DFOREGROUND"]