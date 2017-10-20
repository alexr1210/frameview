FROM nginx AS base
COPY _site /usr/share/nginx/html
VOLUME /usr/share/nginx/html
VOLUME /etc/nginx

FROM alpine:latest 
COPY --from=base  . .
RUN apk add --update openssh-client && apk add dcron && rm -rf /var/cache/apk/*
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d
VOLUME /usr/share/nginx/html
VOLUME /etc/nginx
