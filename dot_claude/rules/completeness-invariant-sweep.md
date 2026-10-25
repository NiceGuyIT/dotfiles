# Completeness / Invariant Sweep (MANDATORY, every change)

Applies to every bug fix, feature, configuration change, migration, issue, and doc edit. A request that names items
("add these five variables", "fix this endpoint") names a LOWER BOUND, never the scope. The scope is the full set the
invariant governs, and finding it is my job before I write anything. A bug is a symptom of a violated invariant, and a
fix is treated like a feature: implemented completely, everywhere the invariant holds. Fixing only the reported site
is forbidden.

Before declaring ANY bug fix done, block completion on this sweep:

1. **State the invariant** in one sentence as a contract ("every collection read pages until a short page"; "every
   liveness ping verifies a reply within a timeout").
2. **Derive a search pattern** matching the SHAPE of code the invariant governs, independent of the original diagnosis
   (every outbound call to a collection endpoint, every `send(Ping)` site, every view reading a format-specific field).
   Grep it; do not rely on memory or siblings you happened to notice.
3. **Enumerate every hit** across the WHOLE codebase and classify: compliant / violating / not-applicable with stated
   reason (an "N/A because bounded" says WHY it cannot exceed the limit). When a fix touches an `if`/present/success
   branch, check the `else`/absent/failure branch in the same pass.
4. **Remediate all violations** in one change, or file and link an issue per exclusion with its reason. Silent
   exclusion is forbidden.
5. **Print the classified table** in the response. The pattern sweep almost always finds more than the initial
   diagnosis; that gap is the point. A comment rationalizing a gap ("the caller will pass a limit") means step 1 was
   skipped.

## Configuration and "add these items" requests

Before the first edit, and before filing any issue that specifies configuration:

1. **State the family** the items belong to ("every `RUNS_ON_*` variable CI uses", "every runner", "every image tag").
2. **Enumerate it from the source of truth, not the list:** grep every consumer (`vars.X`, `${X}`, `env:`, workflows,
   compose files, scripts, submodules) and query the system that defines the members (org variables, registry, every
   runner config, the deployed resource). A file the user pasted is a sample, never the population; one instance with a
   value commented out proves nothing about the others.
3. **Reconcile** in a table: member, where defined, where consumed, covered by this change (yes / no + reason). A
   consumed member absent from the user's list is a finding: include it or ask one question, never drop it silently.
4. **Never narrow scope on my own.** "Not part of this change", "only the N listed" and "out of scope" are forbidden
   unless the user said them. If completeness enlarges the change, include it; if it needs a decision, ask.
5. **Do the whole job in one pass.** If the user will have to touch this configuration again, it is incomplete.

Counter-rule: completeness covers the family the change governs, not unrelated work. A finding outside it:

- **Code defect:** file the issue automatically (`youtrack-workflow.md` section 3), no asking; do not fix it here unless
  it is in the governed family.
- **Configuration or infrastructure** (image pins, variables, runner labels, compose or env settings, CI settings,
  registry or version choices): never file, queue, or start without explicit approval. Report it in the reply and wait.
  Editing configuration is not a bug fix, even when an old value is deprecated.
- **Unsure which:** treat it as configuration and ask.
