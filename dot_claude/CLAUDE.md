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
- Safety: NEVER use force flags (rm -rf, --force, save --force, etc.) — failures without force reveal real bugs

# Troubleshooting Rules

- **Three-strike red herring rule:** If the same symptom persists after 3 fix attempts targeting the same area, STOP.
  Flag it as a likely red herring and broaden the investigation:
  1. Re-examine the full error context and surrounding system (not just the error message).
  2. Check assumptions: are the inputs what we think they are? Add debug output to verify.
  3. Look upstream: the root cause is likely in a different layer (caller, config, environment, permissions) than where
     the symptom appears.
  4. Explicitly tell the user: "We've tried fixing X three times. The real problem is probably elsewhere. Let me step
     back and look at the bigger picture."
- Before proposing a fix, verify the hypothesis first. Prefer adding debug/diagnostic output to confirm the cause before
  changing code speculatively.
