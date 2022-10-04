#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# load variables from env file
if [ -f ../env ]; then
  . ../env
fi

if [ ! -f "${DOMAIN}/${DOMAIN}.pem" ]; then  
  mkdir -p $DOMAIN

  openssl req \
    -newkey rsa:2048 \
    -x509 \
    -nodes \
    -keyout "${DOMAIN}/${DOMAIN}.key" \
    -new \
    -out "${DOMAIN}/${DOMAIN}.crt" \
    -subj "/CN=*.${DOMAIN}" \
    -reqexts SAN \
    -extensions SAN \
    -config <(cat /etc/ssl/openssl.cnf \
    <(printf "[SAN]\nsubjectAltName=DNS:*.%s, DNS:%s" "${DOMAIN}" "${DOMAIN}")) \
    -sha256 \
    -days 3650

  cat "${DOMAIN}/$DOMAIN.crt" "${DOMAIN}/${DOMAIN}.key" \
      | tee "${DOMAIN}/${DOMAIN}.pem"
else  
  echo "Certificate already exists!!!"
fi