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
