# Personal Claude Code configuration

Detailed rules live in `~/.claude/rules/` and are auto-discovered by Claude Code (no import needed). This file is
a short index for humans; edit the files below, not this list.

- `rules/response-style.md` - how to write responses (terse, direct, no filler)
- `rules/user-preferences.md` - Nushell-first shell commands, doc links, YAML/Compose conventions, production-ready
  answers, comment length, force-flag ban, em-dash/ASCII-only output, AskUserQuestion preview ban
- `rules/verify-source-of-truth.md` - MANDATORY: re-verify against the live source before stating any fact or claim
- `rules/troubleshooting.md` - three-strike red herring rule, verify-before-fix
- `rules/completeness-invariant-sweep.md` - MANDATORY: every bug fix is swept for every site the invariant governs
- `rules/error-visibility.md` - MANDATORY: no swallowed errors, no silent fallbacks, visible at every layer
- `rules/documentation-currency.md` - MANDATORY: docs updated in the same PR as the code; docs are never unit tested
- `rules/documentation-provenance.md` - MANDATORY: verify system claims against the system, not against prior docs
- `rules/plans-roadmap.md` - multi-step plans live in `docs/ROADMAP.md`, linking the tracker, never duplicating status
- `rules/tooling-gap-discipline.md` - missing CLI capability gets filed against the tool, never worked around
- `rules/nushell.md` (scoped to `**/*.nu`) - target Nushell 0.112.2 syntax
- `rules/git-workflow.md` - branch/commit/PR flow, pre-change and pre-commit checks, Forgejo `fj` conventions
- `rules/youtrack-workflow.md` - MANDATORY compliance gate: every code change starts as a YouTrack issue; issue
  granularity, parenting, no orphan notes, human-steps-gate-the-merge, agent-must-finish-alone, commit references.
  Detailed drafting workflow, required issue-body shape, and fuller rationale live in the `youtrack-workflow` skill
  (`skills/youtrack-workflow/SKILL.md`) - reference material, not part of the compliance gate
- `rules/docker-naming.md` (scoped to Compose files) - `{app}-{service}` resource naming, `dev-` prefix
