# Solar Explorer — CLAUDE.md

## Project Overview

visionOS solar system explorer app for Apple Vision Pro. SwiftUI + RealityKit, targeting visionOS 2.0+, Swift 6.

## Build & Test

```bash
# Generate Xcode project (after any file changes)
xcodegen generate

# Build (no simulator needed)
xcodebuild -project SolarExplorer.xcodeproj -target SolarExplorer -sdk xros26.2 CODE_SIGNING_ALLOWED=NO build

# Build tests
xcodebuild -project SolarExplorer.xcodeproj -target SolarExplorerTests -sdk xrsimulator26.2 CODE_SIGNING_ALLOWED=NO build
```

## Key Conventions

- **`import SwiftUI` only in App entry** — avoid `import RealityKit` in `SolarExplorerApp.swift` to prevent `Scene` ambiguity
- **`@MainActor`** required on all types that touch RealityKit entities (`EntityFactory`, `PlanetTextures`, `SolarSystemModel`)
- **ECS registration** must happen in `App.init()` before any scene renders
- **xcodegen** — after creating/renaming/deleting .swift files, run `xcodegen generate` to update the .xcodeproj
- **Textures in bundle** — xcodegen auto-includes `Resources/Textures/*.jpg` via the `sources: SolarExplorer` path

## Architecture

Three scene types registered in `SolarExplorerApp`:
1. `WindowGroup` → `HomeView` (2D planet list)
2. `WindowGroup(.volumetric)` → `SolarSystemView` (3D volume)
3. `ImmersiveSpace` → `ImmersiveView` (full immersion)

Shared state via `SolarSystemModel` (`@Observable`, injected as `.environment()`).

RealityKit uses ECS: `OrbitComponent`/`OrbitSystem` for orbits, `RotationComponent`/`RotationSystem` for spins.

## Common Pitfalls

- `Scene` is ambiguous when both SwiftUI and RealityKit are imported — use `SwiftUI.Scene` or avoid importing RealityKit in App file
- `ParticleEmitterComponent` API changes between visionOS versions — check release notes
- Gesture closures in RealityView need `@MainActor` safety for model mutations
- Quaternion multiplication accumulates floating-point error — normalize periodically
- `DragGesture.translation` is cumulative from start — track delta manually

## SourceKit Diagnostics

SourceKit-LSP does NOT support visionOS SDK indexing. You will see false-positive errors like "Cannot find type in scope" — always verify with `xcodebuild`, not IDE diagnostics.
