import ComposableArchitecture
import Features
import XCTest

@MainActor
final class AppFeatureTests: XCTestCase {
  func testInitialState() async throws {
    let store = TestStore(
      initialState: AppFeature.State(),
      reducer: {
        AppFeature()
      }
    )

    expectNoDifference(store.state.home, HomeFeature.State())
  }
}
