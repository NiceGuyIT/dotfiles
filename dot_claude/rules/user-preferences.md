# User Preferences

- Give shell commands in Nushell syntax, not Bash, with command line switches in their long form.
- When troubleshooting, link the documentation that explains the specific scenario.
- Docker Compose: use `compose.yml`, not `docker-compose.yml`.
- In all YAML, including Compose labels, use mapping syntax (`key: value`), never list syntax (`- "key=value"`).
- Give complete, production-ready answers: cleanup steps, verification commands, edge cases, automation considerations.
  Never a partial solution that needs a follow-up question.
- Prefer the simplest, most minimal solution first. Do not present alternative approaches unless asked; stay on the
  context given.
- Code comments: 1-2 lines max, in every language and file. Keep only the non-obvious "why"; drop what the code shows and
  background that belongs in a doc or issue.
- Safety: NEVER use force flags (`rm -rf`, `--force`, `save --force`, `--force-with-lease`, etc.). A failure without
  force reveals a real bug, and "safer" variants of `--force` are still banned. If a git operation requires force, stop
  and find another approach.
- NEVER use the em-dash character (U+2014) in any text shown to the user or written to any artifact (chat, code
  comments, commits, PR text, READMEs, docs). Use a hyphen, colon, parentheses, or a new sentence.
- Generalize that: wherever a Unicode character has a reasonable ASCII equivalent, write the ASCII, in every output and
  file (chat, code, comments, commits, PR text, docs, config, terminal output, file names). Examples: curly quotes ->
  straight quotes (never a backtick as an apostrophe); en/em dashes and the minus sign U+2212 -> `-`; box drawing and
  block elements -> `= - | +`; ellipsis character -> `...`; bullets and middle dot -> `-`; arrows -> `->` `<-` `=>`
  `<->`; `<=` `>=` `!=` `~=` `x` `/` `+/-` for the math symbols; non-breaking and zero-width spaces -> a normal space or
  nothing; ligatures -> `fi` `fl`; fractions -> `1/2`; trademark, copyright, registered signs -> `(TM)` `(C)` `(R)`.
  A character with NO ASCII equivalent (accented letters, CJK, degree sign, euro, micro sign, emoji, real math notation)
  stays Unicode; never mangle it or strip an accent. When the character IS the payload (quoting a user or file
  verbatim, test fixtures, i18n strings, Unicode-handling sample data, strings matching an external system),
  reproduce it byte-exact.
- Never use the AskUserQuestion `preview` field: it renders cramped, truncated content I cannot expand. Ask decisions in
  plain markdown prose with each option and its trade-offs, and let me reply in my next message.
- Never name a file or directory on disk after a tracker issue; name it for what it CONTAINS, plus a date stamp when
  there will be several: `pg-17-dump-20260905`, not `dev-424-backup-20260905`. Covers dumps, backups, exports, archives,
  scratch and moved-aside directories, log bundles, and any path a runbook tells someone to create. The artifact
  outlives the issue and is read by someone without it open. Issue ids stay correct where the issue IS the subject:
  branch names, commit trailers, PR titles, and a document written about the issue itself (such as
  `docs/runbooks/dev-424-postgres-17-to-18.md`). If the id helps, put it in a README or log line inside the directory.
