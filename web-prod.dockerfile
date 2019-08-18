FROM nginx:stable

ADD vhost-prod.conf /etc/nginx/conf.d/default.conf
ADD .htpasswd /etc/nginx/.htpasswd