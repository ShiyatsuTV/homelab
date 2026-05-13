#!/usr/bin/env bash
set -euo pipefail

IMAGE="redpeaks:7.0.6_54"
HTTP_PORT=8888
HTTPS_PORT="${HTTP_PORT%?}3"

INSTANCE="${HTTP_PORT}"
CONTAINER="redpeaks-${INSTANCE}"

sudo docker rm -f ${CONTAINER} 2>/dev/null || true

sudo docker run -d \
  --name ${CONTAINER} \
  --restart=always \
  -p ${HTTP_PORT}:8888 \
  -p ${HTTPS_PORT}:8443 \
  --add-host=host.docker.internal:host-gateway \
  -v ${CONTAINER}-certificates:/opt/tomcat/certificates \
  -v ${CONTAINER}-drivers:/opt/tomcat/drivers \
  -v ${CONTAINER}-db:/opt/tomcat/db \
  -v ${CONTAINER}-import:/opt/tomcat/importConf \
  -v ${CONTAINER}-logs:/opt/tomcat/logs \
  -v ${CONTAINER}-snapshots:/opt/tomcat/snapshots \
  -v ${CONTAINER}-tmp-drivers:/opt/tomcat/tmp_drivers \
  -v ${CONTAINER}-update:/opt/tomcat/update \
  -v ${CONTAINER}-worker-libs:/opt/tomcat/worker_libs \
  -v ${CONTAINER}-workers:/opt/tomcat/workers \
  ${IMAGE}
