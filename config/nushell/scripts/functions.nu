# Nushell functions and aliases
# https://www.nushell.sh/book/aliases.html#persisting

# General "ls -l" command
export def l [...args: string] {
	if ($args | is-empty) {
		ls --long |
			select name user group mode size modified |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --long $it
		} | flatten |
			select name user group mode size modified |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}

# General "ls -la" command
export def la [...args: string] {
	if ($args | is-empty) {
		ls --all --long |
			select name user group mode size modified |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long $it
		} | flatten |
			select name user group mode size modified |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}

# "ls -la" command that shows the links
export def ll [...args: string] {
	if ($args | is-empty) {
		ls --all --long |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long $it
		} | flatten |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}

# "ls -lat" command
export def lt [...args: string] {
	if ($args | is-empty) {
		ls --all --long |
			sort-by modified |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long $it
		} | flatten |
			sort-by modified |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}

# "ls -lart" command
export def lrt [...args: string] {
	if ($args | is-empty) {
		ls --all --long |
			sort-by --reverse modified |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long $it
		} | flatten |
			sort-by --reverse modified |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}

# "ls -larS" command
export def lrs [...args: string] {
	if ($args | is-empty) {
		ls --all --long |
			sort-by size |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	} else {
		$args | each {|it|
			ls --all --long $it
		} | flatten |
			sort-by size |
			select name user group mode size modified target |
			update modified {format date "%Y-%m-%d %H:%M:%S"} |
			table --width 999
	}
}

# "git commit --message 'my changes'" with syntactic sugar to pull changes first. This makes conflict resolution
# easier by short circuiting if the pull fails.
export def git-commit [message: string] {
	git pull
	print "---"
	git add --update
	git commit --signoff --message $"($message)"
	print "---"
	git push
}

# rdp4k will use xfreerdp to RDP to a client with an HD resolution.
export def rdp [...args: string] {
	if ($args | is-empty) {
		print "Please add an argument for /v and /u"
		return false
	} else {
		^xfreerdp /w:1920 /h:1080 +bitmap-cache +offscreen-cache /compression-level:2 /network:auto $args
	}
}

# rdp4k will use xfreerdp to RDP to a client with a resolution suitable for a 4k monitor.
export def rdp4k [...args: string] {
	if ($args | is-empty) {
		print "Please add an argument for /v and /u"
		return false
	} else {
		^xfreerdp /w:2548 /h:1436 +bitmap-cache +offscreen-cache /compression-level:2 /network:auto $args
	}
}
