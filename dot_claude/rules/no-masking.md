# No Masking (MANDATORY, every change and every diagnosis)

Nothing wrong, missing, unexpected, or deprecated may be made to look fine. A defect is fixed at its cause. If it
cannot be fixed in this change, it is made MORE visible, never less, and it gets a tracked issue. A masked defect is
worse than the original: it is now unreportable, and it looks like a success.

Origin: a UI showed "Someone" where a person's name belonged. The roster lookup had failed. The fallback label turned
a failed lookup into a believable value, and the cause stayed hidden until a human noticed: no request, no log line, no
tooltip, nothing that named the id. The label alone was not the defect; the absence of any trace was.

## The test

After this line runs, can the situation be FOUND? Found means at least one trace that is on by default and carries the
offending id or value: visible on screen (text, badge, tooltip) or logged. No trace anywhere is masking. Judge the
effect, not the syntax: the list below is examples, not a closed set.

Visibility is the requirement, not severity. A situation that must be seen does not have to be logged at `error`:
`warn` or `info` is correct when that matches the consequence (see `error-visibility.md` section 3), provided the line
exists, names the cause, and the outcome is still distinguishable from success. Escalating a benign event to `error`
is noise, and noise buries real failures.

## Forbidden shapes

1. **Placeholder for failed or missing data, with no trace:** "Someone", "Unknown", "N/A", "-", "Anonymous", "Guest",
   "Untitled", "", 0, epoch, a default avatar, a default id. A placeholder that could be a real value is the worst form.
   A placeholder is allowed when it carries the cause where the person can reach it (a hover tooltip naming the id) and
   the failure is logged with the id. A placeholder with neither is masking.
2. **Default or coalesce on data the contract says must exist:** `??`, `||`, `.get(k, default)`, `or ""`, `COALESCE`,
   `${VAR:-default}`, `#[serde(default)]`, making a required field optional so a type check passes.
3. **Dropping the odd item:** filter, skip, `continue`, `flatten`, or `LIMIT` over rows that failed to parse or
   resolve; clamping; dedupe that hides a conflict; trimming, lowercasing, or coercing input that should be rejected.
4. **Catch-all for the unexpected:** `_ =>` / `default:` / `else` on a closed set, an unknown variant mapped to a known
   one, a "tolerant" parser that accepts malformed input.
5. **Silencing the signal, not the cause:** deleting or filtering a log line, lowering its level below what the consequence warrants, `allow` / `noqa` /
   `type: ignore` / `@ts-ignore` / `eslint-disable` / `2>/dev/null` / `|| true`, making a check non-blocking, adding
   a baseline or ignore entry.
6. **Making the test pass instead of the code:** weakened or deleted assertion, a mock or fixture that returns the
   fallback, a snapshot re-recorded over a regression, `skip` / `xfail`, retry-until-green, a sleep or raised timeout
   to dodge a race or hang.
7. **Retry, restart, cache-bust, or second-source fallback** with no log of the first failure and no investigation of
   why it failed.
8. **Hiding it in presentation:** `display: none`, an empty state that reads as "no data" when the call failed, a
   spinner that never resolves, a count that omits the failures.
9. **Pin, shim, or version-lock** to avoid a bug in code we control or can fix upstream.

## What to do instead

1. Find the cause and show the evidence (`troubleshooting.md`, `verify-source-of-truth.md`). Fix it there.
2. Data that is absent BY CONTRACT (optional in the schema) is a state of its own: `None` / null in the model, and in
   the UI an explicit "not set" that is visibly different from every real value. Failure is never absence.
3. A cause that cannot be fixed in this change (upstream bug, human action) is rendered as an explicit failure where
   the person is looking, with the cause in the text (or, for a display value, the existing placeholder plus a hover
   tooltip naming the cause), logged at a level matching the consequence, answered with a non-success status, and
   tracked in a linked issue (`youtrack-workflow.md` section 3). The failure is shown while the fix is pending.
4. Unexpected input, state, or variant fails fast with the offending value in the message. Matches over closed sets
   are exhaustive, with no wildcard arm.
5. Warnings are defects: fix them. A suppression is allowed only under `error-visibility.md` section 4 plus a linked
   issue.
6. A test must fail before the fix and pass after it. Run both and report both.

## Diagnosis and reporting

- Never call a change "fixed", "handled", or "resolved" when it only changes what is displayed or logged. State the
  root cause.
- Never offer a masking workaround as an option, including a "temporary" one.
- Never say "the code gets fixed, not masked" without the cause already located. Saying it is not doing it.
- If the investigation is unfinished, report that. Do not ship a patch that makes the symptom go away.

## Blocking sweep, before ANY change is done

Grep the diff and the surrounding file for the shapes above. Print a table: hit, classification (root-cause fix /
optional-by-contract with the schema cited / explicit visible failure state), and verdict. Anything else is a
violation and is fixed in the same change. Masking found in the failure path of what you are fixing is removed in the
same change. Masking elsewhere is a code defect: file it per `completeness-invariant-sweep.md`.
