#!/usr/bin/env bash

# See https://serverfault.com/questions/107187/ssh-agent-forwarding-and-sudo-to-another-user

# User is provided as $1
if id "$1" >/dev/null 2>&1
then
	echo "$SSH_AUTH_SOCK"

	if [[ `uname -s` = "FreeBSD" ]]
	then
		# FreeNAS setfacl does not support long options.
		# By default, FreeNAS root (/tmp) does not have ACLs enabled.
		# The only option left is to use chmod
		# The svc-backup user is in the wheels group, so the group permissions
		# need to be changed.
		chmod g+X  "$(dirname "$SSH_AUTH_SOCK")"
		chmod g+rw "$SSH_AUTH_SOCK"
		ls -la $(dirname $SSH_AUTH_SOCK)

		# This asks for the user's password if you aren't root
		# To bypass the password, a 2nd sudo is needed
		sudo SSH_AUTH_SOCK="$SSH_AUTH_SOCK" --user $1 --login

		# FreeNAS setfacl does not support long options
		# By default, FreeNAS root (/tmp) does not have ACLs enabled 
		# The only option left is to use chmod
		chmod g-x  "$(dirname "$SSH_AUTH_SOCK")"
		chmod g-rw "$SSH_AUTH_SOCK"

	elif grep --silent '^NAME=.*CentOS' /etc/os-release
	then
		setfacl --modify u:$1:x  "$(dirname "$SSH_AUTH_SOCK")"
		setfacl --modify u:$1:rw "$SSH_AUTH_SOCK"

		# This asks for the user's password if you aren't root
		# To bypass the password, a 2nd sudo is needed
		# sudo on CentOS doesn't support long options
		sudo sudo -u $1 -i

		# Revoke the permissions
		setfacl --remove-all "$(dirname "$SSH_AUTH_SOCK")"
		setfacl --remove-all "$SSH_AUTH_SOCK"
	else
		setfacl --modify u:$1:x  "$(dirname "$SSH_AUTH_SOCK")"
		setfacl --modify u:$1:rw "$SSH_AUTH_SOCK"

		# This asks for the user's password if you aren't root
		# To bypass the password, a 2nd sudo is needed
		sudo sudo --user $1 --login

		# Revoke the permissions
		setfacl --remove-all "$(dirname "$SSH_AUTH_SOCK")"
		setfacl --remove-all "$SSH_AUTH_SOCK"
	fi

else
	echo "Invalid user: $1"
	exit 1
fi
