#!/usr/bin/env -S nu --stdin

# Claude Code statusLine command to render the Starship prompt.
# starship's `prompt` output is multi-line: a leading blank line (add_newline),
# the info line, then the prompt-character line. Keep only the info line(s):
# drop blank lines, then drop the final prompt-character line.
#
# Note: `--stdin` + `def main` are both required. Referencing `$in` at the top
# level of a script triggers nu 0.112.2's "Can't evaluate block in IR mode" bug;
# wrapping the logic in `main` gives a properly compiled block, and `--stdin`
# pipes Claude Code's JSON payload into that block's `$in`.

# To test:
#   {cwd: $env.PWD} | to json | ./statusline-command.nu

# To install, edit ~/.claude/settings.json:
#   {
#     "statusLine": {
#       "type": "command",
#       "command": "/home/dev/.claude/statusline-command.nu",
#       "padding": 0
#     }
#   }
#
# - type: "command" (only supported type).
# - command: script path or inline command. Run on every status refresh.
# - padding: optional. 0 removes default left padding so output sits flush at the edge.


# Docs: https://docs.claude.com/en/docs/claude-code/statusline
# Claude Code pipes a JSON session payload to the command on stdin (why your script reads stdin). Fields:
#   {
#     "hook_event_name": "Status",
#     "session_id": "abc123",
#     "transcript_path": "/path/to/transcript.json",
#     "cwd": "/current/working/dir",
#     "model": { "id": "claude-opus-4-8", "display_name": "Opus 4.8" },
#     "workspace": { "current_dir": "/current/dir", "project_dir": "/original/project/dir" },
#     "version": "1.0.0",
#     "output_style": { "name": "default" },
#     "cost": {
#       "total_cost_usd": 0.01,
#       "total_duration_ms": 45000,
#       "total_lines_added": 100,
#       "total_lines_removed": 50
#     }
#   }

# Claude Code statusLine command to render the Starship prompt.
def main [] {
  let cwd = ($in | from json | get cwd)
  $env.STARSHIP_CONFIG = ($env.XDG_CONFIG_HOME | path join "starship-claude.toml")
  starship prompt --path $cwd --logical-path $cwd
}
