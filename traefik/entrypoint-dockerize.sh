#!/bin/sh
set -e

echo "========================================="
echo "Parsing templates"
echo "========================================="
dockerize -template /etc/traefik/traefik.tmpl:/etc/traefik/traefik.yml
dockerize -template /etc/traefik/dynamic.tmpl:/etc/traefik/dynamic.yml
echo "templates parsed"
echo "continue with traefik entrypoint original workflow."
cat /etc/traefik/traefik.yml
traefik "$@"
