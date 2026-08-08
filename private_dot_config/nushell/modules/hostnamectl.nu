# Custom hostnamectl functions

# Get the host, kernel and OS information as a record.
export def "hostnamectl status" []: nothing -> record {
	if (which hostnamectl | is-empty) {
		print $"The 'hostnamectl' command is not found. Please install 'systemd' and try again."
		exit 1
	}
	^hostnamectl --json short | from json
}
