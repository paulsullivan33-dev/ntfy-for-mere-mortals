# Writing Criteria

Every guide in this repo is written to the same
standard. If you're adding or editing a guide —
human or AI — hold it to these.

1. **Plain words, real ideas.** Simple language,
   never dumbed-down concepts. Explain jargon on
   first use; collect terms in the glossary.
2. **No hype.** No marketing adjectives, no
   "revolutionary," no promises about what
   something will do for the reader.
3. **Honest about limits.** Say what the thing
   *can't* do. State uncertainty instead of
   smoothing it over. Validation notes include
   what remains unverified.
4. **No invented numbers.** Benchmarks, defaults,
   and specs are either measured or qualified with
   "depends on your setup." If it wasn't tested,
   say so.
5. **Checkable.** Commands are meant to be run,
   with "Check:" blocks showing what success looks
   like. Sources are linked, not asserted.
6. **Respect the reader's setup.** Call out
   Windows/Mac/Linux differences. Don't assume a
   GPU, a budget, or prior experience.
7. **Safety isn't skipped.** Real risks get
   stated plainly, not buried.
8. **Scoped.** Each guide says what it covers and
   points elsewhere for the rest. No guide
   pretends to be the whole subject.
9. **Structure over prose.** Tables, before/after
   examples, symptom → fix. Scannable beats essay.

## Verification notes for this guide

Standard 3 and 4 applied to this guide,
specifically. The tool is **ntfy 2.32.0**
— the official release archive for Linux
amd64 (the binary's own banner: `ntfy
2.32.0 (9d0b6d9), runtime go1.27.1`), one
binary acting as both client and server.
Every quoted output in the chapters is a
capture from that binary: a server run
locally on `127.0.0.1:8099` and clients
(`curl`, `jq`, and `ntfy` itself) talking
to it. Working transcripts are kept with
the build (`ntfy-lab/transcripts/`).

**The lab.** One server, configured by
the file in `examples/server.yml` (the
build copy differs only in using absolute
paths): loopback only, port 8099, state
in three files the config names — a
message cache, an attachment directory,
an auth database. Two phases, because
the guide teaches both: chapters 1–7 run
against an open server
(`auth-default-access: "read-write"`),
and chapter 8 creates two users, grants
them opposite rights on a `lab-private`
topic, flips the default to `deny-all`,
and restarts. The users (alice, bob) and
their passwords are invented fixtures for
a throwaway loopback server, printed in
the chapters because the captures need
them; they protect nothing.

**Verified by running, per chapter:**

- *Ch. 1:* `--version`; the server
  starting with the lab config (startup
  log line as printed); `/v1/health`
  answering `{"healthy":true,...}`; the
  web app root answering HTTP 200.
- *Ch. 2:* publishing with `curl` (POST,
  and PUT identically); publishing with
  the `ntfy` CLI, including `--title`,
  `--priority high`, `--tags`; the
  receipt fields read back (`id`,
  `time`, `expires` = time + 43,200,
  `event`, `topic`, `message`); JSON
  publishing to the server root with
  topic, title, message, priority, and
  tags fields, all reflected in the
  receipt.
- *Ch. 3:* the header form of title,
  priority, and tags; the priority
  scale's measured mappings (name `min`
  → 1, numeric 2 → 2, `high` → 4,
  numeric 5 → 5, and a plain message's
  receipt carrying no `priority` field);
  `X-Priority: 9` refused with HTTP 400,
  code 40007; `X-Markdown: true`
  returning `content_type:
  "text/markdown"`; `X-Click` returned
  as the `click` field; `X-Actions`
  parsed into a structured `actions`
  array.
- *Ch. 4:* a live CLI subscription
  receiving a message published from a
  second shell; the held-open `/json`
  stream (the `open` event, then the
  message); the `/sse` stream in its
  `event:`/`data:` framing; the `/raw`
  stream delivering the bare message
  text; `ntfy subscribe` running a
  command per message, with `$title`,
  `$message`, and `$priority` populated
  in its environment.
- *Ch. 5:* polling the cache
  (`?poll=1` returned all 12 messages
  published so far); `since=1m`
  returning the last minute's 5;
  `since=<message id>` returning
  nothing when the ID was the newest
  message — the strictly-after
  semantics, captured, not assumed;
  `ntfy subscribe --poll` printing a
  topic's cache and exiting 0.
- *Ch. 6:* delayed delivery both ways —
  a 12-second delay accepted with a
  `time` 12 seconds in the future,
  absent from a poll taken immediately,
  present after the delay passed — and
  a 2-second delay refused with HTTP
  400, code 40005 ("too small"); a 67-byte
  file uploaded with `X-Filename` and
  `X-Message`, its `attachment` object
  read back, the file downloaded from
  the handed-out URL and compared
  byte-identical; the attachment expiry
  measured at exactly 3 hours against
  the message's 12; and the body-size
  boundary measured by bisection — a
  4,095-byte body a message, a
  4,096-byte body a file — plus a
  65,536-character message carried by
  the `message` parameter arriving
  whole.
- *Ch. 7:* the config file itself is
  the lab's, run as printed; the
  server's periodic `Server stats` log
  line captured from the lab's log
  (shown trimmed to the interesting
  fields, declared in the chapter).
- *Ch. 8:* `ntfy user add` for both
  users (passwords via `NTFY_PASSWORD`),
  `user list` including the `*`
  anonymous entry and its server-config
  default; `ntfy access` granting
  read-write and read-only and
  reporting the grants; and after the
  `deny-all` restart, the full matrix —
  anonymous publish refused 403 (code
  40301), alice publishing 200, alice
  with a wrong password refused 401
  (code 40101), bob publishing refused
  403, bob polling successfully and
  receiving alice's message; CLI
  authentication with `--user`,
  exercised in chapters 4 and 5.

**Defaults quoted from the release's own
commented `server.yml` template** and
cross-checked against captures wherever
a capture could reach them: cache
duration 12h (measured in every
receipt), attachment expiry 3h
(measured), `message-size-limit` `4k`
(measured at the 4095/4096 boundary),
attachment limits 15M per file / 5G
total (template only; the lab's files
were bytes, deliberately), delay limit
`3d` (template; the lab's delays were
seconds).

**Capture hygiene (declared trims):**
the two stream captures in chapter 4
were produced by two shells — a held-open
subscription and a publish — and are
shown interleaved in one block, as the
chapter text states; the chapter 5 poll
of the full cache is shown with `head`
and its length proven by the counted
capture beside it, and two further
listings carry bracketed trim notes
with their true counts; the chapter 8
listing quotes the build machine's
config path in the export line, as run.
Two mid-task corrections, for the
record: the first delayed-delivery
capture was defeated by `curl`'s output
buffering and proved nothing, and the
second attempt polled with a `since`
that excluded the message by design —
the quoted capture is a third,
poll-based one that proves both the
absence before and the presence after;
and an early oversized-*message* test
turned out to be measuring the
body-becomes-file rule instead, which
is how chapter 6's boundary got measured
properly. Nothing in the chapters rests
on the discarded attempts.

**Build-machine weather, stated once:**
the build filesystem is an overlay that
refuses ownership changes, so the
release archive was extracted with
`tar --no-same-owner`; message `time`
values in captures are Unix timestamps
from the server (the lab machine's
clock), shown as captured. The lab
server was stopped when the build
finished; its data files were build
state, not deliverables.

**Documented-only (not run), and why:**

- *The Android and iOS apps:* install,
  background delivery, per-priority
  sounds and banners, and iOS delivery
  via Apple's push service / Firebase
  (FCM) on Android — none of it can be
  exercised from this build machine,
  and no phone behaviour is quoted
  anywhere in the guide. What the apps
  receive is described only down to the
  server's side of the wire, which was
  captured.
- *The web app's interface:* the server
  serving it (HTTP 200 at the root) is
  captured; clicking through its UI is
  not a terminal capture and is
  described, not quoted.
- *`X-Attach` (server-fetched
  attachments), `X-Email`, and
  `X-Call`:* named where they belong.
  The first needs an outside file
  server to fetch from; the other two
  need an SMTP server and a Twilio
  account. None exists in the lab.
- *Access tokens (`ntfy token`):* the
  command exists in the captured
  `--help` listing and is recommended
  over passwords for scripts in
  chapter 8's prose; token creation
  itself was not run.
- *Natural-language delays*
  (`tomorrow, 10am`) *and timestamp
  delays:* the duration form is the one
  measured; the other spellings are
  attributed to the documentation.
- *Running as a system service and
  behind a reverse proxy:* the release
  archive ships a systemd unit (seen in
  its file listing) and the upstream
  documentation covers both; the lab
  ran the server in a foreground
  terminal on purpose, so readers watch
  the same process the chapters talk
  to. HTTPS settings are described the
  same way.
- *The public server's own limits:*
  ntfy.sh imposes rate and size limits
  of its own, set by its operator and
  changeable by them; the guide
  measures only the lab and points at
  the service's documentation for its
  current numbers.
- *Windows and macOS builds:* the
  project publishes them and the CLI
  surface is the same program; every
  capture here is the Linux build, and
  no cross-platform behaviour is
  claimed beyond the publishing model,
  which is HTTP and identical by
  construction.
- *The neighbours (chapter 10):*
  Gotify, Pushover, Apprise, and email
  are described from their
  documentation for comparison, as the
  chapter states; none was installed.

Specimen discipline, for the record:
every name, user, and password in the
guide is invented; the only addresses
are loopback and `example.org`; the lab
listened on 127.0.0.1 throughout, so no
capture in this guide ever left the
build machine; and the two lab
passwords are printed deliberately, as
fixtures for a server that no longer
exists — they must not be used anywhere
else, and chapter 8 says so where they
appear.
