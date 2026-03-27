import SwiftUI

struct HomeView: View {
    @Environment(SolarSystemModel.self) private var model
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        NavigationStack {
            List(Planet.allPlanets) { planet in
                Button {
                    model.selectPlanet(planet)
                } label: {
                    PlanetRow(planet: planet)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Solar Explorer")
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    Button("Explore Solar System") {
                        openWindow(id: "SolarSystemVolume")
                        model.isShowingVolume = true
                    }
                    .font(.title3)
                    .controlSize(.large)
                }
            }
            .sheet(item: Binding(
                get: { model.selectedPlanet },
                set: { planet in
                    if planet == nil { model.clearSelection() }
                }
            )) { planet in
                PlanetDetailCard(planet: planet)
            }
        }
    }
}

struct PlanetRow: View {
    let planet: Planet

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(planet.color)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(planet.name)
                    .font(.headline)
                Text("\(Int(planet.distanceFromSun)) million km from Sun")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(Int(planet.diameter)) km")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
