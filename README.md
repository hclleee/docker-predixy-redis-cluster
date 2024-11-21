# Redis cluster container with proxy

## Important

> Do not use this container in production. Use only in demo, test, or local development.

## Ports

* 6379 - redis proxy (predixy)
* 7000, 7001, 7002 - redis master nodes
* 7003, 7004, 7005 - redis slaves nodes

## Get this image

```console
docker pull octo5/predixy-redis-cluster:latest
```

## Supported tags

* [`5.0.6`]

## Using Docker Compose

```yaml
services:
  redis-cluster:
    image: octo5/predixy-redis-cluster:latest
    restart: always
    ports:
      - 6379:6379
      - 7000:7000
      - 7001:7001
      - 7002:7002
      - 7003:7003
      - 7004:7004
      - 7005:7005
```

