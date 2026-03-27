import SwiftUI

struct PlanetDetailCard: View {
    let planet: Planet

    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(planet.color)
                .frame(width: 80, height: 80)

            Text(planet.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                GridRow {
                    Text("Diameter")
                        .foregroundStyle(.secondary)
                    Text("\(Int(planet.diameter)) km")
                }
                GridRow {
                    Text("Distance from Sun")
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", planet.distanceFromSun)) million km")
                }
                GridRow {
                    Text("Orbital Period")
                        .foregroundStyle(.secondary)
                    Text("\(Int(planet.orbitalPeriod)) days")
                }
                GridRow {
                    Text("Rotation Period")
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", planet.rotationPeriod)) hours")
                }
            }
            .font(.body)

            Text(planet.funFact)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(30)
        .frame(maxWidth: 400)
    }
}
