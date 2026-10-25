# Documentation Currency (MANDATORY, every change)

Documentation is part of the change. A doc statement a change makes false is a defect shipped in the same commit, and
completion BLOCKS on this sweep:

1. Grep every doc for what the change touched: file paths, table/column names, flags, commands, module names, phase
   numbers, config keys, env vars. Sweep by the SHAPE of the change, not the one doc you remember. Read every candidate
   from disk THIS TURN (`verify-source-of-truth.md`); a doc remembered from earlier is not evidence of what it says now.
2. Docs in scope: repo `CLAUDE.md`, `README`, governance docs, `SCHEMA/*.md` and other in-repo docs, code-comment
   claims, and the plan file. Update every stale hit in the SAME PR.
3. NEVER restate mutable status (done / TBD / in-progress / merged / planned) in prose. Status lives in the tracker;
   prose links to the issue and never re-asserts its state.
4. A stale doc found mid-change but outside its scope: file a linked issue (`youtrack-workflow.md` section 3); do not
   leave it silently and do not drive-by fix it.
5. Edit live content, never a remembered copy. For a doc hosted outside the repo (YouTrack article or issue, wiki),
   re-fetch immediately before writing and merge into what comes back; these writes are full replacements. A KB article
   mapped to a repo doc syncs both ways, so edit whichever side the change belongs on, not both.

## Documentation is never unit tested

A change to a static documentation file ships NO test, guard script, `just` recipe, or CI step asserting its wording.
Nothing imports a `.md` file, so no behaviour can regress, and a regex suite over prose fails on every rewording while
certifying nothing.

- **Never tested:** `*.md`, `*.mmd`, `*.txt`, READMEs, ADRs, governance docs, issue and PR templates, prompt and
  instruction files, changelogs: anything whose audience is a person.
- **Keep their tests:** docstrings, doctests, `--help` output, executed examples, type stubs, generated docs whose
  generator is code.
- Verification for a doc change is reading the diff. A `grep` named in an issue or AC is run ONCE at review time, never
  committed as a script, test, recipe or CI job. A term that must never return goes in a linter the repo ALREADY runs
  (a cspell forbidden word, an existing lint rule), never a new bespoke script or CI job.
- The permitted file set for a doc issue is the doc files themselves; adding a `scripts/`, `tests/`, or
  `.github/workflows/` entry fails the issue.

## Plans live in one file, linking the tracker

Every multi-step, phased, or roadmap plan lives in ONE file per repo: `docs/ROADMAP.md` (create if absent; a repo's
existing equivalent such as `TODO.md` keeps its name under these same rules).

- It holds durable narrative only: goals, phases, sequencing, architecture direction, reasoning behind the order.
- Each phase or item links to its owning YouTrack epic or issue. Status is READ from the tracker, never duplicated as
  checkboxes or a status column.
- "Agreed in chat" or "agreed in PR review" is not a plan. Write the plan to the file BEFORE the work starts.
- A plan item with no owning issue is invisible work: file and link it.
