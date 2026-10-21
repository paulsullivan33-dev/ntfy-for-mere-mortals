# The Neighbours

**Scope:** the honest map of what else
does this job, and when each is the
better pick. ntfy was run throughout
the guide; everything in this chapter
is described, not run, and is labelled
that way — descriptions of the
neighbours come from their own
documentation, and none of them was
installed in the lab.

**Gotify** — the closest relative: a
small self-hosted server with its own
web UI, its own phone app, and an
API of applications and clients rather
than open topics. The shape differs in
one honest way: Gotify's model is
*your* server for *your* devices, and
every sender is a registered
application with a token, where ntfy's
model is topics anyone can use until
locked. Pick Gotify if the registered-
sender model suits you and you never
wanted a public server; pick ntfy if
the "one curl, no enrolment" start is
the point.

**Pushover** — the hosted veteran.
A commercial service: a paid app, a
generous monthly message allowance,
delivery over the vendors' own push
channels, and an email address you can
send to that becomes a notification.
No server to run at all. Pick it if
running a server — yours or trusting
ntfy.sh — is the part you want to not
do, and a per-device app fee is fair
for that.

**Apprise** — not a service but a
translator: a library and command-line
tool that takes one message and
delivers it to dozens of endpoints —
ntfy among them, plus email, chat
services, and the other tools here.
Pick it when the destination is the
variable: a script that should reach
"whatever I'm using this year" sends
once, to Apprise, and the URL decides
the rest. It composes with ntfy rather
than competing with it.

**Email, and its gateway cousins** —
the neighbour that was already there.
An SMTP server will deliver your
backup's confession to every device
you own, with attachments, archives,
and search, for no new software.
What it will not do is *insist*: email
arrives when the mail app feels like
fetching, sorted into a pile. ntfy
itself can forward a message as email
(the `X-Email` header) — a documented
feature needing an SMTP server behind
the ntfy server, listed as
documented-only in `criteria.md`.
Pick email when "eventually, and kept"
beats "now."

The line through all four: every one
of these will move a short message
from a computer to a person. They
differ in who runs the pipe, what a
sender must enrol as, and whether the
pipe can knock loudly. ntfy's answers
— a pipe you can host in an afternoon,
senders that are one HTTP request, and
a priority field that reaches the
phone's idea of loud — are the ones
this guide measured.
