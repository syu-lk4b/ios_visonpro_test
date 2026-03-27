import SwiftUI
import Observation

@MainActor
@Observable
final class SolarSystemModel {
    var selectedPlanet: Planet?
    var isShowingVolume: Bool = false
    var isShowingImmersive: Bool = false
    var isFullImmersion: Bool = false

    func selectPlanet(_ planet: Planet) {
        selectedPlanet = planet
    }

    func clearSelection() {
        selectedPlanet = nil
    }

    func toggleImmersionStyle() {
        isFullImmersion.toggle()
    }

    var immersionStyle: ImmersionStyle {
        isFullImmersion ? .full : .mixed
    }
}
