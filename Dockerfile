FROM ubuntu:20.04

MAINTAINER octo-5 (hyochan.lee@gmail.com)

ENV HOME /root
ENV PREDIXY_VERSION=1.0.5
ENV REDIS_VERSION=5.0.6
ENV BIN_BASE_DIR=/usr/local/bin
ENV CONF_BASE_DIR=/usr/local/etc
ENV DATA_BASE_DIR=/var/lib
ENV LOG_BASE_DIR=/var/log
ENV PROXY_PORT=6379

WORKDIR ${HOME}

RUN mkdir ${CONF_BASE_DIR}/predixy
RUN mkdir ${CONF_BASE_DIR}/redis
RUN mkdir ${DATA_BASE_DIR}/redis
RUN mkdir ${LOG_BASE_DIR}/redis

RUN apt-get update
RUN apt-get install --no-install-recommends apt-utils -y \
      net-tools supervisor gettext-base wget ca-certificates \
      build-essential
RUN apt-get clean -y

RUN wget https://github.com/antirez/redis/archive/${REDIS_VERSION}.tar.gz -O ./redis.tar.gz
RUN tar xfz ./redis.tar.gz -C ./
RUN mv ./redis-${REDIS_VERSION} ./redis

RUN wget https://github.com/joyieldInc/predixy/archive/${PREDIXY_VERSION}.tar.gz -O ./predixy.tar.gz
RUN tar xfz ./predixy.tar.gz -C ./
RUN mv ./predixy-${PREDIXY_VERSION} ./predixy

RUN (cd ./redis && make)
RUN cp ./redis/src/redis-server ./redis/src/redis-cli ${BIN_BASE_DIR}

RUN (cd ./predixy && make)
RUN cp ./predixy/src/predixy ${BIN_BASE_DIR}

COPY supervisord.conf ./supervisord.conf

COPY predixy.conf.tmpl ./predixy.conf.tmpl
COPY supervisord.conf.predixy.tmpl ./supervisord.conf.predixy.tmpl

COPY redis.conf.tmpl ./redis.conf.tmpl
COPY supervisord.conf.redis.tmpl ./supervisord.conf.redis.tmpl

COPY docker-entrypoint.sh ./docker-entrypoint.sh

RUN chmod 755 ./docker-entrypoint.sh

EXPOSE 6379 7000 7001 7002 7003 7004 7005

ENTRYPOINT ["./docker-entrypoint.sh"]

CMD ["predixy-redis-cluster"]
