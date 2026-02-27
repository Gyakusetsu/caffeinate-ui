# Caffeinate UI

macOS menu bar app providing a GUI for the `caffeinate` command.

## Tech Stack
- Swift 5.10 + SwiftUI
- macOS 14+ (Sonoma)
- SPM only — no Xcode project

## Build & Run
- Dev: `swift build && swift run CaffeinateUI`
- Release: `./build.sh && open ".build/release/Caffeinate UI.app"`

## Architecture
- **Models**: `CaffeinateFlag`, `TimeoutOption` — value types for flags and durations
- **Services**: `CaffeinateService` — spawns/kills `/usr/bin/caffeinate` Process
- **ViewModels**: `CaffeinateViewModel` — `@Observable` state management
- **Views**: SwiftUI views using `MenuBarExtra` with `.window` style

## Conventions
- `@Observable` (not `ObservableObject`) for state
- Kill-and-respawn pattern: changing flags kills existing process and spawns new one
- `LSUIElement = true` — no Dock icon
