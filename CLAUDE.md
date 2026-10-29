# CLAUDE.md

## Project Overview

DnbCal is a tiny macOS app (Swift, no Xcode project, SPM only) that writes Apple Calendar
events for a date range to a file. It is an *app bundle* on purpose: macOS asks for Calendar
access per app, so a plain CLI run by Hammerspoon/SketchyBar/launchd could never hold it.

## Build & Test

```bash
swift build && swift test         # the output format is unit-tested
scripts/build-app.sh [version]    # build/DnbCal.app, ad-hoc signed
```

## Conventions

- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`, `chore(deps):`); release-please reads them for the version bump and `CHANGELOG.md`.
- **Branches & PRs**: branch, PR, squash-merge. release-please's own bump PRs auto-merge on patch only.
- Output format is a contract with consumers (the dotfiles' `calendar.lua` parses it): change it only with a major version.

## Non-obvious pitfalls

- The calendar access prompt can't be tested in CI; the code path that asks for it (`Sources/DnbCal/main.swift`) is deliberately tiny, the formatting lives in `Render.swift`, which is unit-tested.
- `open -W` can't reliably wait for this app (it exits in milliseconds); consumers poll for the output file, which is written atomically.
- **Release flow**: tag push → `release.yml` builds, ad-hoc signs, zips, attaches to the release release-please created, then bumps `Casks/dnb-cal.rb` in `drumandbytes/homebrew-tap` as `dnb-robot`. The cask must already exist in the tap.
