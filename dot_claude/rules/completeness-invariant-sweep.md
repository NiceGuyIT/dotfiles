# Completeness / Invariant Sweep (MANDATORY, every bug fix)

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
