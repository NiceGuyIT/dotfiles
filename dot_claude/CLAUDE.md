# Personal Claude Code configuration

Detailed rules live in `~/.claude/rules/` and are auto-discovered by Claude Code (no import needed). This file is
a short index for humans; edit the files below, not this list.

- `rules/response-style.md` - how to write responses (terse, direct, no filler)
- `rules/user-preferences.md` - Nushell-first shell commands, doc links, YAML/Compose conventions, production-ready
  answers, comment length, force-flag ban, em-dash/ASCII-only output, AskUserQuestion preview ban, on-disk artifacts
  named for their contents rather than a tracker issue
- `rules/test-deliverable-yourself.md` - MANDATORY: the agent always runs and tests the script or program itself in its
  own environment, never hands testing to a human or a "Before this PR is merged" step, no redundant repeat checks
- `rules/verify-source-of-truth.md` - MANDATORY: re-verify against the live source before stating any fact or claim
- `rules/troubleshooting.md` - three-strike red herring rule, verify-before-fix
- `rules/completeness-invariant-sweep.md` - MANDATORY: every change (bug fix, config, feature, issue) covers the
  whole family it governs; the user's list is a lower bound, enumerate the full set from the source of truth
- `rules/error-visibility.md` - MANDATORY: no swallowed errors, no silent fallbacks, visible at every layer (see also
  `no-masking.md`)
- `rules/no-masking.md` - MANDATORY: nothing wrong, missing, unexpected, or deprecated is ever masked (placeholders
  with no trace, defaults, dropped rows, silenced warnings, weakened tests); a placeholder with a tooltip and a log line
  naming the id is findable, not masked; fix the cause or make the failure more visible
- `rules/documentation-currency.md` - MANDATORY: docs updated in the same PR as the code; docs are never unit tested
- `rules/documentation-provenance.md` - MANDATORY: verify system claims against the system, not against prior docs
- `rules/plans-roadmap.md` - multi-step plans live in `docs/ROADMAP.md`, linking the tracker, never duplicating status
- `rules/tooling-gap-discipline.md` - missing CLI capability gets filed against the tool, never worked around
- `rules/nushell.md` (scoped to `**/*.nu`) - target Nushell 0.112.2 syntax
- `rules/git-workflow.md` - branch/commit/PR flow, pre-change and pre-commit checks, Forgejo conventions (`fj` first, Forgejo MCP as fallback)
- `rules/youtrack-workflow.md` - MANDATORY compliance gate: use the `yt` CLI for YouTrack (MCP only as fallback); every code
  change starts as a YouTrack issue; issue
  granularity, parenting, no orphan notes, human-steps-gate-the-merge, agent-must-finish-alone, queue-on-file
  (`AI Agent = Queued` whenever the issue is workable), `Needs-Info` only when a person must decide (dependencies are
  managed by YouTrack links, never by that tag), bare `#KEY-N` as the last block of every commit AND PR description
  (never `Closes` / `Tracked in`).
  Detailed drafting workflow, required issue-body shape, and fuller rationale live in the `youtrack-workflow` skill
  (`skills/youtrack-workflow/SKILL.md`) - reference material, not part of the compliance gate
- `rules/docker-naming.md` (scoped to Compose files) - `{app}-{service}` resource naming, `dev-` prefix
