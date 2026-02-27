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
- **Models**: `CaffeinateFlag`, `TimeoutOption` — `Codable` value types for flags and durations
- **Services**: `CaffeinateServiceProtocol` / `CaffeinateService` — spawns/kills `/usr/bin/caffeinate` Process; `UserDefaultsProtocol` for testable persistence
- **ViewModels**: `CaffeinateViewModel` — `@Observable` state management, accepts `service` and `defaults` via init; persists flags/timeout to UserDefaults; `launchAtLogin` via `SMAppService`
- **Views**: SwiftUI views using `MenuBarExtra` with `.window` style; includes "Enable All" master toggle, "Launch at Login" option, and `MenuBarIcon` with draining cup fill overlay
- **Resources**: `Info.plist`, `AppIcon.icns` (coffee cup icon generated from SF Symbol)

## Testing
- XCTest with `@testable import CaffeinateCore`
- `MockCaffeinateService` and `MockUserDefaults` (test spies in `TestHelpers.swift`) — no real processes or UserDefaults
- `PersistenceTests` verifies save/restore cycle, corrupted-data resilience, and that restore does not auto-start caffeinating
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
- `restoreState()` sets properties directly (not via bindings) so caffeinate does NOT auto-start on launch
- `onTermination` callback clears `enabledFlags` and calls `saveState()` so UI resets when timeout expires naturally; countdown timer also clears state when reaching zero to avoid refill flash
- `totalTimeoutSeconds` tracks the initial timeout; `timeoutProgress` stored var updated every 0.25s from `timeoutStartDate` for smooth drain animation
- `MenuBarIcon` renders via `NSImage` (not SwiftUI shapes) because `MenuBarExtra` converts labels to template images; uses `isTemplate = true` so the icon adapts to light/dark; `TimelineView` does NOT work in `MenuBarExtra` labels
- `MenuBarIcon` uses `cup.and.heat.waves` / `cup.and.heat.waves.fill` SF Symbols; drain effect clips filled icon from bottom up with top/bottom offsets to avoid clipping steam waves and saucer
- After completing a task, update README.md and CLAUDE.md if the changes affect architecture, build commands, or conventions
