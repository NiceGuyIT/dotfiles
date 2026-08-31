# Plans live in one file, linking the tracker

Every multi-step / phased / roadmap / "we will do X then Y then Z" plan lives in ONE designated file per repo:
`docs/ROADMAP.md` (create it if absent). Rules:

- The file holds durable narrative ONLY: goals, phases, sequencing, architecture direction, the reasoning behind the
  order. It is the answer to "where is the plan?".
- Each phase / item links to its owning YouTrack epic or issue. Status is READ from the tracker, never duplicated as
  checkboxes or a status column in the file (same rule as Documentation Currency step 3).
- "Agreed in PR review" or "agreed in chat" is NOT a plan. A plan agreed anywhere is written to the plan file BEFORE the
  work starts, so it is discoverable, reviewable, and cannot evaporate into an un-searchable review thread. The phased
  plan that motivated this rule existed only as an uncaptured PR-review discussion, which is exactly the gap it closes.
- A phase or plan item with no owning issue is invisible work: file it and link it (no-orphan-notes rule, see
  `youtrack-workflow.md`).
- If a repo already uses another name for this file (e.g. `TODO.md`), keep the name but bind it to these same rules
  (narrative plus tracker links, never duplicated status). Prefer `docs/ROADMAP.md` for new repos; "TODO" invites the
  checkbox-status anti-pattern.
