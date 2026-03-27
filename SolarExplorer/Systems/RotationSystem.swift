import RealityKit
import simd

struct RotationSystem: System {
    static let query = EntityQuery(where: .has(RotationComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let rotation = entity.components[RotationComponent.self] else { continue }
            let angle = rotation.speed * deltaTime
            let increment = simd_quatf(angle: angle, axis: rotation.axis)
            entity.orientation = simd_normalize(entity.orientation * increment)
        }
    }
}
