# Troubleshooting

**Scope:** failures, matched to the
evidence for each. The server explains
itself in the error JSON of chapter 3
— a `code`, an HTTP status, and a
sentence — so most diagnosis starts by
reading the answer instead of guessing
at it.

## Symptom: publishing returns HTTP 403, "forbidden"

**Cause:** the server knows who is
asking (or that nobody is) and the
answer is no: anonymous publishing on
a `deny-all` server, a user publishing
to a topic they have no write grant
on, or a subscription reading a topic
without a read grant. Chapter 8
captured all three shapes.

**Fix:** check the grants
(`ntfy access`, with the config
pointer from chapter 8), check which
user the request authenticated as —
and if you expected an open server,
check `auth-default-access` in the
config the server actually started
with.

## Symptom: publishing returns HTTP 401, "unauthorized"

**Cause:** credentials were offered
and not believed — a wrong password, a
misspelt user, or credentials sent in
a form the client mangled. 401 is
about *identity*; 403 is about
*permission*. A wrong password never
becomes right by adding grants.

**Fix:** retype the password; try the
same request interactively before
blaming the script; if the user was
just created, confirm which auth
database the user command edited —
the next symptom is that trap.

## Symptom: `ntfy user` says the auth database is not configured, or new users have no effect

**Cause:** the user and access
commands edit an auth file they find
through the server config — and, in
2.x, `--config` is not a global flag,
so pointing them at your config the
obvious way fails:

```
$ ntfy --config server.yml user add alice
Incorrect Usage: flag provided but not defined: -config
```

**Fix:** point with the environment
variable (or the `--config` flag those
commands carry themselves), from
chapter 8:

```
export NTFY_CONFIG_FILE=/path/to/server.yml
ntfy user list
```

Check: `user list` shows the users you
expect *before* you change anything —
including the `*` anonymous line with
the server-config default you
intended.

## Symptom: a subscriber sees nothing

**Cause:** the usual four, in order.
The topic name differs by one
character between publisher and
subscriber (topics are exact strings,
and each is its own channel). The
messages were published *before* the
subscription opened, and sit in the
cache — use chapter 5's `poll` and
`since`. The message was published
with a delay that has not yet passed
(chapter 6). Or the client is
buffering: `curl` without `-N` holds
streamed lines back, and the
subscription looks dead while working
perfectly.

**Fix:** publish one message from a
second shell while the subscriber is
open, and watch both sides — the
publisher's receipt proves the server
has it; the cache poll proves where it
went.

## Symptom: yesterday's messages are gone

**Cause:** they expired. The cache
keeps messages 12 hours by default,
attachments 3; both numbers are
visible in any receipt's `expires`
field, and both are config settings
(`cache-duration`,
`attachment-expiry-duration`), not
malfunctions.

**Fix:** if a message must outlive
its notification, the subscriber keeps
it — chapter 9's log-file recipe.
Raising `cache-duration` makes the
server an archive it was not built to
be; do it knowingly, or not at all.

## Symptom: a long message arrived as a file

**Cause:** the request body crossed
the 4,096-byte boundary measured in
chapter 6, and the server — with an
attachment cache configured — filed
the body as an upload and made the
message a note about it.

**Fix:** send long content as an
attachment on purpose, with a short
message of your own writing; or carry
the text in a field (JSON, or the
`message` parameter) instead of the
bare body.

## Symptom: the server will not start, or the address does not answer

**Cause:** the mundane trio: another
process already holds the port; the
config file is not where `--config`
points (the startup log says what it
read); or the client is asking a
different address than the server is
listening on — `listen-http` is an
exact host:port, and 127.0.0.1 is not
reachable from other machines, ever,
by design.

**Fix:** read the first line of the
server's log (`Listening on …`),
confirm the health endpoint on the
*same* address, and only then debug
the network between.

## Symptom: the phone does not buzz

**Cause:** outside the lab's reach,
and this guide says so plainly: phone
delivery depends on the app, the
phone's battery and notification
settings, and — on iOS — Apple's push
infrastructure, none of which a local
server capture can settle. What *can*
be settled from a desk: the message
reached the server (the publisher's
receipt) and reached a desktop
subscriber (chapter 4) — if both are
true, the loss is on the phone's side
of the pipe.

**Fix:** check the app's subscription
is to the same server and topic; check
the topic's messages in the web app;
then the phone's per-app notification
and battery settings. The upstream
documentation's notes on instant
delivery are the reference here —
this symptom is listed as
documented-only in `criteria.md`.
