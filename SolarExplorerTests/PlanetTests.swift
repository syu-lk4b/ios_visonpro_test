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
        #expect(mercury.orbitRadiusForVolume < neptune.orbitRadiusForVolume)
        for planet in Planet.allPlanets {
            #expect(planet.orbitRadiusForVolume <= 0.45, "\(planet.name) orbit too large: \(planet.orbitRadiusForVolume)")
        }
    }

    @Test("Planet sphere radius scales correctly for Volume display")
    func sphereRadiusScale() {
        let jupiter = Planet.allPlanets.first(where: { $0.name == "Jupiter" })!
        let mercury = Planet.allPlanets.first(where: { $0.name == "Mercury" })!
        #expect(jupiter.sphereRadiusForVolume > mercury.sphereRadiusForVolume)
        for planet in Planet.allPlanets {
            #expect(planet.sphereRadiusForVolume >= 0.005, "\(planet.name) too small: \(planet.sphereRadiusForVolume)")
            #expect(planet.sphereRadiusForVolume <= 0.05, "\(planet.name) too large: \(planet.sphereRadiusForVolume)")
        }
    }
}
