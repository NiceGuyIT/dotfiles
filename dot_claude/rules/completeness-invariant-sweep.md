# Completeness / Invariant Sweep (MANDATORY, every change)

Applies to every bug fix, feature, configuration change, migration, issue, and doc edit. A request that names specific
items ("add these five variables", "fix this endpoint", "use this image") names a LOWER BOUND, never the scope. The
scope is the full set the invariant governs, and finding that set is my job before I write anything.

A bug is never a broken line. It is a symptom of a violated invariant, and a fix is treated like a feature: the feature
IS the invariant, and it must be implemented completely, everywhere the invariant holds. Fixing the one site named in
the report while leaving siblings broken is a half-baked fix and is forbidden. This rule exists because the default
failure mode is narrowing in on the reported symptom (pagination fixed on 2 of 4 endpoints; drag-and-drop fixed on 5 of
6 items; HTML view left blank with no text fallback; a WebSocket ping sent but the pong never verified). To a human this
is common sense; encode it so it happens every time.

Before declaring ANY bug fix done, run this sweep and BLOCK completion on it:

1. **State the invariant** in one sentence, as a contract. Examples: "every collection read pages until a short page (
   never silently truncates)"; "every liveness ping verifies a reply within a timeout, else the connection is torn
   down"; "every content renderer falls back to a secondary representation when the primary is absent".
2. **Derive a search pattern** that matches the SHAPE of code the invariant governs, independent of the original
   diagnosis. For pagination that is every outbound call to a collection endpoint, not the one function in the ticket.
   For the ping it is every heartbeat/`send(Ping)` site. For the renderer it is every view function that reads a
   format-specific field. Grep the shape, do not rely on memory or on siblings you happened to notice.
3. **Enumerate every hit** across the WHOLE codebase and classify each: compliant / violating /
   not-applicable-with-stated-reason. No hit left unclassified. An "N/A because domain-bounded" must state WHY it cannot
   exceed the limit.
4. **Remediate all violations** in one change: fix them, or file+link a tracked issue per exclusion with its reason (per
   the no-orphan-notes rule). Silent exclusion is forbidden.
5. **Print the classified table** in the response so the boundary is auditable, not implied. The count found by the
   pattern sweep is almost always larger than the count in the initial diagnosis; that gap is the whole point of the
   rule.

The comment that rationalizes a gap ("let the WebSocket layer time out stale connections", "the caller will pass a
limit") is the tell that step 1 was skipped. When a fix touches an `if`/present/success branch, step 2 must check the
corresponding `else`/absent/failure branch as part of the same shape.

## Configuration and "add these items" requests (MANDATORY)

Before the first edit, and before filing any issue that specifies configuration:

1. **State the family.** Name the whole set the listed items belong to ("every `RUNS_ON_*` variable CI uses", "every
   runner", "every image tag"). The user's list is a subset of it until proven otherwise.
2. **Enumerate the family from the source of truth, not from the list.** Grep the consumers (every `vars.X`, `${X}`,
   `env:`, workflow, compose file, script, and submodule that references the family prefix). Query the system that
   defines the members (org variables, registry, every runner config, the deployed resource). A single file the user
   pasted or I happened to read is a sample, never the population.
3. **Reconcile.** Print a table: member, where defined, where consumed, covered by this change (yes / no + reason). A
   member that is consumed but absent from the user's list is a finding. Ask about it (one question) or include it,
   never silently drop it.
4. **Never narrow scope on my own.** Phrases like "not part of this change", "only the N listed", or "out of scope" are
   forbidden unless the user said them. If completeness would make the change larger, include it; if it needs a
   decision, ask for that decision.
5. **A sample is not the fleet.** When infrastructure has several instances (runners, hosts, environments), read ALL
   of them before stating how it works. One instance showing a value commented out proves nothing about the others.
6. **Do the whole job in one pass.** The test is "will the user have to touch this exact configuration again?" If yes,
   the change is incomplete.

Counter-rule: completeness is about the family the change governs, not about unrelated work. What happens to a
finding outside the current change depends on its kind:

- **Code defects (bugs, broken or missing behavior in code):** file the issue automatically, per the no-orphan-notes
  rule in `youtrack-workflow.md`. Do not ask first, and do not fix it in the current change unless it is in the
  family the invariant governs.
- **Configuration and infrastructure changes (image pins, variables, runner labels, compose or env settings, CI
  settings, registry or version choices):** never file, queue, or start these without the user's explicit approval.
  Report the finding in the reply and wait. A change that edits configuration is not a bug fix, even when an old
  value is deprecated.
- **Unsure which kind it is:** treat it as configuration and ask.
