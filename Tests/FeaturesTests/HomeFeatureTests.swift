import ComposableArchitecture
import Features
import XCTest

@MainActor
final class HomeFeatureTests: XCTestCase {
  func testInitialState() async throws {
    let store = TestStore(
      initialState: HomeFeature.State(),
      reducer: { HomeFeature() }
    )

    expectNoDifference(store.state.trips, TripsFeature.State())
  }
}
