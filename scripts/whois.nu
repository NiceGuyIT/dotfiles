#!/usr/bin/env nu

whois example.com
	| lines
	| parse '{name}: {value}'
	| str trim
	| update value {|it| if ($it.name =~ "Date") {$it.value | into datetime} else {$it.value}}
