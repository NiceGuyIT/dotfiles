#!/usr/bin/env nu

# Install Claude Code ('claude')
export def 'claude install' [] {
	# Use bun to install claude instead
	if (which bun | length) == 0 {
		use std log
		log error "bun is required to install claude"
		log error "^bun install --global @anthropic-ai/claude-code"
		return
	}
	^bun install --global @anthropic-ai/claude-code
}
