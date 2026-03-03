# Caffeinate UI

A native macOS menu bar app that provides a GUI for the [`caffeinate`](https://ss64.com/mac/caffeinate.html) command.

![Screenshot](screenshot.png)

## Why?

macOS ships with `caffeinate` — a handy command that prevents your Mac from sleeping — but it's buried in the terminal. There's no built-in way to toggle it from the menu bar, see which flags are active, or know how much time is left on a timeout. You either leave a terminal window open or forget it's running entirely.

Caffeinate UI puts all of that in a single menu bar popover: pick your flags, set a timeout, and watch the cup drain as it counts down. No terminal needed.

## Features

- **Toggle flags** — Enable/disable caffeinate flags individually:
  - `-d` Prevent display sleep
  - `-i` Prevent idle sleep
  - `-s` Prevent system sleep
  - `-u` Declare user active
- **Enable All** — Master toggle to enable/disable all flags at once
- **Persistent state** — Toggles and timeout settings are remembered across app launches
- **Launch at Login** — Option to start the app automatically at login via SMAppService
- **Timeout picker** — Preset durations (15m, 30m, 1h, 2h, 8h, 12h), custom h:m:s input, scheduled date/time, or indefinite
- **Live countdown** — Shows remaining time next to the timeout picker
- **Command display** — Shows the exact `caffeinate` command being run (including the hidden 8-hour cap for `-u` + indefinite)
- **Draining cup icon** — Menu bar icon fills when active and drains from bottom-up as the timeout counts down
- **Reactive icon** — Menu bar icon changes from outline (`cup.and.heat.waves`) to filled when active
- **Single instance** — Only one instance can run at a time (POSIX file lock)
- **Clean startup** — Kills any stale caffeinate processes from previous sessions
- **Graceful cleanup** — Terminates caffeinate when the app quits

## Install

Download the latest DMG from the [Releases](https://github.com/Gyakusetsu/caffeinate-ui/releases) page, open it, and drag **Caffeinate UI** to Applications.

## Requirements

- macOS 14+ (Sonoma)
- Swift 5.10+ (for building from source)

## Build & Run

**Development:**

```sh
swift build && swift run CaffeinateUI
```

**Test:**

```sh
swift test
```

**Release + install locally:**

```sh
./build.sh
```

Builds a release `.app` bundle with `LSUIElement = true` (no Dock icon) and installs it to `/Applications/Caffeinate UI.app`.

## Architecture

Built with SwiftUI and SPM — no Xcode project needed.

```
Sources/
├── CaffeinateUI/                       # CaffeinateCore library target
│   ├── CaffeinateUIApp.swift           # App struct, MenuBarExtra scene
│   ├── Models/
│   │   ├── CaffeinateFlag.swift        # Enum: -d, -i, -s, -u
│   │   └── TimeoutOption.swift         # Enum: presets + custom + scheduled + indefinite
│   ├── Services/
│   │   ├── CaffeinateService.swift     # Protocol + impl: spawns/kills caffeinate
│   │   └── UserDefaultsProtocol.swift  # Protocol for testable UserDefaults access
│   ├── ViewModels/
│   │   └── CaffeinateViewModel.swift   # @Observable state management
│   └── Views/
│       ├── CaffeinatePanel.swift       # Root popover view
│       ├── FlagToggleRow.swift         # Toggle row with label + description
│       ├── MenuBarIcon.swift          # Icon + circular progress ring overlay
│       ├── TimeoutPicker.swift         # Duration picker with h:m:s fields
│       └── TimerDisplay.swift          # Countdown display + formatDuration()
└── CaffeinateUIMain/
    └── main.swift                      # Thin executable entry point

Tests/CaffeinateUITests/
├── CaffeinateFlagTests.swift
├── CaffeinateViewModelTests.swift
├── PersistenceTests.swift
├── TestHelpers.swift
├── TimeFormattingTests.swift
└── TimeoutOptionTests.swift
```

## Made by

Reymar & Claude
