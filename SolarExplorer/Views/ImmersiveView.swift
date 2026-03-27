import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(SolarSystemModel.self) private var model
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        RealityView { content in
            let root = Entity()
            root.name = "ImmersiveRoot"
            content.add(root)

            let sun = await EntityFactory.makeSun(radius: 0.3)
            sun.position = SIMD3(0, 1.2, -2.0)
            root.addChild(sun)

            let light = Entity()
            light.components.set(PointLightComponent(
                color: .white,
                intensity: 10000,
                attenuationRadius: 20
            ))
            light.position = sun.position
            root.addChild(light)

            let immersiveScale: Float = 5.0
            for planet in Planet.allPlanets {
                let planetEntity = await EntityFactory.makePlanet(planet)

                guard var orbit = planetEntity.components[OrbitComponent.self] else { continue }
                orbit.radius *= immersiveScale
                planetEntity.components.set(orbit)

                // Re-create model at larger scale with texture
                let largerRadius = planet.sphereRadiusForVolume * immersiveScale
                let largerMaterial = await PlanetTextures.material(for: planet)
                planetEntity.model = ModelComponent(
                    mesh: .generateSphere(radius: largerRadius),
                    materials: [largerMaterial]
                )

                planetEntity.components.set(CollisionComponent(
                    shapes: [.generateSphere(radius: largerRadius * 1.5)]
                ))

                // Parent under orbitAnchor at sun position so OrbitSystem
                // writes positions relative to the sun, not world origin
                let orbitAnchor = Entity()
                orbitAnchor.position = sun.position
                orbitAnchor.addChild(planetEntity)
                root.addChild(orbitAnchor)

                if let ring = try? EntityFactory.makeOrbitRing(radius: orbit.radius) {
                    ring.position = sun.position
                    root.addChild(ring)
                }
            }

            let starfield = ModelEntity(
                mesh: .generateSphere(radius: 15),
                materials: [makeStarfieldMaterial()]
            )
            starfield.scale = SIMD3(-1, 1, 1)
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

                    Button(model.isFullImmersion ? "Mixed Reality" : "Full Starfield") {
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

    private func makeStarfieldMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        material.color = .init(tint: .init(white: 0.02, alpha: 1.0))
        return material
    }
}
