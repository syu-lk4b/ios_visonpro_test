import RealityKit
import SwiftUI

@MainActor
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
            return SimpleMaterial(
                color: UIColor(planet.color),
                isMetallic: false
            )
        }
    }

    /// Loads a sun texture as UnlitMaterial, falls back to yellow
    static func sunMaterial() async -> any RealityKit.Material {
        do {
            let texture = try await TextureResource(named: "sun_texture")
            var material = UnlitMaterial()
            material.color = .init(texture: .init(texture))
            return material
        } catch {
            var material = UnlitMaterial()
            material.color = .init(tint: .init(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0))
            return material
        }
    }
}
