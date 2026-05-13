#!/usr/bin/env bash
set -euo pipefail

docker run -d \
  -p 8080:8080 \
  --user 1000:1000 \
  -v dokuwiki_data:/storage \
  dokuwiki/dokuwiki:2024-02-06b
