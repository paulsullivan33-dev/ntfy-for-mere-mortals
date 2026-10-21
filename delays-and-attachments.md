# Delays and Attachments

**Scope:** publishing for later
(`X-Delay`), publishing with a file
attached, and the size limits that
decide what counts as a message and
what counts as a file.

## Deliver later

The `X-Delay` header asks the server to
hold a message and deliver it at a
future time — a reminder planted now
and fired later, without anyone running
a timer. Check: the receipt's `time`
is the *delivery* time, in the future,
and until it passes the message is
nowhere a subscriber can see:

```
$ curl -s -H "X-Delay: 12s" -d "Second delayed message" http://127.0.0.1:8099/lab-alerts   (sent at epoch 1792610866)
{"id":"ZQAgsk5bPBPc","time":1792610878,"expires":1792654078,"event":"message","topic":"lab-alerts","message":"Second delayed message"}
$ curl -s "http://127.0.0.1:8099/lab-alerts/json?poll=1&since=30s" | grep -c ZQAgsk5bPBPc   (immediately after)
0
[accepted with a timestamp 12 s in the future, but not yet visible to subscribers]
$ sleep 15; curl -s "http://127.0.0.1:8099/lab-alerts/json?poll=1&since=1m" | grep ZQAgsk5bPBPc   (after the delay)
{"id":"ZQAgsk5bPBPc","time":1792610878,"expires":1792654078,"event":"message","topic":"lab-alerts","message":"Second delayed message"}
```

Delays have a floor and a ceiling,
both the server's. Too small is
refused outright — the lab's capture
of a 2-second delay:

```
$ curl -s -w "\nHTTP %{http_code}\n" -H "X-Delay: 2s" -d "Too soon" http://127.0.0.1:8099/lab-alerts
{"code":40005,"http":400,"error":"invalid delay parameter: too small, please refer to the docs","link":"https://ntfy.sh/docs/publish/#scheduled-delivery"}

HTTP 400
```

The documented range is 10 seconds to
3 days (the shipped config's
`message-delay-limit` is `3d`). Times
can also be written as a Unix timestamp
or in words — `tomorrow, 10am` is a
valid delay to the server — those
spellings are documented rather than
captured here; the duration form above
is the one the lab measured. One honest
consequence of the design: a delayed
message lives in the server until its
time comes, so the server has to still
be running, with its cache intact,
when the moment arrives.

## Attach a file

A message can carry one file. Upload it
*as* the request, with the PUT form of
publishing, its name in `X-Filename`,
and the message text in `X-Message`:

```
$ printf "Weekly report..." > report.txt; wc -c report.txt
67 report.txt
$ curl -s -T report.txt -H "X-Filename: report.txt" -H "X-Message: The weekly report is attached" http://127.0.0.1:8099/lab-alerts
{"id":"z2qMRPB7pgFB","time":1792610913,"expires":1792654113,"event":"message","topic":"lab-alerts","message":"The weekly report is attached","attachment":{"name":"report.txt","type":"text/plain; charset=utf-8","size":67,"expires":1792621713,"url":"http://127.0.0.1:8099/file/z2qMRPB7pgFB.txt"}}
```

The receipt grows an `attachment`
object: the file's `name`, `type`, and
`size`, the address it can be fetched
from (`url`) — and its own, shorter
`expires`. The arithmetic is measurable
in the capture: the attachment's expiry
is 3 hours after publishing, against the
message's 12. Files are guests, not
residents; the defaults in the shipped
config are a 15 MB limit per file, 5 GB
across the whole server, and that 3-hour
lifetime. Fetching the address handed
back the file exactly:

```
$ curl -s http://127.0.0.1:8099/file/z2qMRPB7pgFB.txt
Weekly report
==============
Backups: ok
Builds: 1 failed, see log
$ cmp report.txt downloaded.txt && echo IDENTICAL
IDENTICAL
```

(The other upload route — `X-Attach`
with an address, asking the server to
fetch the file itself — is documented
but was not exercised in the lab; it is
listed in `criteria.md`.)

## Where a message stops being a message

One limit surprises everyone once, so
the lab measured it exactly. A message
sent as the request *body* is a message
only up to a boundary — the shipped
config's `message-size-limit` of `4k`.
Below it, the body is the message; at
it, with an attachment cache configured,
the body is filed as an upload instead,
and the "message" becomes a note that a
file arrived:

```
$ wc -c body-4095.txt body-4096.txt
4095 body-4095.txt
4096 body-4096.txt
8191 total
$ curl -s -d @body-4095.txt http://127.0.0.1:8099/lab-alerts | jq -c "{event, message_length: (.message | length), has_attachment: has(\"attachment\")}"
{"event":"message","message_length":4095,"has_attachment":false}
$ curl -s -d @body-4096.txt http://127.0.0.1:8099/lab-alerts
{"id":"KL0lLBdPhorY","time":1792611040,"expires":1792654240,"event":"message","topic":"lab-alerts","message":"You received a file: attachment.txt","attachment":{"name":"attachment.txt","type":"text/plain; charset=utf-8","size":4096,"expires":1792621840,"url":"http://127.0.0.1:8099/file/KL0lLBdPhorY.txt"}}
```

4,095 bytes: a message. 4,096 bytes: a
file. Nothing failed in either case —
but a script that POSTs its log tail as
the body will, past that line, notify
you about a *file* instead of telling
you the news. Long output belongs in an
attachment on purpose (the first part
of this chapter), with a short message
saying what it is.

The boundary is about the *body*, not
about messages themselves: a message
carried in a field — the JSON form, or
the `message` query parameter — is not
measured by the same ruler. The lab
published one of 65,536 characters that
way and it arrived whole:

```
$ curl -s -d "" "http://127.0.0.1:8099/lab-alerts?message=<a 65536-character message>" | jq -c "{event, message_length: (.message | length), has_attachment: has(\"attachment\")}"
{"event":"message","message_length":65536,"has_attachment":false}
```

That is a lab measurement, not advice —
a 65 KB "notification" is a document, and
the public server imposes limits of its
own. It stands in the guide so the
4,096 line is understood for what it
is: the boundary between the two ways
of carrying content, not a cap on
thought.
