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
- Keep code comments short: 1-2 lines max. Large multi-line comment blocks hurt readability (reader wades
  through prose before reaching the code). Compress anything longer to the essential non-obvious "why";
  drop restating what the code shows and drop background/rationale that belongs in a doc or issue. Applies
  to all languages and all files.
- Safety: NEVER use force flags (rm -rf, --force, save --force, --force-with-lease, etc.) - failures without force
  reveal real bugs. "Safer" variants of --force are still force pushes and still banned. If a git operation requires
  force, stop and find the approach that does not.
- NEVER use the em-dash character (—, U+2014) in any text shown to the user or written to any artifact: chat messages,
  code comments, commit messages, PR titles and descriptions, READMEs, documentation, or any other output. Use a regular
  hyphen (-), a colon, parentheses, or a period-and-new-sentence instead. Applies to all projects and all contexts.
- Generalize that rule: whenever a Unicode character has a reasonable ASCII equivalent, write the ASCII. This holds
  everywhere the em-dash ban holds (chat, code, comments, commit messages, PR text, docs, config, terminal output,
  file names). If a character has NO ASCII equivalent (é, ñ, 日本語, °, €, µ, emoji, real math or scientific notation),
  Unicode is correct and expected. Never mangle such a character into an approximation; never strip an accent.
  Common substitutions, not an exhaustive list:
    - Smart quotes " " ' ' -> straight quotes " and '. Backtick-as-quote ` for an apostrophe is also wrong.
    - Dashes — – ‒ ― and the minus sign − -> hyphen-minus -
    - Box drawing ═ ─ │ ┌ └ ├ ┼ and block elements -> = - | + and other ASCII
    - Ellipsis … -> three periods ...
    - Bullets • ‣ ◦ and the middle dot · -> - (or the list syntax of the format)
    - Arrows → ← ⇒ ↔ -> -> <- => <->
    - Math and comparison ≤ ≥ ≠ ≈ × ÷ ± -> <= >= != ~= x / +/-
    - Non-breaking space, narrow no-break space, zero-width space -> a normal space, or nothing
    - Ligatures ﬁ ﬂ -> fi fl; fractions ½ ¼ -> 1/2 1/4; ™ © ® -> (TM) (C) (R)
  One exception: when the character IS the payload rather than formatting, reproduce it byte-exact. That covers
  quoting the user or a file verbatim, test fixtures and i18n strings, sample data that exercises Unicode handling,
  and any string that must match an external system. Silently ASCII-folding those changes the data.
- Never use the AskUserQuestion tool's preview field. It renders a cramped side-by-side box that truncates content
  behind a "N lines hidden" fold, which I cannot expand. When you need a decision from me, ask in plain markdown prose
  in the chat - state each option and its trade-offs as normal paragraphs or a list, and let me reply in my next
  message. Do not open the option/preview picker dialog.
- Never name a file or directory on disk after a tracker issue. Name it for what it CONTAINS, plus a date stamp
  when there will be more than one: `pg-17-dump-20260905`, not `dev-424-backup-20260905`. This covers every artifact
  a person meets on a filesystem later: dumps, backups, exports, archives, scratch and working directories,
  moved-aside directories, log bundles, and any path a runbook or script tells someone to create.
  **Why:** the artifact outlives the issue and is read by someone who does not have the issue open. `dev-424-backup`
  says only that some ticket caused it; the reader has to leave the terminal, find a tracker they may not have
  access to, and read a whole issue to learn it is a Postgres 17 dump. `pg-17-dump` says it on sight, sorts next to
  its siblings, and still means something in two years when the issue is closed and the project renamed. An issue id
  is a pointer to a story; a filename should be a description of a thing.
  Issue ids stay correct where the issue IS the subject and the reader is already in that context: branch names,
  commit trailers, PR titles, and the filename of a document written about the issue itself (a runbook such as
  `docs/runbooks/dev-424-postgres-17-to-18.md`). The ban is on naming DATA after a ticket, not on referencing tickets.
  If the issue id genuinely helps, put it in a `README` or a log line inside the directory, not in its name.
