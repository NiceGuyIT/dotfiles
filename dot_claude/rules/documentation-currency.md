# Documentation Currency (MANDATORY, every change)

Documentation is part of the change, not a follow-up. A doc statement that a change makes false is a defect shipped in
the same commit as the change. The Definition of Done for ANY change includes a doc sweep, and completion BLOCKS on it:

1. Grep every doc for references to what the change touched: file paths, table/column names, flags, commands, module
   names, phase numbers, config keys, env vars. Sweep by the SHAPE of what changed, not just the one doc you happen to
   remember. Read every candidate from disk THIS TURN per `verify-source-of-truth.md`: a doc you read earlier in
   the session, or remember the gist of, is not evidence of what it says now, and judging it current from memory is how
   a stale claim survives the sweep.
2. Docs in scope: the repo `CLAUDE.md`, `README`, governance docs, `SCHEMA/*.md` and other in-repo docs, code-comment
   claims, and the repo plan file (see `plans-roadmap.md`). Update every stale hit in the SAME PR as the change.
3. NEVER restate mutable status (done / TBD / in-progress / merged / planned) in prose. Status lives in the tracker
   (YouTrack); prose links to the issue and never re-asserts its state. A hand-maintained status table in Markdown is
   the anti-pattern that produced a stale `## Phases` table in a repo's own docs: the table said "TBD" for work that
   had shipped months earlier because status was duplicated in prose instead of read from the tracker.
4. Stale doc discovered mid-change but outside its scope: file a linked issue per the no-orphan-notes rule; do not
   silently leave it, and do not silently fix unrelated docs as a drive-by.
5. Edit live content, never a remembered or drafted copy. For a doc hosted outside the repo (YouTrack article or issue,
   wiki, anything the user can edit concurrently), re-fetch it immediately before writing and merge the change into
   what comes back. Those writes are full-content replacements, so publishing a locally assembled version silently
   deletes every edit made since you last read it. Same rule, same reason, as `verify-source-of-truth.md`.

This is the doc analogue of the Completeness / Invariant Sweep, and it stands on Verify the Source of Truth FIRST: the
sweep is only as good as the freshness of what it reads and writes. The failure mode is fixing the code and forgetting
the prose that describes it, so encode the sweep to run every time. No hook can judge semantic staleness, so this
blocking sweep at change time is the enforcement, not a commit hook.

## Documentation is never unit tested (MANDATORY)

A change to a static documentation file ships NO test, guard script, `just` recipe, or CI step that asserts its
wording. Not one. Documentation is prose for humans; there is no documentation server, nothing imports a `.md` file,
and no behaviour can regress. A regex suite over prose fails on every legitimate rewording and stays green while the
prose rots in any way the regex does not model, so it certifies nothing and bills maintenance forever.

**In scope (never tested):** `*.md`, `*.mmd`, `*.txt`, READMEs, ADRs, governance docs, issue and PR templates, prompt
and instruction files, changelogs. Anything whose audience is a person reading it.

**NOT in scope (keep their tests):** documentation IN code. Docstrings, doctests, `--help` output, executed examples,
type stubs, and generated docs whose generator is code are all code and are tested like code.

Rules:

- Verification for a doc change is reading the diff. A `grep` named in an issue or an acceptance criterion is an
  instruction to run it ONCE at review time; it is never a licence to commit that grep as a script, a test, a recipe,
  or a CI job.
- If a banned term genuinely must never return, express it in the linter the repo ALREADY runs (a cspell forbidden
  word, an existing lint rule). Never a new bespoke script, never a new CI job.
- The permitted file set for a doc issue is the doc files themselves. A diff that adds a `scripts/`, `tests/`, or
  `.github/workflows/` entry to a documentation change has failed the issue, whatever else it got right.

**Why:** one issue stated twice, in the approach and in an acceptance criterion, that it adds no guard script, `just`
recipe, or CI step. The run shipped a bespoke guard script, a `just` recipe wired into `just check`, and a Lint job
step, then listed the guard in its summary as a satisfied criterion. Another issue turned a human-run prompt file into
an 85-line pytest asserting sentences. A written prohibition alone did not hold, so this rule is stated once, globally,
and the file-set check in the issue is what enforces it.
