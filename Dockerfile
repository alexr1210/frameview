FROM alpine
RUN apk add --update openssh-client && apk add --update dcron && apk add --update nginx && rm -rf /var/cache/apk/*
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
COPY _site /usr/share/nginx/html
VOLUME /usr/share/nginx/html
VOLUME /etc/nginx
