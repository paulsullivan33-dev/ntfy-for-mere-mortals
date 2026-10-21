# Glossary

Plain definitions, in the order the
ideas appear. Chapter numbers point at
where each one does its work.

**Topic** — a named channel on a
server. Publishing and subscribing are
both addressed to a topic; a topic
exists by being used. Chapter 1.

**Publish** — send a message to a
topic: an HTTP POST or PUT with the
message as the body. Chapter 2.

**Server** — the ntfy process that
receives messages, caches them, and
forwards them to subscribers. The
public one is `ntfy.sh`; the lab's is
your own. Chapter 1, chapter 7.

**Message** — one notification: a
text, plus whatever of the anatomy
below it carries. Identified on the
server by a twelve-character `id`,
accepted at `time`, forgotten at
`expires`. Chapter 2.

**Receipt** — the JSON the server
returns for a publish, and the same
JSON subscribers receive. If a field
is absent from it, the message does
not have that field. Chapter 2.

**Title** — a message's optional bold
first line (`X-Title`). Chapter 3.

**Priority** — how insistently the
receiving device presents a message:
1 (`min`) to 5 (`max`), default 3.
Carried as a number; absent from the
receipt when default. Chapter 3.

**Tag** — a comma-separated label on a
message (`X-Tags`). Some tags render
as emoji on receiving apps, which
decide that for themselves. Chapter 3.

**Action** — a button on a
notification (`X-Actions`): a `view`
action opens an address, an `http`
action makes a request. Chapter 3.

**Click** — the address a tap on the
notification opens (`X-Click`).
Chapter 3.

**Subscribe** — open a GET on a topic
and stay: the server writes each new
message as it is published.
Chapter 4.

**Stream** — a held-open subscription
in one of three shapes: `json` (one
object per line), `sse`
(Server-Sent Events), or `raw` (bare
message texts). Chapter 4.

**Open event** — the first line of a
stream, `event: "open"`: the server
confirming the subscription is live,
before any message. Chapter 4.

**Cache** — the server's memory of
recent messages: 12 hours by default,
in the file `cache-file` names.
Chapter 5.

**Poll** — ask once and close:
`?poll=1` returns the cached messages
instead of holding the connection.
Chapter 5.

**Since** — where a poll or
subscription starts reading: a
duration, a timestamp, or a message
ID — meaning strictly *after* the
named message. Chapter 5.

**Delay** — publish now, deliver
later (`X-Delay`): 10 seconds to
3 days, documented range. Chapter 6.

**Attachment** — the one file a
message can carry, uploaded with the
message and kept for 3 hours by
default, under its own address.
Chapter 6.

**Message size limit** — the boundary
(`message-size-limit`, default `4k`)
below which a request body is a
message and at which it becomes a
file. Chapter 6.

**Config file** — the server's one
YAML file (`server.yml`): listen
address, base address, and the paths
of the three state files. Chapter 7.

**Base URL** — the address the server
believes it lives at, used to build
the links it hands out. Chapter 7.

**Auth file** — the user database
(`auth-file`). Without one, a server
has no users, only the default access.
Chapter 7, chapter 8.

**Default access** —
`auth-default-access`: what a request
with no matching grant may do, from
`read-write` down to `deny-all`.
Chapter 8.

**Grant** — one user's allowed access
to one topic (`read-write`,
`read-only`, `write-only`, or none),
made with `ntfy access`. Chapter 8.

**Role** — a user's standing: an
`admin` reads and writes everything;
a `user` has only their grants.
Chapter 8.

**Anonymous (the `*` user)** —
everyone with no login: exactly what
the default access says, and nothing
more. Chapter 8.

**401 / 403** — the locked server's
two refusals: *unauthorized* (your
credentials were not believed) and
*forbidden* (you were believed, and
the answer is no). Chapter 8,
chapter 11.

**Token** — a per-user access key
issued by `ntfy token`, so scripts
need not carry the account password.
Named in chapter 8; documented, not
run, in this guide.

**Web app** — the interface the server
serves at its own root address:
subscribe, read, and publish from a
browser. Chapter 1, chapter 4.
