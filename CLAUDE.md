# Caffeinate UI

macOS menu bar app providing a GUI for the `caffeinate` command.

## Tech Stack
- Swift 5.10 + SwiftUI
- macOS 14+ (Sonoma)
- SPM only — no Xcode project

## Build & Run
- Dev: `swift build && swift run CaffeinateUI`
- Test: `swift test`
- Release + install: `./build.sh` (builds and copies to `/Applications`)

## Architecture
- **CaffeinateCore** (library target): all source code at `Sources/CaffeinateUI/`
- **CaffeinateUI** (executable target): thin wrapper at `Sources/CaffeinateUIMain/main.swift`
- **CaffeinateUITests** (test target): `Tests/CaffeinateUITests/`

### Layers
- **Models**: `CaffeinateFlag`, `TimeoutOption`, `SemanticVersion` — `Codable` value types for flags and durations; `TimeoutOption.scheduled` computes delta from a target date; `SemanticVersion` parses/compares version strings (e.g. `v1.2` → `1.2.0`)
- **Services**: `CaffeinateServiceProtocol` / `CaffeinateService` — spawns/kills `/usr/bin/caffeinate` Process; `UserDefaultsProtocol` for testable persistence; `UpdateCheckerServiceProtocol` / `UpdateCheckerService` — queries GitHub Releases API for latest version
- **ViewModels**: `CaffeinateViewModel` — `@Observable` state management, accepts `service`, `defaults`, and `updateChecker` via init; persists flags/timeout to UserDefaults; `launchAtLogin` via `SMAppService`; checks for updates on launch with 24h in-memory throttle
- **Views**: SwiftUI views using `MenuBarExtra` with `.window` style; includes "Enable All" master toggle, "Launch at Login" option, and `MenuBarIcon` with draining cup fill overlay
- **Resources**: `Info.plist`, `AppIcon.icns` (coffee cup icon generated from SF Symbol)

## Testing
- XCTest with `@testable import CaffeinateCore`
- `MockCaffeinateService`, `MockUserDefaults`, and `MockUpdateCheckerService` (test spies in `TestHelpers.swift`) — no real processes, UserDefaults, or network calls
- `PersistenceTests` verifies save/restore cycle, corrupted-data resilience, and that restored flags resume caffeinating on next launch
- `formatDuration(_:)` extracted as free function for independent testing
- Run: `swift test`

## Conventions
- `@Observable` (not `ObservableObject`) for state
- Kill-and-respawn pattern: changing flags/timeout kills existing process and spawns new one
- `LSUIElement = true` — no Dock icon
- Single-instance guard via POSIX file lock (`/tmp/caffeinate-ui.lock`)
- Kills stale caffeinate processes on launch; `killAll()` waits for pkill to finish before spawning new process
- Termination handler uses identity check (`===`) to avoid race conditions on rapid toggle changes
- State persistence: `isRestoring` flag suppresses `didSet` → `saveState()` during `restoreState()` to avoid cross-property overwrites
- `restoreState()` sets properties directly (not via bindings) so `didSet` handlers don't trigger `syncProcess()` during restore; `syncProcess()` is called explicitly after `restoreState()` in `init` to resume the previous session
- `scheduledDate` persisted as `timeIntervalSince1970` (Double); `.scheduled` timeout computes `scheduledDate - now` in seconds, clamped to 60s minimum
- `onTermination` callback clears `enabledFlags` and calls `saveState()` so UI resets when timeout expires naturally; countdown timer also clears state when reaching zero to avoid refill flash
- `totalTimeoutSeconds` tracks the initial timeout; `timeoutProgress` stored var updated every 0.25s from `timeoutStartDate` for smooth drain animation
- `MenuBarIcon` renders via `NSImage` (not SwiftUI shapes) because `MenuBarExtra` converts labels to template images; uses `isTemplate = true` so the icon adapts to light/dark; `TimelineView` does NOT work in `MenuBarExtra` labels
- `MenuBarIcon` uses `cup.and.heat.waves` / `cup.and.heat.waves.fill` SF Symbols; drain effect clips filled icon from bottom up with top/bottom offsets to avoid clipping steam waves and saucer
- Update checker fires async `Task` in `init` after `restoreState()`/`syncProcess()`; returns `.unknown` on any failure (graceful degradation); footer shows green dot (up to date), orange dot (update available, clickable), or no dot (unknown)
- After completing a task, update README.md and CLAUDE.md if the changes affect architecture, build commands, or conventions
