FROM ubuntu:20.04

MAINTAINER octo-5 (hyochan.lee@gmail.com)

ENV HOME /root
ENV PREDIXY_VERSION=7.0.1
ENV REDIS_VERSION=7.0.15
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

RUN wget https://github.com/redis/redis/archive/${REDIS_VERSION}.tar.gz -O ./redis.tar.gz
RUN tar xfz ./redis.tar.gz -C ./
RUN mv ./redis-${REDIS_VERSION} ./redis

RUN (cd ./redis && make)
RUN cp ./redis/src/redis-server ./redis/src/redis-cli ${BIN_BASE_DIR}

RUN wget https://github.com/joyieldInc/predixy/releases/download/${PREDIXY_VERSION}/predixyFreeEdition-${PREDIXY_VERSION}-amd64-linux.tar.gz -O ./predixy.tar.gz
RUN tar xfz ./predixy.tar.gz -C ./
RUN mv ./predixyFreeEdition-${PREDIXY_VERSION} ./predixy
RUN cp ./predixy/bin/predixy ${BIN_BASE_DIR}

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
