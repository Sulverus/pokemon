FROM tarantool/tarantool:1.7
MAINTAINER andrey@tarantool.org

COPY *.lua /opt/tarantool/
EXPOSE 3301
WORKDIR /opt/tarantool

CMD ["tarantool", "client.lua"]
