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
