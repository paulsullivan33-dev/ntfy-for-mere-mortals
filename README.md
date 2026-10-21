# ntfy for Mere Mortals

A plain-language guide to **ntfy**, the
small service that carries a message
from a program — a backup that finished,
a build that passed, a sensor that
tripped — to the person who should hear
about it. Publishing is one HTTP
request; subscribing is one held open.
This guide runs both against a local lab
server until they are ordinary, then
puts a lock on the server's door.

Everything here was tested against a
real lab server (`ntfy 2.32.0`, run
locally), publishing and subscribing for
real, with users refused for real. The
phone apps and anything needing an
outside service (email plumbing, phone
calls, Apple's and Google's push
infrastructure) are described from the
documentation and marked as such —
`criteria.md` lists exactly what was
run and what was only documented.

## What this guide covers

- [What ntfy Is](what-ntfy-is.md) — the
  model: a server, a topic, a message;
  the public server and your own; the
  lab.
- [Publishing](publishing.md) — one
  POST with `curl`, the `ntfy` command,
  and the JSON form; reading the
  receipt.
- [Message Anatomy](message-anatomy.md)
  — titles, the five priorities, tags,
  Markdown, click targets, and action
  buttons.
- [Subscribing](subscribing.md) — the
  CLI held open, the `json`/`sse`/`raw`
  streams, and subscriptions that run a
  command per message.
- [Catching Up](catching-up.md) — the
  12-hour cache, polling instead of
  holding open, and `since` in its
  duration and message-ID forms.
- [Delays and Attachments](delays-and-attachments.md)
  — scheduled delivery, one file per
  message, and the measured line where
  a body stops being a message and
  becomes a file.
- [Running Your Own Server](running-your-own-server.md)
  — the config file line by line, the
  three state files, and what changes
  when a server faces a network.
- [Users and Access](users-and-access.md)
  — users, per-topic grants,
  `deny-all`, and the honest difference
  between a 401 and a 403.
- [Recipes](recipes.md) — notify me
  when this finishes, sensors that
  speak, reminders planted on the
  server, a topic as a log.
- [The Neighbours](the-neighbours.md)
  — Gotify, Pushover, Apprise, and
  email: what else does this job, and
  when each is the better pick.
- [Troubleshooting](troubleshooting.md)
  — 403s and 401s, silent subscribers,
  expired messages, and the
  user-command config trap.
- [Glossary](glossary.md) — every term,
  defined once.

## What it doesn't cover

- The Android and iOS apps beyond how
  they subscribe: their background
  delivery, per-priority sounds, and
  battery behaviour belong to the
  phone and are documented-only here.
- Firebase/FCM and Apple push delivery
  — the machinery behind instant phone
  delivery on the public service.
- Sending email (`X-Email`) or placing
  phone calls (`X-Call`) from a
  message: both need outside accounts
  (SMTP, Twilio) the lab does not have.
- Running the server as a system
  service or behind a reverse proxy in
  production; the guide runs it in a
  terminal and says what a deployment
  adds.
- ntfy as a *record*: the cache forgets
  on purpose. Archives live at the
  subscriber (see the recipes chapter).

## How to use this guide

Start the lab — `examples/` has the
config and `lab-server.sh` — then read
from chapter 1. Each chapter's
**Check:** paragraphs are the point:
they show what success looks like when
you run the command yourself, and the
captures are the lab's real answers,
with any trim declared next to them.
`examples/commands.txt` is the
cheat-sheet; `ntfy-lab/transcripts/`
keeps the captures the chapters quote
from.
