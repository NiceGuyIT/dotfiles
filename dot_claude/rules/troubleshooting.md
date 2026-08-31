# Troubleshooting Rules

- **Verify the source of truth FIRST.** See `verify-source-of-truth.md`; it is mandatory for every investigation, and no
  hypothesis, finding, or "fixed" claim is made from cached state.
- **Three-strike red herring rule:** If the same symptom persists after 3 fix attempts targeting the same area, STOP.
  Flag it as a likely red herring and broaden the investigation:
    1. Re-examine the full error context and surrounding system (not just the error message).
    2. Check assumptions: are the inputs what we think they are? Add debug output to verify.
    3. Look upstream: the root cause is likely in a different layer (caller, config, environment, permissions) than
       where
       the symptom appears.
    4. Explicitly tell the user: "We've tried fixing X three times. The real problem is probably elsewhere. Let me step
       back and look at the bigger picture."
- Before proposing a fix, verify the hypothesis first. Prefer adding debug/diagnostic output to confirm the cause before
  changing code speculatively.
