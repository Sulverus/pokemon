FROM tarantool/tarantool-nginx:latest
MAINTAINER doc@tarantool.org

COPY nginx.conf /etc/nginx/nginx.conf
VOLUME ["/var/cache/nginx"]
EXPOSE 80 443
CMD nginx -g "daemon off;"
