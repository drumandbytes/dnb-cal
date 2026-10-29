# dnb-cal

A tiny macOS app that writes your Apple Calendar events for a date range to a file.
It exists for scripts and helpers that can't ask for Calendar access themselves
(Hammerspoon, SketchyBar, launchd jobs, cron): macOS gives Calendar access to *apps*,
and asks for it under the app's own name, so DnbCal is an app.

```sh
brew install --cask drumandbytes/tap/dnb-cal
```

## Use

```sh
open -g -n -a DnbCal --args 2026-10-29 2026-11-12 /tmp/events.tsv
```

The arguments are the first day, the last day (both included) and the output file.
The first run asks for Calendar access for **DnbCal** (System Settings → Privacy &
Security → Calendars). The output file is written in one step (temp file + rename), so
it either doesn't exist yet or is complete. `open -W` can't reliably wait for an app
that exits this quickly, so wait for the file instead.

One line per event, ordered by start, tab-separated:

```text
2026-10-29	-	Rent due
2026-10-29	10:00	Standup
```

The date, the start time (`HH:mm`, or `-` for an all-day event) and the title.
Recurring events are expanded. If access is refused the file contains just `DENIED`.

## From Hammerspoon

```lua
os.remove(out)
hs.task.new("/usr/bin/open", nil, { "-g", "-n", "-a", "DnbCal", "--args", "2026-10-29", "2026-11-12", out }):start()
-- poll for `out`, read it, split lines on tabs
```

## Why an app

A command-line tool run by Hammerspoon (or SketchyBar, launchd, …) counts as that
program for macOS's privacy checks, so it needs *that* program to hold the permission,
and Hammerspoon can't be given Calendar access (it doesn't declare a calendar usage
description, so it never appears in the list). Started through `open`, DnbCal is its own
app: it asks for access once under its own name and keeps it. Under the hood it's
EventKit (`requestFullAccessToEvents`) and about 30 lines of code.

## A note on signing

Ad-hoc signed, not notarized (a paid Apple Developer Program membership is the only
way to change that). A Homebrew cask install goes through the normal one-time
Gatekeeper approval, and because the signature changes with every release, macOS may ask
for Calendar access again after an upgrade.

## Build

```sh
swift build && swift test
scripts/build-app.sh [version]   # build/DnbCal.app, ad-hoc signed
```

Requires macOS 13+ (full-access Calendar permission on macOS 14+), Apple Silicon.
