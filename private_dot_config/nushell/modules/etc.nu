# Readers for well-known files under /etc.
#
# Naming: one command per file, named after the file's basename with '.' and '_'
# folded to '-' (resolv.conf -> 'etc resolv-conf'). Each is sugar for opening the
# canonical path and handing the text to the matching parser in from.nu.

use from.nu *

# Read and parse /etc/fstab.
export def "etc fstab" []: nothing -> table {
	open --raw /etc/fstab | from fstab
}

# Read and parse /etc/os-release.
export def "etc os-release" []: nothing -> record {
	open --raw /etc/os-release | from os-release
}
