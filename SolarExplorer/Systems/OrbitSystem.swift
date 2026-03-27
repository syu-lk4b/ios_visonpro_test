import RealityKit

struct OrbitSystem: System {
    static let query = EntityQuery(where: .has(OrbitComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var orbit = entity.components[OrbitComponent.self] else { continue }
            orbit.angle = OrbitMath.advanceAngle(currentAngle: orbit.angle, speed: orbit.speed, deltaTime: deltaTime)
            entity.components.set(orbit)
            entity.position = OrbitMath.position(radius: orbit.radius, angle: orbit.angle)
        }
    }
}
