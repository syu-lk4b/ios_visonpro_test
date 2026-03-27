import SwiftUI
import RealityKit

struct SolarSystemView: View {
    @Environment(SolarSystemModel.self) private var model
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var lastDragWidth: CGFloat = 0
    @State private var baseScale: Float = 1.0

    var body: some View {
        RealityView { content, attachments in
            let root = Entity()
            root.name = "SolarSystemRoot"
            content.add(root)

            let sun = await EntityFactory.makeSun()
            root.addChild(sun)

            for planet in Planet.allPlanets {
                if let ring = try? EntityFactory.makeOrbitRing(radius: planet.orbitRadiusForVolume) {
                    root.addChild(ring)
                }

                let planetEntity = await EntityFactory.makePlanet(planet)
                root.addChild(planetEntity)

                if let label = attachments.entity(for: planet.id) {
                    label.position = SIMD3(0, planet.sphereRadiusForVolume + 0.015, 0)
                    planetEntity.addChild(label)
                }
            }

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
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    guard let root = findRoot(from: value.entity) else { return }
                    let delta = Float(value.translation.width - lastDragWidth) * 0.005
                    lastDragWidth = value.translation.width
                    let rotation = simd_quatf(angle: delta, axis: SIMD3(0, 1, 0))
                    root.orientation = root.orientation * rotation
                }
                .onEnded { _ in
                    lastDragWidth = 0
                }
        )
        .gesture(
            MagnifyGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    guard let root = findRoot(from: value.entity) else { return }
                    let scale = baseScale * Float(value.magnification)
                    let clampedScale = min(max(scale, 0.5), 2.0)
                    root.scale = SIMD3(repeating: clampedScale)
                }
                .onEnded { value in
                    baseScale = min(max(baseScale * Float(value.magnification), 0.5), 2.0)
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

    private func findRoot(from entity: Entity) -> Entity? {
        var current: Entity? = entity
        while let parent = current?.parent {
            if parent.name == "SolarSystemRoot" { return parent }
            current = parent
        }
        if entity.name == "SolarSystemRoot" { return entity }
        return nil
    }
}
