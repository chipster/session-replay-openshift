FROM base

COPY . /home/user/chipster-web-server/

RUN cd /home/user/chipster-web-server/js/rest-client \
	&& npm install; tsc; npm link \
	&& cd /home/user/chipster-web-server/js/cli-client \
	&& npm install \
	&& npm link rest-client \
	&& tsc \
    && chmod -R ugo+rwx .

WORKDIR /home/user/chipster-web-server/js/cli-client

CMD node src/replay-session -h
