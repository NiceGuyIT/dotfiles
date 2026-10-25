#!/usr/bin/env nu

# This is a list of various ways to get the external IP.

# This is has the forwarded for IP.
let lumtest = (http get --headers [Accept "application/json" ] https://lumtest.com/echo.json)

# This does the forwarded IPs.
let ifconfig_me = (http get --headers [Accept "application/json" ] https://ifconfig.me/all.json)

# The free service is fine for low queries.
let ipinfo = (http get --headers [Accept "application/json" ] https://ipinfo.io/json)

let ifconfig_co = (http get --headers [Accept "application/json" ] "https://ifconfig.co/json")

# Has bad language (JSON names)
# http get --headers [Accept "application/json" ] https://wtfismyip.com/json

# These provide only the IP
# http get --headers [Accept "application/json" ] https://icanhazip.com/
# http get --headers [Accept "application/json" ] https://ifconfig.in

{
	lumtest: $lumtest
	ifconfig_me: $ifconfig_me
	ifconfig_co: $ifconfig_co
	ipinfo: $ipinfo
}