#!/bin/sh
set -e

echo "========================================="
echo "Parsing templates"
echo "========================================="
dockerize -template /etc/traefik/traefik.tmpl:/etc/traefik/traefik.yml
echo "========================================="
cat /etc/traefik/traefik.yml

echo "========================================="
dockerize -template /etc/traefik/dynamic.tmpl:/etc/traefik/dynamic.yml
cat /etc/traefik/dynamic.yml
echo "templates parsed"
echo "continue with traefik entrypoint original workflow."
traefik "$@"
