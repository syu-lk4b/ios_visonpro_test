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
        let newAngle = OrbitMath.advanceAngle(currentAngle: 1.0, speed: 2.0, deltaTime: 0.5)
        #expect(abs(newAngle - 2.0) < 0.001)
    }

    @Test("Angle wraps around 2*pi")
    func angleWrapping() {
        let newAngle = OrbitMath.advanceAngle(currentAngle: 6.0, speed: 1.0, deltaTime: 1.0)
        #expect(newAngle >= 0)
        #expect(newAngle < 2 * .pi)
    }
}
