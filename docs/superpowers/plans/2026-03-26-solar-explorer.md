# Solar Explorer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a visionOS app that lets users explore the solar system across three spatial modes: a 2D window with planet info, a 3D volumetric model with orbiting planets, and a fully immersive space experience.

**Architecture:** SwiftUI for all 2D UI (Window, info cards, ornaments). RealityKit ECS for 3D rendering and animation (orbit/rotation systems). Three scene types registered at app level: WindowGroup (home), WindowGroup+volumetric (solar system), ImmersiveSpace (full immersion). State managed via `@Observable` class shared across views.

**Tech Stack:** Swift 6, SwiftUI, RealityKit, ARKit, visionOS 2.0+ SDK, Xcode 16+

**Spec:** `docs/superpowers/specs/2026-03-26-solar-explorer-design.md`

---

## File Structure

```
SolarExplorer/
├── SolarExplorerApp.swift              # App entry: registers scenes, ECS components/systems
├── Models/
│   ├── Planet.swift                    # Planet data model (name, radius, orbit, texture, facts)
│   └── SolarSystemModel.swift          # @Observable state: selected planet, immersion mode
├── Views/
│   ├── HomeView.swift                  # Window: planet list with thumbnails
│   ├── SolarSystemView.swift           # Volume: RealityView with 3D solar system
│   ├── ImmersiveView.swift             # Immersive Space: full-scale experience
│   └── PlanetDetailCard.swift          # SwiftUI card shown as RealityView attachment
├── Systems/
│   ├── OrbitComponent.swift            # ECS component: radius, speed, angle
│   ├── OrbitSystem.swift               # ECS system: updates planet positions each frame
│   ├── RotationComponent.swift         # ECS component: rotation speed, axis
│   └── RotationSystem.swift            # ECS system: spins planets each frame
├── Helpers/
│   ├── EntityFactory.swift             # Creates planet/sun/orbit entities programmatically
│   └── PlanetTextures.swift            # Texture loading helper
├── Resources/
│   └── Textures/                       # Planet texture images (PNG/JPG)
└── SolarExplorerTests/
    ├── PlanetTests.swift               # Unit tests for Planet model
    └── OrbitSystemTests.swift          # Unit tests for orbit math
```

---

## Task 1: Create Xcode Project and App Shell

**Files:**
- Create: `SolarExplorer.xcodeproj` (via Xcode)
- Create: `SolarExplorer/SolarExplorerApp.swift`

**Prerequisites:** Xcode 16+ with visionOS SDK installed.

- [ ] **Step 1: Create visionOS project in Xcode**

Open Xcode → File → New → Project → visionOS → App.
- Product Name: `SolarExplorer`
- Team: (your team)
- Organization Identifier: your reverse domain
- Initial Scene: Window
- Immersive Space Renderer: RealityKit
- Immersive Space: Mixed

Save to `/Users/syu/repo/github/visonpro_test/`.

- [ ] **Step 2: Verify project builds in simulator**

In Xcode: Product → Run (or ⌘R). Select "Apple Vision Pro" simulator.
Expected: App launches showing a default window with "Hello, world!" in the simulator.

- [ ] **Step 3: Clean up template and set up App entry point**

Replace the contents of `SolarExplorerApp.swift`:

```swift
import SwiftUI
import RealityKit

@main
struct SolarExplorerApp: App {
    init() {
        OrbitComponent.registerComponent()
        OrbitSystem.registerSystem()
        RotationComponent.registerComponent()
        RotationSystem.registerSystem()
    }

    var body: some Scene {
        // Layer 1: 2D Window — planet list
        WindowGroup {
            HomeView()
        }
        .defaultSize(CGSize(width: 800, height: 600))

        // Layer 2: Volume — 3D solar system model
        WindowGroup(id: "SolarSystemVolume") {
            SolarSystemView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.8, depth: 1.0, in: .meters)
        .volumeWorldAlignment(.gravityAligned)

        // Layer 3: Immersive Space
        ImmersiveSpace(id: "ImmersiveSolarSystem") {
            ImmersiveView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .full)
    }
}
```

This won't compile yet (missing views, components, systems). That's expected — we'll add them in the next tasks.

- [ ] **Step 4: Create placeholder files so the project compiles**

Create these minimal placeholder files:

`SolarExplorer/Views/HomeView.swift`:
```swift
import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("Solar Explorer")
            .font(.largeTitle)
    }
}
```

`SolarExplorer/Views/SolarSystemView.swift`:
```swift
import SwiftUI
import RealityKit

struct SolarSystemView: View {
    var body: some View {
        RealityView { content in
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.1),
                materials: [SimpleMaterial(color: .yellow, isMetallic: false)]
            )
            content.add(sphere)
        }
    }
}
```

`SolarExplorer/Views/ImmersiveView.swift`:
```swift
import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.3),
                materials: [SimpleMaterial(color: .yellow, isMetallic: false)]
            )
            content.add(sphere)
        }
    }
}
```

`SolarExplorer/Systems/OrbitComponent.swift`:
```swift
import RealityKit

struct OrbitComponent: Component {
    var radius: Float = 1.0
    var speed: Float = 1.0
    var angle: Float = 0.0
}
```

`SolarExplorer/Systems/OrbitSystem.swift`:
```swift
import RealityKit

struct OrbitSystem: System {
    static let query = EntityQuery(where: .has(OrbitComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {}
}
```

`SolarExplorer/Systems/RotationComponent.swift`:
```swift
import RealityKit

struct RotationComponent: Component {
    var speed: Float = 1.0
    var axis: SIMD3<Float> = SIMD3(0, 1, 0)
}
```

`SolarExplorer/Systems/RotationSystem.swift`:
```swift
import RealityKit

struct RotationSystem: System {
    static let query = EntityQuery(where: .has(RotationComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {}
}
```

- [ ] **Step 5: Build and run to verify shell compiles**

In Xcode: ⌘R. Expected: App launches with "Solar Explorer" text in a window. No errors.

- [ ] **Step 6: Commit**

```bash
cd /Users/syu/repo/github/visonpro_test
git init
echo ".DS_Store\n*.xcuserdata\nDerivedData/\n.build/\n.superpowers/" > .gitignore
git add .
git commit -m "feat: initialize visionOS project with app shell and ECS placeholders"
```

---

## Task 2: Planet Data Model

**Files:**
- Create: `SolarExplorer/Models/Planet.swift`
- Create: `SolarExplorerTests/PlanetTests.swift`

- [ ] **Step 1: Write the failing test**

`SolarExplorerTests/PlanetTests.swift`:
```swift
import Testing
@testable import SolarExplorer

@Suite("Planet Model Tests")
struct PlanetTests {

    @Test("All 8 planets are defined")
    func allPlanetsExist() {
        #expect(Planet.allPlanets.count == 8)
    }

    @Test("Planets are ordered by distance from sun")
    func planetsOrderedByDistance() {
        let distances = Planet.allPlanets.map(\.distanceFromSun)
        let sorted = distances.sorted()
        #expect(distances == sorted)
    }

    @Test("Each planet has a fun fact")
    func eachPlanetHasFact() {
        for planet in Planet.allPlanets {
            #expect(!planet.funFact.isEmpty, "Missing fun fact for \(planet.name)")
        }
    }

    @Test("Mercury is the smallest planet")
    func mercuryIsSmallest() {
        let smallest = Planet.allPlanets.min(by: { $0.diameter < $1.diameter })
        #expect(smallest?.name == "Mercury")
    }

    @Test("Orbit radius scales correctly for Volume display")
    func orbitRadiusScale() {
        let mercury = Planet.allPlanets[0]
        let neptune = Planet.allPlanets[7]
        // Mercury should be closest, Neptune farthest
        #expect(mercury.orbitRadiusForVolume < neptune.orbitRadiusForVolume)
        // All orbit radii should fit within the volume (< 0.45 meters from center)
        for planet in Planet.allPlanets {
            #expect(planet.orbitRadiusForVolume <= 0.45,
                    "\(planet.name) orbit too large: \(planet.orbitRadiusForVolume)")
        }
    }

    @Test("Planet sphere radius scales correctly for Volume display")
    func sphereRadiusScale() {
        let jupiter = Planet.allPlanets.first(where: { $0.name == "Jupiter" })!
        let mercury = Planet.allPlanets.first(where: { $0.name == "Mercury" })!
        #expect(jupiter.sphereRadiusForVolume > mercury.sphereRadiusForVolume)
        // All sphere radii should be visible but not huge
        for planet in Planet.allPlanets {
            #expect(planet.sphereRadiusForVolume >= 0.005,
                    "\(planet.name) too small: \(planet.sphereRadiusForVolume)")
            #expect(planet.sphereRadiusForVolume <= 0.05,
                    "\(planet.name) too large: \(planet.sphereRadiusForVolume)")
        }
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

In Xcode: ⌘U or Product → Test.
Expected: Compilation error — `Planet` type not found.

- [ ] **Step 3: Implement Planet model**

`SolarExplorer/Models/Planet.swift`:
```swift
import Foundation
import SwiftUI

struct Planet: Identifiable, Sendable {
    let id: String
    let name: String
    let diameter: Double          // km
    let distanceFromSun: Double   // million km
    let orbitalPeriod: Double     // Earth days
    let rotationPeriod: Double    // Earth hours
    let color: Color
    let textureName: String
    let funFact: String

    // --- Volume display scaling ---
    // Maps real distances to 0.08...0.45 meter range for the Volume
    var orbitRadiusForVolume: Float {
        // Log scale to compress the huge range (58M km to 4,500M km)
        let minDist = log(58.0)    // Mercury
        let maxDist = log(4_500.0) // Neptune
        let normalized = Float((log(distanceFromSun) - minDist) / (maxDist - minDist))
        return 0.08 + normalized * 0.37 // range: 0.08 to 0.45 meters
    }

    // Maps real diameters to 0.005...0.05 meter range
    var sphereRadiusForVolume: Float {
        let minD = log(4_879.0)   // Mercury
        let maxD = log(139_820.0) // Jupiter
        let normalized = Float((log(diameter) - minD) / (maxD - minD))
        return 0.005 + normalized * 0.045 // range: 0.005 to 0.05 meters
    }

    // Orbit speed for Volume (scaled so innermost ~4s per orbit)
    var orbitSpeedForVolume: Float {
        // Inverse sqrt of period gives visually pleasing speed differences
        Float(4.0 / sqrt(orbitalPeriod / 88.0))
    }
}

extension Planet {
    static let allPlanets: [Planet] = [
        Planet(
            id: "mercury", name: "Mercury",
            diameter: 4_879, distanceFromSun: 57.9,
            orbitalPeriod: 88, rotationPeriod: 1407.6,
            color: .gray, textureName: "mercury_texture",
            funFact: "Mercury has no atmosphere and temperatures swing from -180°C to 430°C."
        ),
        Planet(
            id: "venus", name: "Venus",
            diameter: 12_104, distanceFromSun: 108.2,
            orbitalPeriod: 225, rotationPeriod: 5832.5,
            color: .orange, textureName: "venus_texture",
            funFact: "Venus rotates backwards — the Sun rises in the west."
        ),
        Planet(
            id: "earth", name: "Earth",
            diameter: 12_756, distanceFromSun: 149.6,
            orbitalPeriod: 365.2, rotationPeriod: 24,
            color: .blue, textureName: "earth_texture",
            funFact: "Earth is the only known planet with liquid water on its surface."
        ),
        Planet(
            id: "mars", name: "Mars",
            diameter: 6_792, distanceFromSun: 227.9,
            orbitalPeriod: 687, rotationPeriod: 24.6,
            color: .red, textureName: "mars_texture",
            funFact: "Mars has the tallest volcano in the solar system — Olympus Mons at 21.9 km."
        ),
        Planet(
            id: "jupiter", name: "Jupiter",
            diameter: 139_820, distanceFromSun: 778.6,
            orbitalPeriod: 4_331, rotationPeriod: 9.9,
            color: .brown, textureName: "jupiter_texture",
            funFact: "Jupiter's Great Red Spot is a storm larger than Earth that has raged for centuries."
        ),
        Planet(
            id: "saturn", name: "Saturn",
            diameter: 116_460, distanceFromSun: 1_433.5,
            orbitalPeriod: 10_747, rotationPeriod: 10.7,
            color: .yellow, textureName: "saturn_texture",
            funFact: "Saturn's density is so low it would float in water."
        ),
        Planet(
            id: "uranus", name: "Uranus",
            diameter: 50_724, distanceFromSun: 2_872.5,
            orbitalPeriod: 30_589, rotationPeriod: 17.2,
            color: .cyan, textureName: "uranus_texture",
            funFact: "Uranus rotates on its side, with an axial tilt of 98 degrees."
        ),
        Planet(
            id: "neptune", name: "Neptune",
            diameter: 49_528, distanceFromSun: 4_495.1,
            orbitalPeriod: 59_800, rotationPeriod: 16.1,
            color: .indigo, textureName: "neptune_texture",
            funFact: "Neptune has the strongest winds in the solar system — up to 2,100 km/h."
        ),
    ]
}
```

- [ ] **Step 4: Run tests to verify they pass**

In Xcode: ⌘U.
Expected: All 6 tests in `PlanetTests` pass.

- [ ] **Step 5: Commit**

```bash
git add SolarExplorer/Models/Planet.swift SolarExplorerTests/PlanetTests.swift
git commit -m "feat: add Planet data model with scaling logic and unit tests"
```

---

## Task 3: Solar System State Model

**Files:**
- Create: `SolarExplorer/Models/SolarSystemModel.swift`

- [ ] **Step 1: Create the observable state model**

`SolarExplorer/Models/SolarSystemModel.swift`:
```swift
import SwiftUI
import Observation

@Observable
final class SolarSystemModel {
    var selectedPlanet: Planet?
    var isShowingVolume: Bool = false
    var isShowingImmersive: Bool = false
    var immersionStyle: ImmersionStyleChoice = .mixed

    func selectPlanet(_ planet: Planet) {
        selectedPlanet = planet
    }

    func clearSelection() {
        selectedPlanet = nil
    }

    func toggleImmersionStyle() {
        immersionStyle = (immersionStyle == .mixed) ? .full : .mixed
    }
}

enum ImmersionStyleChoice {
    case mixed
    case full
}
```

- [ ] **Step 2: Wire into App entry point**

Update `SolarExplorerApp.swift` to inject the model as environment:

```swift
import SwiftUI
import RealityKit

@main
struct SolarExplorerApp: App {
    @State private var solarSystemModel = SolarSystemModel()

    init() {
        OrbitComponent.registerComponent()
        OrbitSystem.registerSystem()
        RotationComponent.registerComponent()
        RotationSystem.registerSystem()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(solarSystemModel)
        }
        .defaultSize(CGSize(width: 800, height: 600))

        WindowGroup(id: "SolarSystemVolume") {
            SolarSystemView()
                .environment(solarSystemModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.8, depth: 1.0, in: .meters)
        .volumeWorldAlignment(.gravityAligned)

        ImmersiveSpace(id: "ImmersiveSolarSystem") {
            ImmersiveView()
                .environment(solarSystemModel)
        }
        .immersionStyle(selection: $immersionSelection, in: .mixed, .full)
    }
}
```

- [ ] **Step 3: Build to verify compilation**

In Xcode: ⌘B. Expected: Build succeeds with no errors.

- [ ] **Step 4: Commit**

```bash
git add SolarExplorer/Models/SolarSystemModel.swift SolarExplorer/SolarExplorerApp.swift
git commit -m "feat: add observable SolarSystemModel and wire into app environment"
```

---

## Task 4: Home Window — Planet List UI

**Files:**
- Modify: `SolarExplorer/Views/HomeView.swift`
- Create: `SolarExplorer/Views/PlanetDetailCard.swift`

- [ ] **Step 1: Implement HomeView with planet list**

Replace `SolarExplorer/Views/HomeView.swift`:
```swift
import SwiftUI

struct HomeView: View {
    @Environment(SolarSystemModel.self) private var model
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        NavigationStack {
            List(Planet.allPlanets) { planet in
                Button {
                    model.selectPlanet(planet)
                } label: {
                    PlanetRow(planet: planet)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Solar Explorer")
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    Button("Explore Solar System") {
                        openWindow(id: "SolarSystemVolume")
                        model.isShowingVolume = true
                    }
                    .font(.title3)
                    .controlSize(.large)
                }
            }
            .sheet(item: Binding(
                get: { model.selectedPlanet },
                set: { planet in
                    if planet == nil { model.clearSelection() }
                }
            )) { planet in
                PlanetDetailCard(planet: planet)
            }
        }
    }
}

struct PlanetRow: View {
    let planet: Planet

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(planet.color)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(planet.name)
                    .font(.headline)
                Text("\(Int(planet.distanceFromSun)) million km from Sun")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(Int(planet.diameter)) km")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
```

- [ ] **Step 2: Implement PlanetDetailCard**

`SolarExplorer/Views/PlanetDetailCard.swift`:
```swift
import SwiftUI

struct PlanetDetailCard: View {
    let planet: Planet

    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(planet.color)
                .frame(width: 80, height: 80)

            Text(planet.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                GridRow {
                    Text("Diameter")
                        .foregroundStyle(.secondary)
                    Text("\(Int(planet.diameter)) km")
                }
                GridRow {
                    Text("Distance from Sun")
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", planet.distanceFromSun)) million km")
                }
                GridRow {
                    Text("Orbital Period")
                        .foregroundStyle(.secondary)
                    Text("\(Int(planet.orbitalPeriod)) days")
                }
                GridRow {
                    Text("Rotation Period")
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", planet.rotationPeriod)) hours")
                }
            }
            .font(.body)

            Text(planet.funFact)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(30)
        .frame(maxWidth: 400)
    }
}
```

- [ ] **Step 3: Make Planet conform to Identifiable for sheet binding**

Planet already conforms to `Identifiable` (from Task 2). Verify the sheet binding compiles.

- [ ] **Step 4: Build and run in simulator**

In Xcode: ⌘R. Expected: Window shows a list of 8 planets. Tapping a planet shows a detail card sheet. "Explore Solar System" button visible at bottom.

- [ ] **Step 5: Commit**

```bash
git add SolarExplorer/Views/HomeView.swift SolarExplorer/Views/PlanetDetailCard.swift
git commit -m "feat: implement HomeView planet list and PlanetDetailCard"
```

---

## Task 5: Entity Factory — Programmatic Planet/Sun/Orbit Creation

**Files:**
- Create: `SolarExplorer/Helpers/EntityFactory.swift`

- [ ] **Step 1: Implement EntityFactory**

`SolarExplorer/Helpers/EntityFactory.swift`:
```swift
import RealityKit
import Foundation

enum EntityFactory {

    /// Creates the sun entity — a glowing yellow sphere
    static func makeSun(radius: Float = 0.04) -> ModelEntity {
        var material = UnlitMaterial()
        material.color = .init(tint: .init(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0))

        let sun = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [material]
        )
        sun.name = "Sun"
        sun.components.set(RotationComponent(speed: 0.2, axis: SIMD3(0, 1, 0)))
        return sun
    }

    /// Creates a planet entity as a colored sphere with orbit and rotation components
    static func makePlanet(_ planet: Planet) -> ModelEntity {
        let material = SimpleMaterial(
            color: .init(planet.color),
            isMetallic: false
        )

        let entity = ModelEntity(
            mesh: .generateSphere(radius: planet.sphereRadiusForVolume),
            materials: [material]
        )
        entity.name = planet.id

        // ECS components for animation
        entity.components.set(OrbitComponent(
            radius: planet.orbitRadiusForVolume,
            speed: planet.orbitSpeedForVolume,
            angle: Float.random(in: 0...(2 * .pi)) // random starting position
        ))
        entity.components.set(RotationComponent(
            speed: Float(24.0 / planet.rotationPeriod), // relative to Earth
            axis: SIMD3(0, 1, 0)
        ))

        // Required for tap/gaze interaction
        entity.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: planet.sphereRadiusForVolume * 1.5)]
        ))
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())

        return entity
    }

    /// Creates a thin torus orbit ring
    static func makeOrbitRing(radius: Float) throws -> ModelEntity {
        let mesh = try EntityFactory.generateTorusMesh(
            majorRadius: radius,
            minorRadius: 0.001,
            majorSegments: 64,
            minorSegments: 8
        )

        var material = UnlitMaterial()
        material.color = .init(tint: .white.withAlphaComponent(0.2))

        let ring = ModelEntity(mesh: mesh, materials: [material])
        ring.name = "orbit_ring"
        return ring
    }

    /// Generates a torus mesh via MeshDescriptor
    private static func generateTorusMesh(
        majorRadius: Float,
        minorRadius: Float,
        majorSegments: Int,
        minorSegments: Int
    ) throws -> MeshResource {
        var positions: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []
        var indices: [UInt32] = []

        for i in 0...majorSegments {
            let u = Float(i) / Float(majorSegments)
            let theta = u * 2.0 * .pi

            for j in 0...minorSegments {
                let v = Float(j) / Float(minorSegments)
                let phi = v * 2.0 * .pi

                let x = (majorRadius + minorRadius * cos(phi)) * cos(theta)
                let y = minorRadius * sin(phi)
                let z = (majorRadius + minorRadius * cos(phi)) * sin(theta)

                positions.append(SIMD3(x, y, z))
                normals.append(normalize(SIMD3(
                    cos(phi) * cos(theta),
                    sin(phi),
                    cos(phi) * sin(theta)
                )))
                uvs.append(SIMD2(u, v))
            }
        }

        for i in 0..<majorSegments {
            for j in 0..<minorSegments {
                let a = UInt32(i * (minorSegments + 1) + j)
                let b = a + 1
                let c = UInt32((i + 1) * (minorSegments + 1) + j)
                let d = c + 1
                indices.append(contentsOf: [a, c, b, b, c, d])
            }
        }

        var descriptor = MeshDescriptor(name: "Torus")
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.normals = MeshBuffers.Normals(normals)
        descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
        descriptor.primitives = .triangles(indices)

        return try MeshResource.generate(from: [descriptor])
    }
}

// Helper: convert SwiftUI Color to UIColor for RealityKit materials
extension UIColor {
    convenience init(_ color: SwiftUI.Color) {
        let components = color.resolve(in: EnvironmentValues())
        self.init(
            red: CGFloat(components.red),
            green: CGFloat(components.green),
            blue: CGFloat(components.blue),
            alpha: CGFloat(components.opacity)
        )
    }
}
```

- [ ] **Step 2: Build to verify compilation**

In Xcode: ⌘B. Expected: Builds with no errors.

- [ ] **Step 3: Commit**

```bash
git add SolarExplorer/Helpers/EntityFactory.swift
git commit -m "feat: add EntityFactory for programmatic sun, planet, and orbit ring creation"
```

---

## Task 6: ECS Orbit and Rotation Systems

**Files:**
- Modify: `SolarExplorer/Systems/OrbitComponent.swift`
- Modify: `SolarExplorer/Systems/OrbitSystem.swift`
- Modify: `SolarExplorer/Systems/RotationComponent.swift`
- Modify: `SolarExplorer/Systems/RotationSystem.swift`
- Create: `SolarExplorerTests/OrbitSystemTests.swift`

- [ ] **Step 1: Write failing test for orbit math**

`SolarExplorerTests/OrbitSystemTests.swift`:
```swift
import Testing
import simd
@testable import SolarExplorer

@Suite("Orbit Math Tests")
struct OrbitMathTests {

    @Test("Orbit position calculates correctly at angle 0")
    func orbitPositionAtZero() {
        let position = OrbitMath.position(radius: 1.0, angle: 0)
        #expect(abs(position.x - 1.0) < 0.001)
        #expect(abs(position.y) < 0.001)
        #expect(abs(position.z) < 0.001)
    }

    @Test("Orbit position at pi/2 gives z = radius")
    func orbitPositionAtHalfPi() {
        let position = OrbitMath.position(radius: 2.0, angle: .pi / 2)
        #expect(abs(position.x) < 0.001)
        #expect(abs(position.z - 2.0) < 0.001)
    }

    @Test("Angle advances by speed * deltaTime")
    func angleAdvancement() {
        let newAngle = OrbitMath.advanceAngle(
            currentAngle: 1.0, speed: 2.0, deltaTime: 0.5
        )
        #expect(abs(newAngle - 2.0) < 0.001) // 1.0 + 2.0 * 0.5
    }

    @Test("Angle wraps around 2*pi")
    func angleWrapping() {
        let newAngle = OrbitMath.advanceAngle(
            currentAngle: 6.0, speed: 1.0, deltaTime: 1.0
        )
        #expect(newAngle >= 0)
        #expect(newAngle < 2 * .pi)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

In Xcode: ⌘U. Expected: Compilation error — `OrbitMath` not found.

- [ ] **Step 3: Update OrbitComponent with full fields**

Replace `SolarExplorer/Systems/OrbitComponent.swift`:
```swift
import RealityKit
import simd

struct OrbitComponent: Component {
    var radius: Float
    var speed: Float
    var angle: Float

    init(radius: Float = 1.0, speed: Float = 1.0, angle: Float = 0.0) {
        self.radius = radius
        self.speed = speed
        self.angle = angle
    }
}

/// Pure math functions for orbit calculations, testable without RealityKit scene
enum OrbitMath {
    static func position(radius: Float, angle: Float) -> SIMD3<Float> {
        SIMD3(
            radius * cos(angle),
            0,
            radius * sin(angle)
        )
    }

    static func advanceAngle(currentAngle: Float, speed: Float, deltaTime: Float) -> Float {
        let newAngle = currentAngle + speed * deltaTime
        let twoPi = 2.0 * Float.pi
        return newAngle.truncatingRemainder(dividingBy: twoPi)
    }
}
```

- [ ] **Step 4: Update OrbitSystem to use OrbitMath**

Replace `SolarExplorer/Systems/OrbitSystem.swift`:
```swift
import RealityKit

struct OrbitSystem: System {
    static let query = EntityQuery(where: .has(OrbitComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var orbit = entity.components[OrbitComponent.self] else { continue }

            orbit.angle = OrbitMath.advanceAngle(
                currentAngle: orbit.angle,
                speed: orbit.speed,
                deltaTime: deltaTime
            )
            entity.components.set(orbit)

            let position = OrbitMath.position(radius: orbit.radius, angle: orbit.angle)
            entity.position = position
        }
    }
}
```

- [ ] **Step 5: Update RotationComponent and RotationSystem**

Replace `SolarExplorer/Systems/RotationComponent.swift`:
```swift
import RealityKit
import simd

struct RotationComponent: Component {
    var speed: Float
    var axis: SIMD3<Float>

    init(speed: Float = 1.0, axis: SIMD3<Float> = SIMD3(0, 1, 0)) {
        self.speed = speed
        self.axis = axis
    }
}
```

Replace `SolarExplorer/Systems/RotationSystem.swift`:
```swift
import RealityKit
import simd

struct RotationSystem: System {
    static let query = EntityQuery(where: .has(RotationComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let rotation = entity.components[RotationComponent.self] else { continue }

            let angle = rotation.speed * deltaTime
            let increment = simd_quatf(angle: angle, axis: rotation.axis)
            entity.orientation = entity.orientation * increment
        }
    }
}
```

- [ ] **Step 6: Run tests**

In Xcode: ⌘U. Expected: All `OrbitMathTests` pass (4 tests). All `PlanetTests` still pass (6 tests).

- [ ] **Step 7: Commit**

```bash
git add SolarExplorer/Systems/ SolarExplorerTests/OrbitSystemTests.swift
git commit -m "feat: implement ECS orbit and rotation systems with testable math"
```

---

## Task 7: Solar System Volume View — 3D Scene

**Files:**
- Modify: `SolarExplorer/Views/SolarSystemView.swift`

- [ ] **Step 1: Implement the full Volume RealityView**

Replace `SolarExplorer/Views/SolarSystemView.swift`:
```swift
import SwiftUI
import RealityKit

struct SolarSystemView: View {
    @Environment(SolarSystemModel.self) private var model
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        RealityView { content, attachments in
            // Root entity for the entire solar system
            let root = Entity()
            root.name = "SolarSystemRoot"
            content.add(root)

            // Sun
            let sun = EntityFactory.makeSun()
            root.addChild(sun)

            // Planets and orbit rings
            for planet in Planet.allPlanets {
                // Orbit ring
                if let ring = try? EntityFactory.makeOrbitRing(radius: planet.orbitRadiusForVolume) {
                    root.addChild(ring)
                }

                // Planet entity
                let planetEntity = EntityFactory.makePlanet(planet)
                root.addChild(planetEntity)

                // Floating name label (attachment)
                if let label = attachments.entity(for: planet.id) {
                    label.position = SIMD3(0, planet.sphereRadiusForVolume + 0.015, 0)
                    planetEntity.addChild(label)
                }
            }

            // Position root slightly below center of volume
            root.position.y = -0.1
        } update: { content, attachments in
            // Update selected state visuals if needed
        } attachments: {
            ForEach(Planet.allPlanets) { planet in
                Attachment(id: planet.id) {
                    Text(planet.name)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glassBackgroundEffect()
                }
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let tappedName = value.entity.name
                    if let planet = Planet.allPlanets.first(where: { $0.id == tappedName }) {
                        model.selectPlanet(planet)
                    }
                }
        )
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                HStack(spacing: 20) {
                    if let selected = model.selectedPlanet {
                        VStack {
                            Text(selected.name).font(.headline)
                            Text(selected.funFact).font(.caption2)
                                .frame(maxWidth: 300)
                        }
                        .padding()
                        .glassBackgroundEffect()
                    }

                    Button("Immersive Experience") {
                        Task {
                            let result = await openImmersiveSpace(id: "ImmersiveSolarSystem")
                            if case .opened = result {
                                model.isShowingImmersive = true
                            }
                        }
                    }
                    .disabled(model.isShowingImmersive)
                }
            }
        }
    }
}
```

- [ ] **Step 2: Build and run in simulator**

In Xcode: ⌘R. From the Home window, tap "Explore Solar System".
Expected: A Volume window opens with a yellow sun at center and 8 colored spheres orbiting around it. Orbit rings visible as faint white lines. Planet name labels float above each planet. Tapping a planet shows its name and fun fact in the bottom ornament.

- [ ] **Step 3: Commit**

```bash
git add SolarExplorer/Views/SolarSystemView.swift
git commit -m "feat: implement 3D solar system Volume view with orbiting planets"
```

---

## Task 8: Immersive Space View

**Files:**
- Modify: `SolarExplorer/Views/ImmersiveView.swift`

- [ ] **Step 1: Implement the immersive view**

Replace `SolarExplorer/Views/ImmersiveView.swift`:
```swift
import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(SolarSystemModel.self) private var model
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            // Root entity
            let root = Entity()
            root.name = "ImmersiveRoot"
            content.add(root)

            // Sun at center, larger scale
            let sun = EntityFactory.makeSun(radius: 0.3)
            sun.position = SIMD3(0, 1.2, -2.0) // In front and slightly above user
            root.addChild(sun)

            // Point light from sun
            let light = Entity()
            light.components.set(PointLightComponent(
                color: .white,
                intensity: 10000,
                attenuationRadius: 20
            ))
            light.position = sun.position
            root.addChild(light)

            // Planets at larger scale
            let immersiveScale: Float = 5.0
            for planet in Planet.allPlanets {
                let planetEntity = EntityFactory.makePlanet(planet)

                // Scale up orbit radius and sphere size for immersive
                var orbit = planetEntity.components[OrbitComponent.self]!
                orbit.radius *= immersiveScale
                planetEntity.components.set(orbit)

                // Re-create with larger mesh
                let largerRadius = planet.sphereRadiusForVolume * immersiveScale
                planetEntity.model = ModelComponent(
                    mesh: .generateSphere(radius: largerRadius),
                    materials: [SimpleMaterial(
                        color: .init(planet.color),
                        isMetallic: false
                    )]
                )

                // Update collision for larger size
                planetEntity.components.set(CollisionComponent(
                    shapes: [.generateSphere(radius: largerRadius * 1.5)]
                ))

                // Position orbits around the sun position
                let orbitAnchor = Entity()
                orbitAnchor.position = sun.position
                orbitAnchor.addChild(planetEntity)
                root.addChild(orbitAnchor)

                // Orbit ring
                if let ring = try? EntityFactory.makeOrbitRing(radius: orbit.radius) {
                    ring.position = sun.position
                    root.addChild(ring)
                }
            }

            // Starfield background sphere
            let starfield = ModelEntity(
                mesh: .generateSphere(radius: 15),
                materials: [makeStarfieldMaterial()]
            )
            starfield.scale = SIMD3(-1, 1, 1) // Invert normals to see inside
            starfield.position.y = 1.2
            root.addChild(starfield)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let tappedName = value.entity.name
                    if let planet = Planet.allPlanets.first(where: { $0.id == tappedName }) {
                        model.selectPlanet(planet)
                    }
                }
        )
        .toolbar {
            ToolbarItem(placement: .bottomOrnament) {
                HStack(spacing: 20) {
                    if let selected = model.selectedPlanet {
                        VStack {
                            Text(selected.name).font(.headline)
                            Text(selected.funFact).font(.caption2)
                                .frame(maxWidth: 300)
                        }
                        .padding()
                        .glassBackgroundEffect()
                    }

                    Button(model.immersionStyle == .mixed ? "Full Starfield" : "Mixed Reality") {
                        model.toggleImmersionStyle()
                    }

                    Button("Exit Immersive") {
                        Task {
                            await dismissImmersiveSpace()
                            model.isShowingImmersive = false
                        }
                    }
                }
            }
        }
    }

    /// Creates a dark material for the background sphere
    private func makeStarfieldMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        material.color = .init(tint: .init(white: 0.02, alpha: 1.0))
        return material
    }
}
```

- [ ] **Step 2: Build and run in simulator**

In Xcode: ⌘R. Navigate to Volume → tap "Immersive Experience".
Expected: Immersive space opens. Larger sun and planets visible in front of user. Planets orbit around the sun. Dark background sphere surrounds the scene. "Exit Immersive" button in ornament returns to Volume.

- [ ] **Step 3: Commit**

```bash
git add SolarExplorer/Views/ImmersiveView.swift
git commit -m "feat: implement immersive space with scaled solar system and starfield"
```

---

## Task 9: Gesture Interactions — Rotate and Zoom Volume

**Files:**
- Modify: `SolarExplorer/Views/SolarSystemView.swift`

- [ ] **Step 1: Add drag-to-rotate and magnify-to-zoom gestures**

Add these gesture modifiers to `SolarSystemView`, after the existing `SpatialTapGesture`:

In `SolarSystemView.swift`, after `.gesture(SpatialTapGesture()...)`, add:

```swift
.gesture(
    DragGesture()
        .targetedToAnyEntity()
        .onChanged { value in
            guard let root = value.entity.parent ?? value.entity.findEntity(named: "SolarSystemRoot") else { return }
            if root.name == "SolarSystemRoot" || root.parent?.name == "SolarSystemRoot" {
                let rotation = simd_quatf(
                    angle: Float(value.translation.width) * 0.005,
                    axis: SIMD3(0, 1, 0)
                )
                let rootEntity = root.name == "SolarSystemRoot" ? root : root.parent!
                rootEntity.orientation = rootEntity.orientation * rotation
            }
        }
)
.gesture(
    MagnifyGesture()
        .targetedToAnyEntity()
        .onChanged { value in
            guard let root = findRoot(from: value.entity) else { return }
            let scale = Float(value.magnification)
            let clampedScale = min(max(scale, 0.5), 2.0)
            root.scale = SIMD3(repeating: clampedScale)
        }
)
```

Also add this helper method inside `SolarSystemView`:

```swift
private func findRoot(from entity: Entity) -> Entity? {
    var current: Entity? = entity
    while let parent = current?.parent {
        if parent.name == "SolarSystemRoot" { return parent }
        current = parent
    }
    if entity.name == "SolarSystemRoot" { return entity }
    return nil
}
```

- [ ] **Step 2: Build and run in simulator**

In Xcode: ⌘R. Open the Volume. Use trackpad drag to rotate the solar system. Use pinch gesture (Option+drag in simulator) to zoom.
Expected: Solar system rotates smoothly when dragged. Zooms in/out with magnify gesture, clamped between 0.5x and 2.0x.

- [ ] **Step 3: Commit**

```bash
git add SolarExplorer/Views/SolarSystemView.swift
git commit -m "feat: add drag-to-rotate and pinch-to-zoom gestures to Volume view"
```

---

## Task 10: Sun Glow Effect with Particle Emitter

**Files:**
- Modify: `SolarExplorer/Helpers/EntityFactory.swift`

- [ ] **Step 1: Add corona particle effect to the sun**

Add this method to `EntityFactory`:

```swift
/// Creates a particle emitter for the sun's corona effect
static func makeSunCorona(sunRadius: Float) -> Entity {
    let corona = Entity()
    corona.name = "SunCorona"

    var particles = ParticleEmitterComponent()
    particles.emitterShape = .sphere
    particles.emitterShapeSize = SIMD3(repeating: sunRadius * 1.2)
    particles.mainEmitter.birthRate = 200
    particles.mainEmitter.lifeSpan = 1.5
    particles.mainEmitter.size = 0.005
    particles.mainEmitter.color = .evolving(
        start: .single(.init(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.8)),
        end: .single(.init(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.0))
    )
    particles.mainEmitter.spreadingAngle = .pi
    particles.speed = 0.02
    particles.mainEmitter.blendMode = .additive

    corona.components.set(particles)
    return corona
}
```

- [ ] **Step 2: Wire corona into makeSun**

Update the `makeSun` method to add corona as a child:

```swift
static func makeSun(radius: Float = 0.04) -> ModelEntity {
    var material = UnlitMaterial()
    material.color = .init(tint: .init(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0))

    let sun = ModelEntity(
        mesh: .generateSphere(radius: radius),
        materials: [material]
    )
    sun.name = "Sun"
    sun.components.set(RotationComponent(speed: 0.2, axis: SIMD3(0, 1, 0)))

    // Add corona particle effect
    let corona = makeSunCorona(sunRadius: radius)
    sun.addChild(corona)

    return sun
}
```

- [ ] **Step 3: Build and run in simulator**

In Xcode: ⌘R. Open the Volume.
Expected: Sun has a glowing corona effect — particles emanate outward from the sun surface, fading from yellow to transparent red.

- [ ] **Step 4: Commit**

```bash
git add SolarExplorer/Helpers/EntityFactory.swift
git commit -m "feat: add particle-based corona effect to the sun"
```

---

## Task 11: Planet Textures (Optional Enhancement)

**Files:**
- Create: `SolarExplorer/Helpers/PlanetTextures.swift`
- Modify: `SolarExplorer/Helpers/EntityFactory.swift`
- Add: texture images to `SolarExplorer/Resources/Textures/`

This task enhances visuals by replacing solid colors with planet textures. If you want to skip this for now and keep solid colors, go directly to Task 12.

- [ ] **Step 1: Download free planet textures**

Download planet texture images from Solar System Scope (https://www.solarsystemscope.com/textures/) or NASA Visible Earth. Save as:
- `SolarExplorer/Resources/Textures/mercury_texture.jpg`
- `SolarExplorer/Resources/Textures/venus_texture.jpg`
- `SolarExplorer/Resources/Textures/earth_texture.jpg`
- `SolarExplorer/Resources/Textures/mars_texture.jpg`
- `SolarExplorer/Resources/Textures/jupiter_texture.jpg`
- `SolarExplorer/Resources/Textures/saturn_texture.jpg`
- `SolarExplorer/Resources/Textures/uranus_texture.jpg`
- `SolarExplorer/Resources/Textures/neptune_texture.jpg`

Add them to the Xcode project's asset catalog or directly in the bundle.

- [ ] **Step 2: Create PlanetTextures helper**

`SolarExplorer/Helpers/PlanetTextures.swift`:
```swift
import RealityKit

enum PlanetTextures {
    /// Loads a texture and creates a PBR material, falls back to solid color
    static func material(for planet: Planet) async -> any RealityKit.Material {
        do {
            let texture = try await TextureResource(named: planet.textureName)
            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(texture: .init(texture))
            material.roughness = .init(floatLiteral: 0.7)
            material.metallic = .init(floatLiteral: 0.0)
            return material
        } catch {
            // Fallback to solid color
            return SimpleMaterial(
                color: .init(planet.color),
                isMetallic: false
            )
        }
    }
}
```

- [ ] **Step 3: Update EntityFactory.makePlanet to use textures**

Change `makePlanet` to be async and use `PlanetTextures`:

```swift
static func makePlanet(_ planet: Planet) async -> ModelEntity {
    let material = await PlanetTextures.material(for: planet)

    let entity = ModelEntity(
        mesh: .generateSphere(radius: planet.sphereRadiusForVolume),
        materials: [material]
    )
    entity.name = planet.id

    entity.components.set(OrbitComponent(
        radius: planet.orbitRadiusForVolume,
        speed: planet.orbitSpeedForVolume,
        angle: Float.random(in: 0...(2 * .pi))
    ))
    entity.components.set(RotationComponent(
        speed: Float(24.0 / planet.rotationPeriod),
        axis: SIMD3(0, 1, 0)
    ))
    entity.components.set(CollisionComponent(
        shapes: [.generateSphere(radius: planet.sphereRadiusForVolume * 1.5)]
    ))
    entity.components.set(InputTargetComponent())
    entity.components.set(HoverEffectComponent())

    return entity
}
```

Update callers in `SolarSystemView` and `ImmersiveView` to `await EntityFactory.makePlanet(planet)`.

- [ ] **Step 4: Build and run**

In Xcode: ⌘R. Expected: Planets show texture maps instead of solid colors (or gracefully fall back to colors if textures aren't found).

- [ ] **Step 5: Commit**

```bash
git add SolarExplorer/Helpers/PlanetTextures.swift SolarExplorer/Helpers/EntityFactory.swift SolarExplorer/Resources/
git commit -m "feat: add planet texture support with PBR materials"
```

---

## Task 12: Final Polish and Integration Test

**Files:**
- All existing files (verification pass)

- [ ] **Step 1: Full flow integration test in simulator**

Run the app in the visionOS simulator and verify the complete user flow:

1. App launches → HomeView shows list of 8 planets
2. Tap a planet → detail card sheet appears with correct data
3. Dismiss sheet → tap "Explore Solar System"
4. Volume opens → 3D solar system with sun (glowing) and 8 orbiting planets
5. Planets orbit and rotate continuously
6. Orbit rings visible as faint white lines
7. Name labels float above planets
8. Gaze at a planet → hover highlight appears
9. Tap a planet → name and fun fact show in bottom ornament
10. Drag to rotate the entire model
11. Pinch to zoom in/out (0.5x to 2.0x range)
12. Tap "Immersive Experience" → immersive space opens
13. Larger scale solar system surrounds user
14. Dark starfield background
15. Tap "Exit Immersive" → returns to Volume

Document any issues found.

- [ ] **Step 2: Fix any issues discovered**

Address bugs found during integration testing.

- [ ] **Step 3: Run all unit tests**

In Xcode: ⌘U. Expected: All tests pass (PlanetTests: 6, OrbitMathTests: 4).

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "chore: integration verification pass — all flows working"
```

---

## Summary

| Task | Description | Key Files |
|------|-------------|-----------|
| 1 | Xcode project + app shell | `SolarExplorerApp.swift`, placeholder views |
| 2 | Planet data model + tests | `Planet.swift`, `PlanetTests.swift` |
| 3 | Observable state model | `SolarSystemModel.swift` |
| 4 | Home window UI | `HomeView.swift`, `PlanetDetailCard.swift` |
| 5 | Entity factory | `EntityFactory.swift` |
| 6 | ECS systems + tests | `Orbit/RotationSystem.swift`, `OrbitSystemTests.swift` |
| 7 | Volume 3D scene | `SolarSystemView.swift` |
| 8 | Immersive space | `ImmersiveView.swift` |
| 9 | Gesture interactions | `SolarSystemView.swift` (gestures) |
| 10 | Sun corona particles | `EntityFactory.swift` (particles) |
| 11 | Planet textures (optional) | `PlanetTextures.swift`, texture assets |
| 12 | Integration test | All files (verification) |
