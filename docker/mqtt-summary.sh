#!/bin/sh

# Write an Orb summary to stdout while keeping the per-invocation startup
# banner out of normal logs. File descriptor 3 carries the real stdout out of
# the command substitution so only stderr is captured in ORB_ERRS. Tests may
# pass a stub Orb executable as the first argument.
emit_orb_summary() {
  (
    ORB_ERRS=$("${1:-/app/orb}" summary 2>&1 >&3)
    ORB_RC=$?

    if [ "$ORB_RC" -ne 0 ]; then
      echo "orb summary failed (exit $ORB_RC):" >&2
      [ -n "$ORB_ERRS" ] && printf '%s\n' "$ORB_ERRS" >&2
      echo '{}'
    elif [ "$DEBUG_MODE" = "true" ] && [ -n "$ORB_ERRS" ]; then
      printf '%s\n' "$ORB_ERRS" >&2
    fi
  ) 3>&1
}
