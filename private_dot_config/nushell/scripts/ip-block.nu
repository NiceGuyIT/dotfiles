#!/usr/bin/env nu

# Convert an IP to an ASN
export def "ip asn" [ip: string]: nothing -> list<string> {
	/usr/bin/whois -h whois.radb.net $ip
		| from ssv --noheaders
		| where column1 =~ 'origin:'
		| get column2
		| uniq
}

# Convert an ASN to firewalld command
export def "asn firewalld" [asn: string]: nothing -> string {
		#| each {|it| $"firewall-cmd --zone block --add-source ($it)"}
	/usr/bin/whois -h whois.radb.net -- $"-i origin ($asn)"
		| from ssv --noheaders
		| where column1 == 'route:'
		| get column2
		| sort --natural
		| uniq
		| to text
}
