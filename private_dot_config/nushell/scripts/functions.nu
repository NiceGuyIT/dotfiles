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
	http get $url | save $filename
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

# Mount the keepassxc encrypted directory
export def "mount keepassxc" []: nothing -> nothing {
	mount gocryptfs --name 'niceguyit.biz-vault'
}

# TODO: Make this dynamic
#let mountpoints = {
#	"niceguyit.biz-vault-crypt": "niceguyit.biz-vault-plain",
#}

# Mount all gocryptfs encrypted directories
export def "mount all" []: nothing -> nothing {
	use gocryptfs.nu *
	mount gocryptfs --name 'niceguyit.biz-docs'
	mount gocryptfs --name 'niceguyit.biz-imaging'
	mount gocryptfs --name 'niceguyit.biz-pics'
	mount gocryptfs --name 'niceguyit.biz-vault'
	mount gocryptfs --name 'niceguyit.biz-vids'
	mount gocryptfs --name 'niceguyit.biz-working'
	mount gocryptfs --name 'pugtsurani.com-divorce'
	mount gocryptfs --name 'pugtsurani.com-docs'
	mount gocryptfs --name 'pugtsurani.com-imaging'
}
