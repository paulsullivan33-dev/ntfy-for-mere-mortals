# Users and Access

**Scope:** locking the server down —
users, per-topic grants, the default
for everyone else — and the four
answers a locked server gives.

Until now the lab has been open: the
config's `auth-default-access:
"read-write"` lets anyone who can
reach it publish and subscribe. On
loopback, "anyone" is you. This
chapter builds the locked version:
named users, each allowed specific
things on specific topics, and
everyone else refused.

The cast is from `lab-notes.txt`:
**alice**, who may read and write the
`lab-private` topic, and **bob**, who
may only read it. Their passwords
(`alice-lab-pass`, `bob-lab-pass`) are
invented fixtures for a throwaway lab
server, printed here because the
captures need them. They protect
nothing. Real passwords for a real
server are made the same way but kept
like passwords.

## Making users

The `user` and `access` commands are
*server* commands: they edit the auth
database file directly, on the server
machine, and they find that file
through the server's config. In this
version of ntfy that pointer is set
with the `NTFY_CONFIG_FILE` environment
variable (or the `--config` flag those
commands carry) — there is no global
`--config`, and a first attempt without
the pointer fails on exactly that. One
export, then the commands work:

```
$ export NTFY_CONFIG_FILE=/home/hatch/workspace/ntfy-build/server.yml   (so the user/access commands find the lab auth database)
$ NTFY_PASSWORD=alice-lab-pass ntfy user add alice
user alice added with role user
$ NTFY_PASSWORD=bob-lab-pass ntfy user add bob
user bob added with role user
$ ntfy user list
user alice (role: user, tier: none)
- no topic-specific permissions
user bob (role: user, tier: none)
- no topic-specific permissions
user * (role: anonymous, tier: none)
- no topic-specific permissions
- read-write access to all (other) topics (server config)
```

(`NTFY_PASSWORD` keeps the password out
of the interactive prompt, which is
what makes the command scriptable; it
also puts it in your shell history —
another reason lab passwords are lab
passwords.) Three things to read in
the listing. A fresh user has *no*
permissions of their own. The `*` user
is "everyone else" — the anonymous
visitor — and its line "(server
config)" is the `auth-default-access`
setting, about to change. And a user's
**role** can be `admin`, which
overrides everything (an admin reads
and writes all topics); alice and bob
are ordinary `user`s, governed by
grants:

```
$ ntfy access alice lab-private read-write
granted read-write access to topic lab-private

user alice (role: user, tier: none)
- read-write access to topic lab-private
$ ntfy access bob lab-private read-only
granted read-only access to topic lab-private

user bob (role: user, tier: none)
- read-only access to topic lab-private
```

Grants are per topic, and the topic
patterns can be broader (`alerts-*`)
or the whole server — but notice the
order of operations: grants were made
while the server was still open, and
they already existed when it locked.
Making them costs nothing in either
state; the database is the same file
the running server reads.

## Locking the door

Now the one-line change: in
`server.yml`, `auth-default-access`
becomes `"deny-all"`, and the server
restarts. The grants stay; the welcome
mat goes. Check: the four answers a
locked server gives, each captured:

Anonymous — no credentials, no grant.
Forbidden:

```
$ curl -s -w "\nHTTP %{http_code}\n" -d "Anyone there?" http://127.0.0.1:8099/lab-alerts
{"code":40301,"http":403,"error":"forbidden","link":"https://ntfy.sh/docs/publish/#authentication"}

HTTP 403
```

Alice, with her grant, publishes to
`lab-private` as before — credentials
ride along as ordinary HTTP basic
auth (`-u user:password`):

```
$ curl -s -w "\nHTTP %{http_code}\n" -u alice:alice-lab-pass -d "Private backup finished" http://127.0.0.1:8099/lab-private
{"id":"8m7OCDtUaLod","time":1792611170,"expires":1792654370,"event":"message","topic":"lab-private","message":"Private backup finished"}

HTTP 200
```

Alice with a *wrong* password is a
different answer — not forbidden, but
unauthorized. The distinction is
diagnostic gold: **401 means "I don't
believe you are alice"; 403 means "I
believe you, and no":**

```
$ curl -s -w "\nHTTP %{http_code}\n" -u alice:wrong-password -d "Private backup finished" http://127.0.0.1:8099/lab-private
{"code":40101,"http":401,"error":"unauthorized","link":"https://ntfy.sh/docs/publish/#authentication"}

HTTP 401
```

Bob, read-only, tries to publish and
gets the 403 his grant promises:

```
$ curl -s -w "\nHTTP %{http_code}\n" -u bob:bob-lab-pass -d "Bob trying to publish" http://127.0.0.1:8099/lab-private
{"code":40301,"http":403,"error":"forbidden","link":"https://ntfy.sh/docs/publish/#authentication"}

HTTP 403
```

And bob doing exactly what he *is*
allowed — reading the topic — works,
and shows him alice's message:

```
$ curl -s -u bob:bob-lab-pass "http://127.0.0.1:8099/lab-private/json?poll=1"
{"id":"8m7OCDtUaLod","time":1792611170,"expires":1792654370,"event":"message","topic":"lab-private","message":"Private backup finished"}
```

## What this buys, and what it doesn't

Buys: a server a stranger can find but
not use; topics whose contents are
read only by the people granted;
scripts that authenticate (the `ntfy`
client takes the same credentials as
`--user`, and upstream also issues
per-user **access tokens** — the
`ntfy token` command — so scripts need
not carry the account password; tokens
are named here as documented, the lab
used basic auth).

Doesn't buy: secrecy on the wire. Basic
auth over plain HTTP is a password in
a trench coat — readable by anyone on
the path. On loopback there is no
path; on a network, chapter 7's HTTPS
is what makes chapter 8's locks worth
turning. And on the *public* server
there are no locks of yours to turn:
anyone who knows or guesses your topic
name can read and publish it, which is
why public-server topics get long,
unguessable names — the name itself is
the password there.
