# Catching Up

**Scope:** the server's cache — how
long messages are kept, how a
subscriber reads what it missed, and
the `since` parameter that says *from
where*.

A live subscription only shows what
arrives while it is open. Phones sleep,
laptops close, scripts restart — so
the server keeps what it is given. By
default, in the config the project
ships, a message is cached for
**12 hours**; you saw the arithmetic in
chapter 2's receipts, where every
`expires` was its `time` plus 43,200
seconds. After that the server forgets
it, entirely and by design: ntfy is a
notification pipe, not an archive, and
anything you must keep belongs in the
subscriber's own log.

## Poll instead of holding open

Add `?poll=1` to a stream address and
the GET answers with the cached
messages and *closes*, instead of
holding the connection open. It is the
one-shot form of subscribing — what a
script on a timer, or a subscriber that
cannot hold connections, uses:

```
$ curl -s "http://127.0.0.1:8099/lab-alerts/json?poll=1" | head -3
{"id":"4ygK7OOqgGJu","time":1792610682,"expires":1792653882,"event":"message","topic":"lab-alerts","message":"Backup finished"}
{"id":"SMGFlQuc9OWj","time":1792610682,"expires":1792653882,"event":"message","topic":"lab-alerts","message":"Door sensor tripped"}
{"id":"f8ufxERBPiyw","time":1792610695,"expires":1792653895,"event":"message","topic":"lab-alerts","message":"Backup finished"}
$ curl -s "http://127.0.0.1:8099/lab-alerts/json?poll=1" | wc -l
12
```

Twelve lines: everything the lab had
published to that topic so far, in
order, oldest first. A poll with
nothing cached returns nothing and
exits — no error, no open event, just
empty output.

## since: starting part-way back

`since` narrows the window. It accepts
a duration (`10m`, `1h`), a Unix
timestamp, or a message ID — and the
three forms answer three different
questions. The duration answers "what
did I miss while I was away":

```
$ curl -s "http://127.0.0.1:8099/lab-alerts/json?poll=1&since=1m"
{"id":"SMGFlQuc9OWj","time":1792610682,"expires":1792653882,"event":"message","topic":"lab-alerts","message":"Door sensor tripped"}
{"id":"f8ufxERBPiyw","time":1792610695,"expires":1792653895,"event":"message","topic":"lab-alerts","message":"Backup finished"}
... (3 more lines trimmed; 5 in all)
```

The ID answers "everything after the
last one I processed" — the form a
careful subscriber stores between runs,
so it resumes exactly where it stopped:

```
$ curl -s "http://127.0.0.1:8099/lab-alerts/json?poll=1&since=MTtUHLNTFxlY"
[no output: that ID was the newest message, and since=<id> means strictly after it]
```

The empty answer is the lesson.
`since=<id>` means *after that
message*, not *from that message* — the
named message itself is never included.
Expecting it to be is the classic
off-by-one of this API, and it is
harmless exactly as long as you know
it: store the last ID you *handled*,
and the next poll picks up at the one
after.

The CLI has the same idea built in:
`ntfy subscribe --poll` polls once and
exits. On the locked topic of chapter
8, as alice:

```
$ ntfy subscribe --poll --user alice:alice-lab-pass http://127.0.0.1:8099/lab-private
{"id":"8m7OCDtUaLod","time":1792611170,"expires":1792654370,"event":"message","topic":"lab-private","message":"Private backup finished"}
{"id":"RNjDBeaWzwcV","time":1792611228,"expires":1792654428,"event":"message","topic":"lab-private","title":"From JSON","message":"A short JSON message","priority":2,"tags":["test"]}
... (3 more lines trimmed: this topic's whole cache at capture time)
[exit 0: it printed the cached messages and ended on its own]
```

Check: poll a topic twice in a row.
The same messages come back both
times, unchanged — polling reads the
cache, it does not consume it. Messages
leave only by expiring.
