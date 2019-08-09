FROM base

COPY . /home/user/chipster-web-server/

RUN cd /home/user/chipster-web-server/js/cli-client \
	&& npm install \
	&& tsc \
    && chmod -R ugo+rwx .

WORKDIR /home/user/chipster-web-server/js/cli-client

CMD node lib/replay-session -h
