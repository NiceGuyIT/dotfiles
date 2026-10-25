# Error Visibility and No Masking (MANDATORY, every change and every diagnosis)

A failure MUST stay distinguishable from success at every layer it crosses, and MUST reach a log and the human who
triggered it. Nothing wrong, missing, unexpected, or deprecated may be made to look fine. A defect is fixed at its
cause; if it cannot be fixed in this change, it is made MORE visible, never less, and gets a linked issue. A hidden
failure is worse than the failure: it is unreportable and looks like a success.

## The test

After this line runs, can the situation be FOUND? Found means a trace that is on by default and carries the offending
id or value, on screen (text, badge, tooltip) or logged. Visibility is the requirement, not severity: `error` for a
failure, `warn` for a degraded or unexpected-but-handled result, `info` for an expected outcome (a lookup that found
nothing). Escalating a benign event to `error` is noise. Judge the effect, not the syntax; the lists below are examples.

## 1. Never discard an error value

Forbidden in every language unless section 6 applies:

- Rust: `unwrap_or*` on a `Result`, `.ok()` dropping an `Err`, `let _ =` on a `Result`, `if let Ok(x)` with no `else`
- Go: empty or log-less `if err != nil {}`, `_ = f()`, shadowed error returns
- Python: `except: pass`, `except Exception:` that neither re-raises nor logs
- JS/TS: empty `catch {}`, `.catch(() => {})`, `.catch(() => null)`, un-awaited promise, `fetch` without `response.ok`
- Shell/Nushell: unchecked non-zero exit, `| ignore` on a fallible command

`unwrap_or(false)` is the canonical offender: it turns "could not evaluate" into "evaluated, answer is no".

## 2. Never collapse "failed" into a legitimate in-band value

An error MUST NOT map onto a value a successful call could return: `Err` -> `false`, exception -> `None`/`null`/`0`/`[]`,
500 -> empty list. A placeholder for failed or missing data ("Someone", "Unknown", "N/A", "-", "", 0, epoch, default
avatar or id) is allowed only when it carries the cause where the person can reach it (a hover tooltip naming the id)
AND the failure is logged with the id. A fallback is the second statement, never the whole handling: log the cause
first, at a level matching the consequence.

## 3. A failure must be visible at every layer it crosses

- **Log**: one line with the underlying cause, naming the id or value.
- **Status/exit code**: a failure NEVER answers `200`, exit `0`, or a success sentinel.
- **Transport/client**: what the server rendered must reach the screen. `hx-swap="none"`, a swallowed rejection, a toast
  that never fires, or a framework that renders only `2xx` re-hides it.
- **Human**: the person sees what failed and why, where they are looking, in the same interaction. "It is in the log"
  is not visible.

When a status code and a rendering mechanism disagree (a `4xx` a client refuses to render), fix the rendering and verify
BOTH together; returning `200` is never the fix.

## 4. Forbidden masking shapes

1. Placeholder for failed data with no trace (section 2).
2. Default or coalesce on data the contract says must exist: `??`, `||`, `.get(k, default)`, `or ""`, `COALESCE`,
   `${VAR:-default}`, `#[serde(default)]`, making a required field optional so a type check passes.
3. Dropping the odd item: filter, skip, `continue`, `flatten`, `LIMIT` over rows that failed to parse or resolve;
   clamping; dedupe that hides a conflict; trimming or coercing input that should be rejected.
4. Catch-all for the unexpected: `_ =>` / `default:` / `else` on a closed set, an unknown variant mapped to a known
   one, a "tolerant" parser.
5. Silencing the signal: deleting, filtering, or down-levelling a log line below its consequence; `allow` / `noqa` /
   `type: ignore` / `@ts-ignore` / `eslint-disable` / `2>/dev/null` / `|| true`; a non-blocking check; a baseline or
   ignore entry.
6. Making the test pass instead of the code: weakened or deleted assertion, a mock returning the fallback, a snapshot
   re-recorded over a regression, `skip` / `xfail`, retry-until-green, a sleep or raised timeout dodging a race.
7. Retry, restart, cache-bust, or second-source fallback with no log of the first failure and no investigation.
8. Hiding it in presentation: `display: none`, an empty state reading "no data" when the call failed, a spinner that
   never resolves, a count omitting failures.
9. Pin, shim, or version-lock to avoid a bug in code we control or can fix upstream.

## 5. What to do instead

1. Find the cause with evidence (`troubleshooting.md`, `verify-source-of-truth.md`) and fix it there.
2. Data absent BY CONTRACT (optional in the schema) is its own state: `None`/null in the model and an explicit "not set"
   in the UI, visibly different from every real value. Failure is never absence.
3. A cause that cannot be fixed now (upstream bug, human action) is shown as an explicit failure where the person is
   looking, logged, answered with a non-success status, and tracked in a linked issue. It stays visible while pending.
4. Unexpected input, state, or variant fails fast with the offending value in the message; matches over closed sets are
   exhaustive with no wildcard arm.
5. Warnings are defects: fix them. A test must fail before the fix and pass after; run both and report both.

## 6. Deliberate suppression is allowed, but only out loud

Best-effort paths exist. A suppressed error is acceptable ONLY when all three hold: (1) it is logged at a level matching
the consequence, (2) a comment states WHY proceeding is correct, (3) nothing downstream reads the outcome as success,
plus a linked issue when it is a masking shape from section 4. A bare `let _ =` or empty `catch` is never acceptable,
even for telemetry or a "best-effort" write.

## 7. Diagnosis and reporting

- Never call a change "fixed", "handled", or "resolved" when it only changes what is displayed or logged. State the
  root cause. Never offer a masking workaround, including a "temporary" one.
- Never say "the code gets fixed, not masked" without the cause already located.
- If the investigation is unfinished, say so. Do not ship a patch that makes the symptom go away.

## 8. Blocking sweep, before ANY change is done

Grep the diff and the surrounding file for the shapes in sections 1, 2 and 4. Print a table: hit, classification
(compliant / root-cause fix / optional-by-contract with schema cited / suppressed per section 6 with reason /
violation), verdict. Fix violations in the same change, including masking in the failure path of what you are fixing.
Masking elsewhere is a code defect: file it per `completeness-invariant-sweep.md`.

**Why:** one incident returned a correct error message with status `200`, and `hx-swap="none"` discarded it, so an
operator assumed success and was locked out of production. A "Someone" label hid a failed roster lookup because nothing
named the id. Every layer looked correct; the failure was invisible.
