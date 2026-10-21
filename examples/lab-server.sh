#!/bin/sh
# lab-server.sh -- run the lab ntfy server in the
# foreground, with the config beside this script.
#
# Usage:  sh lab-server.sh
# Stop it with Ctrl-C. The server is the same
# "ntfy" binary the chapters use as a client;
# set NTFY_BIN if yours lives somewhere unusual:
#   NTFY_BIN=/path/to/ntfy sh lab-server.sh

set -eu
cd "$(dirname "$0")"
mkdir -p ntfy-data/attachments
BIN=${NTFY_BIN:-ntfy}
exec "$BIN" serve --config server.yml
