import SwiftUI

@main
struct SolarExplorerApp: App {
    @State private var solarSystemModel = SolarSystemModel()

    @MainActor
    init() {
        OrbitComponent.registerComponent()
        OrbitSystem.registerSystem()
        RotationComponent.registerComponent()
        RotationSystem.registerSystem()
    }

    var body: some SwiftUI.Scene {
        // Layer 1: 2D Window — planet list
        WindowGroup {
            HomeView()
                .environment(solarSystemModel)
        }
        .defaultSize(CGSize(width: 800, height: 600))

        // Layer 2: Volume — 3D solar system model
        WindowGroup(id: "SolarSystemVolume") {
            SolarSystemView()
                .environment(solarSystemModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.8, depth: 1.0, in: .meters)
        .volumeWorldAlignment(.gravityAligned)

        // Layer 3: Immersive Space
        ImmersiveSpace(id: "ImmersiveSolarSystem") {
            ImmersiveView()
                .environment(solarSystemModel)
        }
        .immersionStyle(selection: .init(
            get: { solarSystemModel.immersionStyle },
            set: { _ in }
        ), in: .mixed, .full)
    }
}
