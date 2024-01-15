# Nushell functions and aliases
# https://www.nushell.sh/book/aliases.html#persisting

# General "ls -l" command
export def l [...args: string]: nothing -> nothing {
	if ($args | is-empty) {
		ls --long --short-names |
			select name user group mode size modified |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --long --short-names $it
		} | flatten |
			select name user group mode size modified |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}


# General "ls -la" command
export def la [...args: string]: nothing -> nothing {
	if ($args | is-empty) {
		ls --all --long --short-names |
			select name user group mode size modified |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long --short-names $it
		} | flatten |
			select name user group mode size modified |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}


# "ls -la" command that shows the links
export def ll [...args: string]: nothing -> nothing {
	if ($args | is-empty) {
		ls --all --long --short-names |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long --short-names $it
		} | flatten |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}


# "ls -lat" command
export def lt [...args: string]: nothing -> nothing {
	if ($args | is-empty) {
		ls --all --long --short-names |
			sort-by modified |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long --short-names $it
		} | flatten |
			sort-by modified |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}


# "ls -lart" command
export def lrt [...args: string]: nothing -> nothing {
	if ($args | is-empty) {
		ls --all --long --short-names |
			sort-by --reverse modified |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long --short-names $it
		} | flatten |
			sort-by --reverse modified |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}


# "ls -larS" command
export def lrs [...args: string]: nothing -> nothing {
	if ($args | is-empty) {
		ls --all --long --short-names |
			sort-by size |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long --short-names $it
		} | flatten |
			sort-by size |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}


# ripgrep all files. Not the same as repgrep-all.
export def rga []: nothing -> nothing {
	^rg --hidden --no-ignore
}


# fd (find) all files.
export def fda []: nothing -> nothing {
	^fd --hidden --no-ignore
}


# dl will download a file from a URL
export def dl [url: string]: nothing -> nothing {
	mut filename: string = (($url | url parse).path | path basename)
	# TODO: Check the Location header for a filename
    if not ($filename =~ '\.') {
        print $"Filename does not have an extension: ($filename). Using a generated filename"
    }
	if ($filename | is-empty) or (($filename | str length) == 0) or (not ($filename =~ '\.')) {
		$filename = $"dl-(random uuid).bin"
	}
	http get $url | save --progress $filename
    let response = (http get --full $url)
    $response.headers
	# https://discord.com/api/download?platform=linux&format=tar.gz
}


# "git commit --message 'my changes'" with syntactic sugar to pull changes first. This makes conflict resolution
# easier by short circuiting if the pull fails.
export def git-commit [message: string]: nothing -> nothing {
	git pull
	print "---"
	git add --update
	git commit --signoff --message $"($message)"
	print "---"
	git push
}


# rdp4k will use xfreerdp or wlfreerdp to RDP to a client with an HD resolution.
export def rdp [...args: string]: nothing -> nothing {
	if ($args | is-empty) {
		print "Please add an argument for /v and /u"
		return false
	} else {
		if not (which xfreerdp | is-empty) {
			^xfreerdp /w:1920 /h:1080 +bitmap-cache +offscreen-cache /compression-level:2 /network:auto $args
		} else if not (which wlfreerdp | is-empty) {
			^wlfreerdp /w:1920 /h:1080 +bitmap-cache +offscreen-cache /compression-level:2 /network:auto $args
		}
	}
}


# rdp4k will use xfreerdp or wlfreerdp to RDP to a client with a resolution suitable for a 4k monitor.
export def rdp4k [...args: string]: nothing -> nothing {
	if ($args | is-empty) {
		print "Please add an argument for /v and /u"
		return false
	} else {
		if not (which xfreerdp | is-empty) {
			^xfreerdp /w:2548 /h:1436 +bitmap-cache +offscreen-cache /compression-level:2 /network:auto $args
		} else if not (which wlfreerdp | is-empty) {
			^wlfreerdp /w:2548 /h:1436 +bitmap-cache +offscreen-cache /compression-level:2 /network:auto $args
		}
	}
}


# TODO: Check if this works for macOS.
# Get the mountpoints as a table.
export def "get-mountpoints" []: nothing -> table {
	if (which mount | is-empty) {
		print $"The 'mount' command is not found. Please install 'mount' and try again."
        exit 1
	}
	^mount
		| from ssv --minimum-spaces 1
		| rename proc on_word mountpoint type_word options
		| select proc mountpoint options
}


# TODO: Make this dynamic
#let mountpoints = {
#	"niceguyit.biz-vault-crypt": "niceguyit.biz-vault-plain",
#}

# Mount all gocryptfs encrypted directories
export def "mount-all" []: nothing -> nothing {
	use gocryptfs.nu *
	gocryptfs-mount --name 'niceguyit.biz-docs'
	gocryptfs-mount --name 'niceguyit.biz-imaging'
	gocryptfs-mount --name 'niceguyit.biz-pics'
	gocryptfs-mount --name 'niceguyit.biz-vault'
	gocryptfs-mount --name 'niceguyit.biz-vids'
	gocryptfs-mount --name 'niceguyit.biz-working'
	gocryptfs-mount --name 'pugtsurani.com-divorce'
	gocryptfs-mount --name 'pugtsurani.com-docs'
	gocryptfs-mount --name 'pugtsurani.com-imaging'
}

# Get certificate information for a domain or file.
export def "cert-get" [cert: string]: nothing -> nothing {
	if (which cfssl-certinfo | is-empty) {
		print $"Could not find 'cfssl-certinfo' binary. Please install 'cfssl-certinfo' and try again."
		exit 1
	}
	mut option = "-domain"
	if ($cert | path exists) and (($cert | path type) == "file") {
		$option = "-file"
	}
	^cfssl-certinfo [
		$option $cert
	] | from json | select subject sans not_after not_before issuer
}
