# Running Your Own Server

**Scope:** what the server needs and
keeps — the config file, its three
state files, its address settings —
and the honest boundary between what
this guide ran and what a public
deployment adds.

The public server at `ntfy.sh` is
free, generous, and someone else's
computer. Your own server is the same
binary you have been using as a client,
started with `serve` and a config
file. The lab is one; this chapter is
about what the lab's setup means, line
by line, and what changes when a
server leaves the loopback and faces
a network.

## The config file

ntfy's server is configured by one
YAML file. The lab's, from `examples/`:

```
base-url: "http://127.0.0.1:8099"
listen-http: "127.0.0.1:8099"
cache-file: "ntfy-data/cache.db"
attachment-cache-dir: "ntfy-data/attachments"
auth-file: "ntfy-data/auth.db"
auth-default-access: "read-write"
```

- **`listen-http`** — the address and
  port to listen on. The lab's
  `127.0.0.1:8099` means *this machine
  only, port 8099* — the property that
  makes the lab safe to leave open.
  Facing a network it becomes something
  like `:80` (all interfaces) or a
  specific LAN address.
- **`base-url`** — the address the
  server believes it lives at, used to
  build the links it hands out. You
  saw it in chapter 6: the attachment's
  `url` began with this value. On a
  real deployment it is the public
  address; a wrong `base-url` produces
  messages that arrive fine and links
  that go nowhere.
- **`cache-file`** — where messages
  are kept for chapter 5's twelve
  hours. A SQLite database. Without it
  the cache is memory-only and a
  restart forgets everything.
- **`attachment-cache-dir`** — where
  uploaded files sit out their three
  hours (chapter 6).
- **`auth-file`** — the user database
  of chapter 8. Without it there are
  no users and no access control, only
  the default below.
- **`auth-default-access`** — what a
  request with no matching grant may
  do: `read-write`, `read-only`,
  `write-only`, `deny-all`. Chapter 8
  is the story of this one line.

The distribution's own `server.yml`
template lists every setting with its
default, heavily commented; the ones
above are the load-bearing six for a
small server. Everything else — rate
limits, visitor quotas, email and
call plumbing — has defaults aimed at
ntfy.sh's scale and can stay untouched
on a household server. (The email and
phone-call settings need outside
services — an SMTP server, a Twilio
account — and are documented-only in
this guide; see `criteria.md`.)

Check: the server tells you, on a
timer, that it is alive and what it
holds. Its log carries periodic lines
like this one, from the lab:

```
2026/10/21 19:27:51 INFO Server stats (… messages_cached=15, messages_published=15, subscribers=0, … topics_active=1, …)
```

(trimmed to the interesting fields.)
And the health endpoint from chapter 1
is the external form of the same
question — the one a monitoring script
asks.

## Facing a network

Three things change, and only the
first is a config line:

1. **The listen address**, above —
   and with it, the guarantee of the
   lab is gone. Anything that can reach
   the port can try to use the server.
2. **Encryption.** The lab speaks
   plain HTTP on loopback, where no one
   else can listen. On a network, use
   the server's own HTTPS settings
   (`listen-https` with a certificate)
   or put it behind a reverse proxy
   that terminates TLS. Credentials
   (chapter 8) and message contents
   both deserve the tunnel; publishing
   from scripts then uses the `https`
   address.
3. **Access control stops being
   optional.** An open `read-write`
   server on a network is a free
   notification service for whoever
   finds it — they can publish to your
   topics (spam on your phone) and read
   them (your messages). The public
   ntfy.sh lives with this by design
   and leans on unguessable topic
   names; a private server should
   instead do what chapter 8 does:
   `deny-all` and grants.

Keeping the server running is the
ordinary machinery of your platform:
the release archive ships a systemd
unit (`ntfy.service`) for Linux, and
the upstream documentation covers
installing it. This guide ran the
server in a terminal, in the
foreground, on purpose — in the lab
you *watch* it — and lists service
installation as documented-only in
`criteria.md` rather than pretend the
lab proved it. Upgrading is replacing
the binary and restarting; the state
files carry over, which is why they
live outside the program, in paths the
config names.
