#!/bin/sh

CLUSTER_MASTERS=3
CLUSTER_REPLICAS=1
TOTAL_NODES=$((CLUSTER_MASTERS * (1 + CLUSTER_REPLICAS)))

FIRST_PORT=7000
LAST_PORT=$((FIRST_PORT + TOTAL_NODES - 1))

SUPV_CONF_PATH=/etc/supervisor/supervisord.conf

if [ -z "$PROXY_PORT" ]; then
  PROXY_PORT=6379
fi

if [ -z "$BIN_BASE_DIR" ]; then
  BIN_BASE_DIR=/usr/local/bin
fi

if [ -z "$CONF_BASE_DIR" ]; then
  CONF_BASE_DIR=/usr/local/etc
fi

if [ -z "$DATA_BASE_DIR" ]; then
  DATA_BASE_DIR=/var/lib
fi

if [ -z "${LOG_BASE_DIR}" ]; then
  LOG_BASE_DIR=/var/log
fi


if [ "$1" = 'predixy-redis-cluster' ]; then
  service supervisor stop

  cp ./supervisord.conf ${SUPV_CONF_PATH}

  redis_nodes=""
  predixy_servers=""

  for port in $(seq ${FIRST_PORT} ${LAST_PORT}); do
    redis_nodes="${redis_nodes} 127.0.0.1:${port}"
    predixy_servers="${predixy_servers}\n\t+ 127.0.0.1:${port}"

    conf_path="${CONF_BASE_DIR}/redis/${port}"
    data_path="${DATA_BASE_DIR}/redis/${port}"

    rm -rf ${conf_path} ${data_path};

    mkdir -p ${conf_path}
    mkdir -p ${data_path}

    PORT=${port} envsubst < ./redis.conf.tmpl > ${conf_path}/redis.conf
    PORT=${port} envsubst < ./supervisord.conf.redis.tmpl >> ${SUPV_CONF_PATH}
  done

  NODES=$(echo ${predixy_servers}) envsubst < ./predixy.conf.tmpl > ${CONF_BASE_DIR}/predixy/predixy.conf
  envsubst < ./supervisord.conf.predixy.tmpl >> ${SUPV_CONF_PATH}

  service supervisor start

  sleep 2;

  supervisorctl status

  echo "yes" | eval redis-cli -p "${FIRST_PORT}" --cluster create --cluster-replicas "${CLUSTER_REPLICAS}" "${redis_nodes}"

  tail -f ${LOG_BASE_DIR}/redis/redis*.log
else
  exec "$@"
fi
