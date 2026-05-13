#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" || "$TARGET" == "-h" || "$TARGET" == "--help" ]]; then
    echo "Usage: $(basename "$0") <prefix-ou-nom>    # ex: $(basename "$0") redpeaks"
    exit 1
fi

echo "Fetching all containers created from the ${TARGET} image and by container name..."

# All containers started from any 'TARGET:*' image
C_BY_IMAGE=$(sudo docker ps -aq --filter "ancestor=${TARGET}" || true)
# All containers whose name contains 'TARGET'
C_BY_NAME=$(sudo docker ps -aq --filter "name=${TARGET}" || true)

# Merge C_BY_IMAGE and C_BY_NAME into CONTAINERS (unique, non-empty)

# Remove containers
CONTAINERS=$(printf "%s\n%s\n" "$C_BY_IMAGE" "$C_BY_NAME" | sort -u | sed '/^$/d' || true)
if [ -n "${CONTAINERS:-}" ]; then
  echo "Removing containers: $CONTAINERS"
  # -f => force stop and remove
  sudo docker rm -f $CONTAINERS
else
  echo "No matching containers found"
fi

# Remove images
echo "Fetching all ${TARGET} images (all tags/versions)..."
IMAGES=$(sudo docker images ${TARGET} -q | sort -u || true)
if [ -n "${IMAGES:-}" ]; then
  echo "Removing images: $IMAGES"
  sudo docker image rm -f $IMAGES
else
  echo "No ${TARGET} images found"
fi

# Remove volumes
echo "Fetching all ${TARGET} volumes (all tags/versions)..."
VOLUMES=$(sudo docker volume ls -q | grep ${TARGET} || true)

if [ -n "${VOLUMES:-}" ]; then
  echo "Removing volumes: $VOLUMES"
  sudo docker volume rm $VOLUMES
else
  echo "No 'redpeaks' volumes found"
fi

echo "Clean finished."
