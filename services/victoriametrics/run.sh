#!/usr/bin/env bash
set -euo pipefail

VICTORIA_VERSION="v1.143.0"
IMAGE="victoriametrics/victoria-metrics:${VICTORIA_VERSION}"
HTTP_PORT=8428
GRAPHITE_PORT=2003

INSTANCE="${HTTP_PORT}-${GRAPHITE_PORT}"
CONTAINER="victoriametrics-${VICTORIA_VERSION}-${INSTANCE}"

sudo docker rm -f ${CONTAINER} 2>/dev/null || true

sudo docker run -d \
  --name ${CONTAINER} \
  --restart=always \
  -p ${HTTP_PORT}:8428 \
  -p ${GRAPHITE_PORT}:2003 \
  -v ${CONTAINER}-data:/victoria-metrics-data \
  ${IMAGE} \
  -storageDataPath=/victoria-metrics-data \
  -graphiteListenAddr=:2003
