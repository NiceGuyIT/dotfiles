# Tooling Gap Discipline

When a task needs functionality that the project's existing tool (the YouTrack MCP, `yt`, `fj`, `gh`, etc.) does not
expose, STOP. Do not reach for the REST API, parse the CLI's human output, scrape HTML, or hand-roll an equivalent.

- Default to the configured CLI. If it does not cover the case, that is the signal to extend the CLI, not bypass it.
- Surface the gap explicitly: state which tool, which capability is missing, and what the new command should look like.
  Ask whether to (a) file an issue against the tool and pause, (b) file an issue and proceed with a documented
  workaround, or (c) drop the requirement.
- Never silently substitute a REST call, raw HTTP, jq pipeline, or human-output parser for a missing CLI command. That
  re-implements auth, error handling, and field selection in every consumer.
- "Just temporarily" is the trap. Temporary REST calls become permanent forks. If a workaround is authorized, file the
  tracking issue first and reference it inline, e.g. `# TODO(PROJ-7): switch to yt project vcs once it lands`.

**Why:** Workarounds embed assumptions about the upstream tool that drift the moment the tool changes. Missing
capabilities should land in the canonical CLI, not scatter across action YAMLs, scripts, and Makefiles.

**Examples that trigger this rule:**

- The YouTrack MCP lacks a capability you need. Stop, file the issue against the MCP, do not hit the YouTrack REST API
  by hand.
- `fj` has no JSON output for `pr search`. Stop, file the issue, do not regex the human output.
- `gh` lacks a flag. Stop, file the issue, do not hit `/api/...` directly.

This rule also applies to nu helpers, shell wrappers, and Makefile targets that reimplement what a CLI should provide.
