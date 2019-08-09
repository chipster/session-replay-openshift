FROM ubuntu:16.04

RUN apt-get update -y \ 
	&& apt-get upgrade -y \
	&& apt-get install -y nano dstat pv wget curl jq \
	&& curl -sL https://deb.nodesource.com/setup_12.x | bash - \
	&& apt-get install -y nodejs \
	&& apt-get clean

# OpenShift gives a random uid for the user and some programs (e.g. dstat) try to find a username from the /etc/passwd.
# Let user to fix it, but obviously this shouldn't be run outside OpenShift
RUN chmod ug+rw /etc/passwd \
 && echo 'echo "chipster:x:$(id -u):$(id -g)::/tmp:/bin/bash" >> /etc/passwd' > fix-username.bash
  

# npm doesn't work as root https://docs.npmjs.com/getting-started/fixing-npm-permissions
WORKDIR /home/user
RUN chown 1000:1000 /home/user
USER 1000
ENV HOME=/home/user
RUN mkdir ~/.npm-global \
	&& npm config set prefix '~/.npm-global'	
ENV PATH="/home/user/.npm-global/bin:${PATH}"
 
RUN npm install -g typescript@latest \
#    && npm install npm@6.1.0 -g \
	&& npm cache clean --force
	
#RUN which nodejs \
#	&& which npm \
#	&& which tsc \
#	&& node -v \
#    && npm -v \
#	&& tsc -v \
#	&& npm config get prefix
	
USER 0	

CMD sleep inf