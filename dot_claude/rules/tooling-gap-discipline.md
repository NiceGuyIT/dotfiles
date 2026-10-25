# Tooling Gap Discipline

When a task needs functionality the project's tool (`yt` then the YouTrack MCP, `fj` then the Forgejo MCP, `gh`, etc.)
does not expose, STOP. Do not reach for the REST API, parse human CLI output, scrape HTML, or hand-roll an equivalent.
That re-implements auth, error handling and field selection in every consumer, and "just temporarily" becomes a
permanent fork. The same applies to nu helpers, shell wrappers and Makefile targets that reimplement what a CLI should
provide.

- Default to the configured CLI. If it lacks the case, extend the CLI rather than bypass it.
- Surface the gap: name the tool, the missing capability, and what the new command should look like. Ask whether to
  (a) file an issue against the tool and pause, (b) file it and proceed with a documented workaround, or (c) drop the
  requirement.
- If a workaround is authorized, file the tracking issue first and reference it inline, e.g.
  `# TODO(PROJ-7): switch to yt project vcs once it lands`.
- Examples: `yt` and the YouTrack MCP both lack a capability (file against `yt`, no hand-made REST call); `fj` and the
  Forgejo MCP both lack one, or `fj pr search` has no JSON output (file against `fj`, no regex on human output); `gh`
  lacks a flag (file the issue, no `/api/...` call).
