#!/usr/bin/env bash

p="$(pwd)"
domain="${p##*/}"
# Add your email here
email="Lego-Acme@NiceGuyIT.biz"
# Add the registrar's DNS server here
resolvers="crystal.ns.cloudflare.com"

# Cloudflare
export CF_API_EMAIL_FILE="./.cloudflare-api-email"
export CF_DNS_API_TOKEN_FILE="./.cloudflare-api-token"
export CF_ZONE_API_TOKEN_FILE="./.cloudflare-api-token"

echo "Renewing ${domain}"
lego \
	--domains "${domain}" \
	--email "${email}" \
	--accept-tos \
	--dns cloudflare \
	--key-type ec256 \
	--dns.resolvers "${resolvers}" \
	run

