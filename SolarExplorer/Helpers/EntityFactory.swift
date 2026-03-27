import RealityKit
import SwiftUI

@MainActor
enum EntityFactory {

    static func makeSun(radius: Float = 0.04) async -> ModelEntity {
        let material = await PlanetTextures.sunMaterial()

        let sun = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [material]
        )
        sun.name = "Sun"
        sun.components.set(RotationComponent(speed: 0.2, axis: SIMD3(0, 1, 0)))

        let corona = makeSunCorona(sunRadius: radius)
        sun.addChild(corona)

        return sun
    }

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

    static func makeOrbitRing(radius: Float) throws -> ModelEntity {
        let mesh = try generateTorusMesh(
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
