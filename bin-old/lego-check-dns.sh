#!/usr/bin/env bash

p="$(pwd)"
domain="${p##*/}"
resolvers="ns17.domaincontrol.com"

if [[ "$1" -eq "www" ]]
then
	while ! dig @"${resolvers}" "_acme-challenge.www.${domain}" -t TXT +short
	do
		sleep 1
	done
else
	while ! dig @"${resolvers}" "_acme-challenge.${domain}" -t TXT +short
	do
		sleep 1
	done
fi

