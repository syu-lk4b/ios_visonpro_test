import Foundation
import SwiftUI

struct Planet: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let diameter: Double          // km
    let distanceFromSun: Double   // million km
    let orbitalPeriod: Double     // Earth days
    let rotationPeriod: Double    // Earth hours
    let color: Color
    let textureName: String
    let funFact: String

    static func == (lhs: Planet, rhs: Planet) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Maps real distances to 0.08...0.45 meter range for the Volume
    var orbitRadiusForVolume: Float {
        let minDist = log(58.0)    // Mercury
        let maxDist = log(4_500.0) // Neptune
        let normalized = Float((log(distanceFromSun) - minDist) / (maxDist - minDist))
        return min(max(0.08 + normalized * 0.37, 0.08), 0.45)
    }

    // Maps real diameters to 0.005...0.05 meter range
    var sphereRadiusForVolume: Float {
        let minD = log(4_879.0)   // Mercury
        let maxD = log(139_820.0) // Jupiter
        let normalized = Float((log(diameter) - minD) / (maxD - minD))
        return min(max(0.005 + normalized * 0.045, 0.005), 0.05)
    }

    // Orbit speed for Volume (scaled so innermost ~4s per orbit)
    var orbitSpeedForVolume: Float {
        Float(4.0 / sqrt(orbitalPeriod / 88.0))
    }
}

extension Planet {
    static let allPlanets: [Planet] = [
        Planet(id: "mercury", name: "Mercury", diameter: 4_879, distanceFromSun: 57.9, orbitalPeriod: 88, rotationPeriod: 1407.6, color: .gray, textureName: "mercury_texture", funFact: "Mercury has no atmosphere and temperatures swing from -180°C to 430°C."),
        Planet(id: "venus", name: "Venus", diameter: 12_104, distanceFromSun: 108.2, orbitalPeriod: 225, rotationPeriod: 5832.5, color: .orange, textureName: "venus_texture", funFact: "Venus rotates backwards — the Sun rises in the west."),
        Planet(id: "earth", name: "Earth", diameter: 12_756, distanceFromSun: 149.6, orbitalPeriod: 365.2, rotationPeriod: 24, color: .blue, textureName: "earth_texture", funFact: "Earth is the only known planet with liquid water on its surface."),
        Planet(id: "mars", name: "Mars", diameter: 6_792, distanceFromSun: 227.9, orbitalPeriod: 687, rotationPeriod: 24.6, color: .red, textureName: "mars_texture", funFact: "Mars has the tallest volcano in the solar system — Olympus Mons at 21.9 km."),
        Planet(id: "jupiter", name: "Jupiter", diameter: 139_820, distanceFromSun: 778.6, orbitalPeriod: 4_331, rotationPeriod: 9.9, color: .brown, textureName: "jupiter_texture", funFact: "Jupiter's Great Red Spot is a storm larger than Earth that has raged for centuries."),
        Planet(id: "saturn", name: "Saturn", diameter: 116_460, distanceFromSun: 1_433.5, orbitalPeriod: 10_747, rotationPeriod: 10.7, color: .yellow, textureName: "saturn_texture", funFact: "Saturn's density is so low it would float in water."),
        Planet(id: "uranus", name: "Uranus", diameter: 50_724, distanceFromSun: 2_872.5, orbitalPeriod: 30_589, rotationPeriod: 17.2, color: .cyan, textureName: "uranus_texture", funFact: "Uranus rotates on its side, with an axial tilt of 98 degrees."),
        Planet(id: "neptune", name: "Neptune", diameter: 49_528, distanceFromSun: 4_495.1, orbitalPeriod: 59_800, rotationPeriod: 16.1, color: .indigo, textureName: "neptune_texture", funFact: "Neptune has the strongest winds in the solar system — up to 2,100 km/h."),
    ]
}
