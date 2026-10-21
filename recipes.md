# Recipes

**Scope:** the guide's parts assembled
into the jobs people actually give a
notification service. Every mechanism
used here was run in its own chapter;
this chapter is arrangements, not new
claims.

## "Tell me when this finishes"

The canonical job: a command that runs
for a long time, and a human who does
not want to watch it. `examples/
notify-done.sh` wraps any command,
publishes how it ended, and exits with
the command's own exit code:

```
sh notify-done.sh ./backup.sh
sh notify-done.sh make release
```

On success it publishes a plain
message; on failure the message
carries the exit code, priority
`high`, and the `warning` tag — so a
failure buzzes differently from a
success at 3 a.m., which is the entire
point (chapter 3). Point it at a
locked server by setting `NTFY_USER`,
`NTFY_SERVER`, and `NTFY_TOPIC` in the
environment. Because it re-exits with
the wrapped code, it drops into
existing scripts without changing
their logic:

```
sh notify-done.sh ./backup.sh && echo "and the chain continues"
```

## The one-liner, for when a script is too much

The same job inline, for a command
already written:

```
./backup.sh; curl -s -d "Backup done: $?" http://127.0.0.1:8099/lab-alerts
```

`$?` is the command's exit code, so
the message itself reports it. The
publish's own receipt is discarded
with `-s` and the redirect of your
choice; chapter 2's captures show
what it would have said.

## A sensor speaks

Anything that can make one HTTP
request can be a publisher — a sensor
gateway, a cron job, a router script.
The pattern is chapter 2's PUT with a
title and a priority matched to how
much the event should demand:

```
curl -s -H "X-Title: Front door" -H "X-Priority: high" -d "Door opened after midnight" http://127.0.0.1:8099/lab-alerts
```

Keep the publisher dumb and the
message honest: the text is what the
human reads half-asleep, so it says
what happened, not which script fired.

## Remind me later, from the machine

Chapter 6's delay, used as a kitchen
timer for computers — plant it when
the thought occurs:

```
curl -s -H "X-Delay: 2h" -H "X-Title: Reminder" -d "Check the long restore job" http://127.0.0.1:8099/lab-alerts
```

The server is the timer; nobody's
script has to stay alive for the two
hours. (And its limit applies: the
server has to still be up, cache
intact, when the moment comes.)

## A topic as a log that reads itself

Chapter 4's command-running
subscription, aimed at a file, turns a
topic into an append-only log with
zero machinery:

```
ntfy subscribe http://127.0.0.1:8099/lab-alerts 'echo "$time $topic: $message" >> ~/notifications.log'
```

Every message lands as a line. The
cache forgets after 12 hours
(chapter 5); the log does not, which
is the difference between a
notification and a record, kept on
purpose at the receiving end.

## Priority discipline

The recipe nobody writes down: decide
a topic's rules once, and publish by
them. A workable set, from the guide's
own examples — success is the default
priority (3) or lower, and silent in
the title; failure is `high` (4) with
the `warning` tag; `max` (5) is
reserved for the one event per topic
that should wake someone. The phone
will do the rest. The moment a topic
cries `max` weekly, its owner has
muted it, and no setting in chapter 3
gets that trust back.
