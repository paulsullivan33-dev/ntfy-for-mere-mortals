# Publishing

**Scope:** getting a message onto a
topic — with `curl`, with the `ntfy`
command, and as JSON — and reading the
receipt the server hands back.

## With curl: a POST and a body

Publishing is an HTTP POST to the topic's
address, with the message as the request
body. Nothing else is required:

```
$ curl -s -d "Backup finished" http://127.0.0.1:8099/lab-alerts
{"id":"4ygK7OOqgGJu","time":1792610682,"expires":1792653882,"event":"message","topic":"lab-alerts","message":"Backup finished"}
```

Read the receipt; it teaches the shape
of every message in this guide:

- `id` — the message's name on the
  server, twelve characters. Chapter 5
  uses IDs to say "everything after
  this one."
- `time` — when the server accepted it,
  as a Unix timestamp (seconds since
  1970, UTC).
- `expires` — when the server will
  forget it. Here it is exactly
  `time` + 43,200 seconds: the cache
  keeps messages for **12 hours** by
  default, and chapter 5 is about
  reading them back before they go.
- `event` — `message`. Other events
  exist (a subscription opening, a
  keep-alive); subscribers meet them
  in chapter 4.
- `topic` and `message` — what you
  sent, on the topic you sent it to.

A PUT works exactly as a POST does —
some tools find one easier to emit than
the other:

```
$ curl -s -X PUT -d "Door sensor tripped" http://127.0.0.1:8099/lab-alerts
{"id":"SMGFlQuc9OWj","time":1792610682,"expires":1792653882,"event":"message","topic":"lab-alerts","message":"Door sensor tripped"}
```

That is the whole of the core protocol,
and it is worth pausing on how little of
it there is: no session, no handshake,
no encoding ceremony. If a program in
any language can make one HTTP request,
it can notify you.

## With the ntfy command

The `ntfy` binary is also the client.
Its `publish` takes the topic's full
address and the message:

```
$ ntfy publish http://127.0.0.1:8099/lab-alerts "Backup finished"
{"id":"f8ufxERBPiyw","time":1792610695,"expires":1792653895,"event":"message","topic":"lab-alerts","message":"Backup finished"}
```

The receipt is the same JSON. What the
command buys over `curl` is options as
flags instead of headers — chapter 3's
anatomy, in flag form:

```
$ ntfy publish --title "Nightly build" --priority high --tags white_check_mark,computer http://127.0.0.1:8099/lab-alerts "Build 412 passed"
{"id":"KhAj9FdJuImx","time":1792610695,"expires":1792653895,"event":"message","topic":"lab-alerts","title":"Nightly build","message":"Build 412 passed","priority":4,"tags":["white_check_mark","computer"]}
```

Note the receipt growing the fields the
flags set: `title`, `priority` (the word
`high` has become the number 4), and
`tags` as a list. A message with no
extras has none of those fields — the
receipt shows what a message *has*, not
a template with blanks.

## As JSON

Programs that already speak JSON can
publish by POSTing a JSON object to the
server's root instead of the topic
address, naming the topic inside. Here
it is against the locked lab of chapter
8, so it carries alice's credentials:

```
$ curl -s -u alice:alice-lab-pass -d '{"topic": "lab-private", "title": "From JSON", "message": "A short JSON message", "priority": 2, "tags": ["test"]}' http://127.0.0.1:8099/
{"id":"RNjDBeaWzwcV","time":1792611228,"expires":1792654428,"event":"message","topic":"lab-private","title":"From JSON","message":"A short JSON message","priority":2,"tags":["test"]}
```

Every field from chapter 3 can be set
this way, with the same names the
receipt uses. JSON is the form to reach
for when a program is building the
message out of its own data structures;
the header form of the next chapter is
the form to reach for from a shell.

**Check:** whichever form you used, the
publish returned HTTP 200 and a receipt
whose `message` is the text you sent.
Anything else — a 400 with an `error`
field, a 401 or 403 — is the server
explaining itself; chapter 11 collects
those explanations.
