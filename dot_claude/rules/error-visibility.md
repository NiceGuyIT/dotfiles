# Error Visibility (MANDATORY, every change)

An error that is not visible did not get handled; it got hidden. A failure MUST remain distinguishable from a success at
every layer it crosses, and MUST reach both a log and the human who triggered it. Silence is a defect, and it is a worse
defect than the failure it conceals, because the failure is now unreportable and undiagnosable.

This rule exists because "handle your errors" does not catch the failure that motivates it. In one production incident
the error WAS handled: the server detected the bad input, rendered the correct message, and returned it. The response
body was then discarded by `hx-swap="none"` one layer up, and the status was `200`. The operator saw a page that did
nothing, assumed success, and was locked out of production with the database as the only witness. Every individual
layer looked correct.

## 1. Never discard an error value

Forbidden in every language, no exceptions without the explicit justification in section 4:

- Rust: `unwrap_or`, `unwrap_or_default`, `unwrap_or_else` on a `Result`, `.ok()` used to drop an `Err`, `let _ = ...`
  on a `Result`, `if let Ok(x)` with no `else`
- Go: `if err != nil {}` with an empty or log-less body, `_ = f()`, named returns that shadow an error
- Python: `except: pass`, `except Exception:` that neither re-raises nor logs, a bare `finally` that swallows
- JS/TS: empty `catch {}`, `.catch(() => {})`, `.catch(() => null)`, an un-awaited promise, `fetch` without checking
  `response.ok`
- Shell/Nushell: a pipeline whose non-zero exit is unchecked, `| ignore` on a fallible command, missing `set -e` intent

`unwrap_or(false)` is the canonical offender: it converts "I could not evaluate this" into "I evaluated it, the answer
is no". Those are different facts and the caller cannot tell them apart afterwards.

## 2. Never collapse "failed" into a legitimate in-band value

An error MUST NOT be mapped onto a value that a successful call could also return. `Err` becoming `false`, an exception
becoming `None`/`null`/`0`/`[]`, a 500 becoming an empty list: in every case the caller now cannot distinguish a broken
dependency from a real negative result, and the bug becomes invisible at the call site AND in the logs.

If a fallback value is genuinely wanted, the error is logged at `error` (or `warn` for a true best-effort path) BEFORE
the substitution, naming the underlying cause. The fallback is the second statement, never the whole handling.

## 3. A failure must be visible at every layer it crosses

Check each layer the failure passes through, and name them in the change:

- **Log**: one line, at `error` unless it is genuinely expected, carrying the underlying cause, not a generic string.
- **Status/exit code**: a failure NEVER answers `200`, exit `0`, or a success sentinel. A rendered error page with a
  `200` is a lie told to every proxy, log, monitor, and test that reads the status.
- **Transport/client**: whatever the server rendered must actually reach the screen. A client that discards, ignores, or
  fails to swap the error body has re-hidden it. `hx-swap="none"`, a swallowed rejection, a toast that never fires, and a
  framework that only renders `2xx` are all this bug.
- **Human**: the person who triggered the action sees what failed and why, where they are looking, in the same
  interaction. "It is in the log" is not visible; nobody was reading the log.

When a status code and a rendering mechanism disagree (a `4xx` that a client refuses to render), that is not a reason to
return `200`. Fix the rendering and verify BOTH together, because satisfying either alone silently restores the defect.

## 4. Deliberate suppression is allowed, but only out loud

Best-effort paths exist. A suppressed error is acceptable ONLY when all three hold:

1. It is logged, at a level that matches the consequence.
2. A comment states WHY proceeding is correct despite the failure.
3. Nothing downstream reads the suppressed outcome as if it had succeeded.

A bare `let _ =` or an empty `catch` satisfies none of these and is never acceptable, even for telemetry, metrics, or a
"best-effort" write. `let _ = touch_last_login(...)` is what made a login timestamp unreliable as evidence during an
outage.

## 5. Blocking sweep, before ANY change is done

Grep the diff (and the file around it) for the shapes in section 1. Classify every hit as compliant, violating, or
suppressed-per-section-4-with-its-reason. Fix the violations in the same change. Print the classified table in the
response, exactly as the Completeness / Invariant Sweep requires. Reviewing only the lines you touched is not enough
when the surrounding function already swallows.

**Why:** a silent failure costs more than a loud one, always. A loud failure is a bug report; a silent failure is a
support incident with no evidence, and the person paying for it is the operator who trusted the screen.
