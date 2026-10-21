#!/bin/sh
# notify-done.sh -- run a command, then publish
# how it ended to an ntfy topic.
#
# Usage:  sh notify-done.sh <command> [args...]
#
# Environment:
#   NTFY_SERVER   default http://127.0.0.1:8099
#   NTFY_TOPIC    default lab-alerts
#   NTFY_USER     optional, user:password for a
#                 server with access control
#
# The command's own output is inherited, not
# swallowed. The notification reports the exit
# code: priority "high" with a warning tag when
# the command failed, a plain message when it
# succeeded. The script exits with the command's
# own exit code, so it composes with && and ||.

set -u
SERVER=${NTFY_SERVER:-http://127.0.0.1:8099}
TOPIC=${NTFY_TOPIC:-lab-alerts}

if [ $# -eq 0 ]; then
  echo "usage: sh notify-done.sh <command> [args...]" >&2
  exit 2
fi

"$@"
code=$?

auth=""
[ -n "${NTFY_USER:-}" ] && auth="-u $NTFY_USER"

if [ "$code" -eq 0 ]; then
  curl -s $auth -H "X-Title: Command finished" \
    -d "$* — finished OK" "$SERVER/$TOPIC" >/dev/null
else
  curl -s $auth -H "X-Title: Command failed" \
    -H "X-Priority: high" -H "X-Tags: warning" \
    -d "$* — FAILED with exit code $code" "$SERVER/$TOPIC" >/dev/null
fi

exit "$code"
