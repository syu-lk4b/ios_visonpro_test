import Testing
@testable import SolarExplorer

@Suite("Solar Explorer Tests")
struct SolarExplorerTests {
    @Test("App exists")
    func appExists() {
        #expect(true)
    }
}
