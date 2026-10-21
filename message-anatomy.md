# Message Anatomy

**Scope:** the optional parts of a
message — title, priority, tags, and a
few display extras — set as HTTP
headers, and what each one is for.

A plain message is one line of text,
and for many jobs that is enough. The
extras exist for the moment the message
lands on a phone, where the first
question is not "what does it say" but
"do I need to look at this now." They
are set with headers when publishing
with `curl` (`-H "X-Title: ..."`), with
flags when publishing with the `ntfy`
command (`--title ...`), or as fields
in the JSON form from chapter 2. All
three routes produce the same message.

## Title, priority, tags

```
$ curl -s -H "X-Title: Backup" -H "X-Priority: 5" -H "X-Tags: floppy_disk,warning" -d "Nightly backup failed" http://127.0.0.1:8099/lab-alerts
{"id":"UEaJynbc46zy","time":1792610721,"expires":1792653921,"event":"message","topic":"lab-alerts","title":"Backup","message":"Nightly backup failed","priority":5,"tags":["floppy_disk","warning"]}
```

- **Title** (`X-Title` / `--title`) —
  the bold first line of the
  notification. Keep it to a few words:
  it answers "what is this about" before
  the message is opened.
- **Priority** (`X-Priority` /
  `--priority`) — how insistently the
  receiving device presents the message.
  It is a number from 1 to 5, and the
  names work anywhere the number does:

  | Value | Name | Meaning |
  |---|---|---|
  | 1 | `min` | quietest; no sound, folded away |
  | 2 | `low` | present, but unobtrusive |
  | 3 | *(default)* | the ordinary notification |
  | 4 | `high` | prominent |
  | 5 | `max` | most insistent the device allows |

  The default row is written the way it
  is because a plain message's receipt
  has *no* `priority` field at all —
  absence means 3. How a device renders
  each level (sounds, vibration,
  bypassing a quiet mode) is the phone
  app's business and differs between
  Android and iOS; the server only
  carries the number. Priority is a
  budget: a topic where everything is
  `max` teaches its owner to ignore it.
- **Tags** (`X-Tags` / `--tags`) —
  comma-separated labels, carried as a
  list in the receipt. Tags are free
  text for your own organising, with
  one decoration: a tag that names a
  standard emoji shortcode (like
  `warning` or `white_check_mark`)
  is shown as that emoji by the phone
  and web apps, in front of the title.
  That rendering happens on the
  receiving side; the message itself
  only ever carries the names.

Check: the server validates what it
can. A priority outside 1–5 is refused
on the spot, with the reason and a link
to the relevant page of the manual:

```
$ curl -s -w "\nHTTP %{http_code}\n" -H "X-Priority: 9" -d "Loud" http://127.0.0.1:8099/lab-alerts
{"code":40007,"http":400,"error":"invalid priority parameter: 9, please refer to the docs","link":"https://ntfy.sh/docs/publish/#message-priority"}

HTTP 400
```

Every ntfy error has this shape — a
`code`, the HTTP status, an `error`
sentence meant for humans, and `link`.
When ntfy says no, it says why.

## Display extras

Three more headers shape how a message
is presented. All three were verified
the same way as above, by reading them
back in the receipt; what a phone does
with them is the app's side of the
bargain.

**Markdown** — the message body is
Markdown, and the web and phone apps
render it as such:

```
$ curl -s -u alice:alice-lab-pass -H "X-Markdown: true" -d "**Bold** news about the build" http://127.0.0.1:8099/lab-private
{"id":"40TjEe61KVnn","time":1792611234,"expires":1792654434,"event":"message","topic":"lab-private","message":"**Bold** news about the build","content_type":"text/markdown"}
```

**Click** (`X-Click`) — the address a
tap on the notification opens:

```
$ curl -s -u alice:alice-lab-pass -H "X-Click: https://example.org/builds/412" -d "Build finished, tap for the log" http://127.0.0.1:8099/lab-private
{"id":"Nie5iWb2Nlo0","time":1792611407,"expires":1792654607,"event":"message","topic":"lab-private","message":"Build finished, tap for the log","click":"https://example.org/builds/412"}
```

**Actions** (`X-Actions`) — up to
three buttons on the notification. A
`view` action opens an address; `http`
actions make a request of your
choosing, which is how a notification
grows an "acknowledge" or "restart it"
button:

```
$ curl -s -u alice:alice-lab-pass -H "X-Actions: view, Open the build log, https://example.org/builds/412" -d "Build 412 finished" http://127.0.0.1:8099/lab-private
{"id":"GEJbnd0AJyAX","time":1792611235,"expires":1792654435,"event":"message","topic":"lab-private","message":"Build 412 finished","actions":[{"id":"Fpl57zmrfW","action":"view","label":"Open the build log","clear":false,"url":"https://example.org/builds/412"}]}
```

The receipt shows the header parsed into
a small object — the button's own `id`,
its `label`, where it goes. An `http`
action is a standing instruction from a
message to a phone, and phones ask
before obeying some of them; treat
actions as a convenience for the
reader, never as a mechanism something
depends on.

**Check:** publish with one extra at a
time and read it back in the receipt.
If a field is missing from the receipt,
the message does not have it — spelling
of header names is the usual suspect
(chapter 11).
