# Subscribing

**Scope:** the receiving end — the
`ntfy` command held open, the raw HTTP
streams under it, and subscriptions
that run a command per message.

Subscribing is publishing turned around:
a GET to the topic's address that does
not end. The server holds the connection
open and writes each new message as it
is published. Nothing polls; the message
arrives when it arrives.

## With the ntfy command

```
$ ntfy subscribe http://127.0.0.1:8099/lab-alerts
{"id":"0nLWsWUJqPGW","time":1792610704,"expires":1792653904,"event":"message","topic":"lab-alerts","message":"Live from the second shell"}
```

The command prints each message as one
line of JSON — the same receipt shape
chapter 2 published — and keeps running
until you stop it (Ctrl-C). It shows
only messages published *after* it
started; what came before is the cache's
story, and it is chapter 5. (In the
capture above, a second shell published
to `lab-alerts` while this one listened.
Yours will sit silent until something
publishes — silence means an idle
topic, not a broken one.)

The browser-shaped subscription is the
**web app**: the server's root address,
which answered 200 in chapter 1, is a
page where you subscribe to topics and
read them in the browser, with the
titles, tags, and priorities of chapter
3 rendered. The phone apps subscribe
the same way under the hood. Their
behaviour — background delivery, sounds
per priority — belongs to the phone and
could not be exercised by this guide's
lab; it is listed as documented-only in
`criteria.md`.

## The raw streams

The CLI is a convenience over three
stream formats, all the same held-open
GET with a different suffix:

- **`/<topic>/json`** — one JSON object
  per line (the format the CLI prints).
- **`/<topic>/sse`** — the same events
  in Server-Sent Events framing, the
  shape browsers consume natively.
- **`/<topic>/raw`** — nothing but the
  message texts, one per line: the
  format for feeding another program
  that wants words, not objects.

Check: the JSON stream, held open while
a second shell publishes:

```
$ curl -sN http://127.0.0.1:8099/lab-alerts/json
{"id":"nKb6DpNVimbX","time":1792610763,"expires":1792653963,"event":"open","topic":"lab-alerts"}
{"id":"G4ZLRJfSgCsK","time":1792610763,"expires":1792653963,"event":"message","topic":"lab-alerts","message":"Streamed over HTTP"}
$ curl -s -d "Streamed over HTTP" http://127.0.0.1:8099/lab-alerts
$ curl -sN http://127.0.0.1:8099/lab-alerts/sse
event: open
data: {"id":"v11J4nryKtFr","time":1792610763,"expires":1792653963,"event":"open","topic":"lab-alerts"}

event: message
data: {"id":"bOFzswkTTTAX","time":1792610763,"expires":1792653963,"event":"message","topic":"lab-alerts","message":"Streamed over SSE"}
```

Two things to notice. The first line of
a stream is an `open` event, not a
message — the server announcing that
the subscription is live, so a program
can tell "connected, nothing yet" from
"not connected." And `curl` needs `-N`
(unbuffered) to show lines as they
arrive; without it the stream still
flows, but your terminal shows it in
lumps and you may conclude — wrongly —
that nothing is happening. If a held-
open subscription looks dead, buffering
is the first suspect (chapter 11).

The raw stream, for contrast — bob is
reading the locked `lab-private` topic
of chapter 8, credentials and all, and
what arrives is bare text:

```
$ curl -sN -u bob:bob-lab-pass http://127.0.0.1:8099/lab-private/raw   (held open; the publish above arrives)

Build finished, tap for the log
```

## Subscriptions that act

Give `ntfy subscribe` a command after
the topic address and it runs that
command once per message instead of
printing. The message's fields arrive
as environment variables — `$id`,
`$time`, `$topic`, `$title`, `$message`,
`$priority`, `$tags`:

```
$ ntfy subscribe --user alice:alice-lab-pass http://127.0.0.1:8099/lab-private 'echo "GOT: [$priority] $title - $message"'
$ curl -s -u alice:alice-lab-pass -H "X-Title: Sensor" -H "X-Priority: 4" -d "Door opened" http://127.0.0.1:8099/lab-private
--- what the subscribe command printed ---
GOT: [4] Sensor - Door opened
```

This is the pattern that turns a
notification service into a trigger: a
message on a topic starts a script on
the machine that heard it. Hold it to
the same standard as any other remote
trigger — it runs, as you, whatever the
message says to run. On a server anyone
can publish to, that is a door, not a
feature; chapter 8's access control is
what makes it a reasonable one.
