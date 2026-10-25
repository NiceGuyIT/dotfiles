# Personal Claude Code configuration

Rules live in `~/.claude/rules/` and are auto-discovered (no import needed). Edit those files, not this index. Each
file states its own scope and rationale.

- `response-style.md`
- `user-preferences.md`
- `testing.md` (MANDATORY)
- `verify-source-of-truth.md` (MANDATORY, no exceptions)
- `error-visibility.md` (MANDATORY, includes no-masking)
- `completeness-invariant-sweep.md` (MANDATORY)
- `no-internal-names.md` (MANDATORY)
- `documentation-currency.md` (MANDATORY, includes plans-roadmap)
- `youtrack-workflow.md` (MANDATORY compliance gate; drafting reference in the `youtrack-workflow` skill)
- `git-workflow.md` (Forgejo detail in the `forgejo-pr-workflow` skill)
- `tooling-gap-discipline.md`
- `troubleshooting.md`
- `large-writes.md` (MANDATORY)
- `nushell.md` (scoped to `**/*.nu`)
- `docker-naming.md` (scoped to Compose files)
