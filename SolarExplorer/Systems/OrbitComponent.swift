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

enum OrbitMath {
    static func position(radius: Float, angle: Float) -> SIMD3<Float> {
        SIMD3(radius * cos(angle), 0, radius * sin(angle))
    }

    static func advanceAngle(currentAngle: Float, speed: Float, deltaTime: Float) -> Float {
        let newAngle = currentAngle + speed * deltaTime
        let twoPi = 2.0 * Float.pi
        return newAngle.truncatingRemainder(dividingBy: twoPi)
    }
}
