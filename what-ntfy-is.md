# What ntfy Is

**Scope:** the mental model — a server, a
topic, a message — plus the public server
and your own, your version, and the lab.

## A postbox with a very long arm

**ntfy** (pronounced "notify") is a small
service with one job: something on a
computer has something to say — a backup
finished, a build passed, a door opened —
and a human somewhere else should hear
about it promptly, on the phone in their
pocket. ntfy is the pipe between those two
moments, and it is deliberately a very
simple pipe.

The whole model fits in three words:

- A **server** receives and forwards
  messages. You can use the public one at
  `ntfy.sh`, run by the project's author,
  or run your own — chapter 7 is about
  that, and this guide's lab is a private
  one.
- A **topic** is a named channel on a
  server: `backups`, `builds`,
  `front-door`. A topic is created by
  being used; there is nothing to set up
  in advance. Anyone may publish to a
  topic or subscribe to it, unless the
  server's owner has locked it down —
  chapter 8.
- A **message** is a short text, with an
  optional title, a priority, and tags,
  published to a topic. Every subscriber
  of that topic receives it.

Publishing and subscribing are both plain
**HTTP**. Publishing is a POST with the
message as the body. Subscribing is a GET
that the server holds open, writing each
new message as it arrives. That is the
entire trick, and it is why everything
that can speak HTTP — `curl`, a shell
script, a backup tool, a microcontroller —
can publish with no library and no SDK,
and why the chapters in this guide need
nothing more exotic than `curl` and the
`ntfy` command-line tool to show real
traffic.

Check: the tool, on the build machine.
One binary is both the client and the
server — the same program you publish
with is the one that serves:

```
$ ntfy --version
ntfy version 2.32.0
```

This guide's ntfy is version **2.32.0**,
the official Linux amd64 build from the
project's releases. The project publishes
builds for other systems too; the
chapters are the Linux one, and they say
so where another system's behaviour
would differ.

## The lab

Everything in this guide happens against
a local lab server, so that no experiment
can spam a public service or a stranger.
It runs from this repo's `examples/`
folder and listens on this machine only:

```
$ ntfy serve --config server.yml
2026/10/21 19:32:22 INFO Listening on 127.0.0.1:8099[http], ntfy 2.32.0, log level is INFO (tag=startup)
```

Check: a healthy lab answers two
questions — is the server up, and does it
serve the web app your browser would use:

```
$ curl -s http://127.0.0.1:8099/v1/health
{"healthy":true,"role":"active"}
$ curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8099/
200
```

The lab's address throughout the guide
is `http://127.0.0.1:8099`, and its
working topic is `lab-alerts`. The
server's state — its message cache, its
uploaded files, its user database — lives
in files the config names; `lab-notes.txt`
in `examples/` describes the whole setup
and the cast. Build it before chapter 2
and leave it running: chapters restart it
exactly once, in chapter 8, when the open
lab becomes a locked one.

One last idea to carry through the
guide: because a topic on an open server
is usable by anyone who can reach it and
guess its name, **the topic name is the
only secret an open server has.** On the
loopback lab that costs nothing. On the
public server it is the whole of your
security, and chapter 8 returns to it.
