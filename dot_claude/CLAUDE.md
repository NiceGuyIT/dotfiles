# User Preferences

- Always provide shell commands in Nushell syntax rather than Bash. When possible, expand all command line switches to
  their long form.
- When troubleshooting a problem, provide links to the documentation that explains the specific scenario.
- For Docker compose, use the newer `compose.yml` convention instead of the older `docker-compose.yml`.
- Always use YAML mapping syntax (key: value) instead of sequence/list syntax (- "key=value") in all YAML code,
  including Docker Compose labels.
- Always provide complete, production-ready answers. Include cleanup steps, verification commands, edge cases, and
  automation considerations. Never provide partial solutions that require follow-up questions to complete.
- Prefer the simplest, most minimal solution first. Avoid presenting multiple alternative approaches unless asked. Focus
  on the specific context provided rather than covering every possible scenario.
- Safety: NEVER use force flags (rm -rf, --force, save --force, etc.) — failures without force reveal real bugs
- NEVER use the em-dash character (—, U+2014) in any text shown to the user or written to any artifact: chat messages,
  code comments, commit messages, PR titles and descriptions, READMEs, documentation, or any other output. Use a regular
  hyphen (-), a colon, parentheses, or a period-and-new-sentence instead. Applies to all projects and all contexts.

# Troubleshooting Rules

- **Three-strike red herring rule:** If the same symptom persists after 3 fix attempts targeting the same area, STOP.
  Flag it as a likely red herring and broaden the investigation:
    1. Re-examine the full error context and surrounding system (not just the error message).
    2. Check assumptions: are the inputs what we think they are? Add debug output to verify.
    3. Look upstream: the root cause is likely in a different layer (caller, config, environment, permissions) than
       where
       the symptom appears.
    4. Explicitly tell the user: "We've tried fixing X three times. The real problem is probably elsewhere. Let me step
       back and look at the bigger picture."
- Before proposing a fix, verify the hypothesis first. Prefer adding debug/diagnostic output to confirm the cause before
  changing code speculatively.

# Nushell

- The installed Nushell version is `0.112.2`. When writing or reviewing Nushell code, use only syntax, commands, flags,
  and standard library features available in `0.112.2`. Reference the `0.112.2` documentation (not latest) when citing
  docs, and flag any usage that requires a newer version.

# Git Workflow (all repos)

Default workflow for every change, unless the user says they are working on many changes at once and to stay on the
current branch:

1. Make the changes.
2. Create a new branch with a name that describes the change (e.g., `fix/...`, `feat/...`, `chore/...`).
3. Commit and push the branch.
4. Switch back to `main` (the user merges the PR).
5. Before starting the next change, `git pull` on `main` to pick up the merged work.

Do not stack a second unrelated change onto an existing feature/fix branch. Each logical change gets its own branch off
the latest `main`.

## Commit messages

- Do NOT hard-wrap bullet points or paragraphs in the commit body. Each bullet or paragraph must be a single long line
  so the Forgejo/GitHub GUI can wrap it naturally. Hard-wrapping inside a bullet causes the GUI to render each wrapped
  line as its own broken-looking block and wastes vertical space in review.
- The subject line should still be short (~70 chars) and in the imperative.

# Docker Naming Convention

Every Docker resource (service, volume, network) for a project must be prefixed by the application name so `docker ps`,
`docker volume ls`, and `docker network ls` group all of an app's resources together. For development, add a `dev-`
prefix on top of the application prefix.

- Service: `{app}-{service}` (dev: `dev-{app}-{service}`)
- Application data volume: `{app}-data` (dev: `dev-{app}-data`)
- Application config volume: `{app}-config` (dev: `dev-{app}-config`)
- Network: `{app}-private` (dev: `dev-{app}-private`)

When a stack contains a sub-service with its own data store (e.g. Infisical bundled inside the `backup` stack and
needing its own Postgres), order the name segments so the sub-service segment comes BEFORE the resource type segment.
That way the data volume sorts adjacent to its parent service in alphabetical listings.

- Right: `dev-backup-infisical` and `dev-backup-infisical-postgres` (sort together)
- Wrong: `dev-backup-infisical` and `dev-backup-postgres-infisical` (the second sorts under `postgres-`, away from its
  parent)

In Compose files this means the volume `name:` field, the volume YAML key, the service name, the network name, and every
internal reference (`depends_on`, env-var hostnames in connection URLs) must all use the prefixed form.
