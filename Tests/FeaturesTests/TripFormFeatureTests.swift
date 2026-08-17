import ComposableArchitecture
import Features
import Models
import XCTest

@MainActor
final class TripFormFeatureTests: XCTestCase {
  func testFormValidation_emptyTitle() async throws {
    let state = TripFormFeature.State()
    expectNoDifference(state.isFormValid, false)
  }

  func testFormValidation_emptyDestination() async throws {
    var state = TripFormFeature.State()
    state.title = "旅行"
    state.destination = ""
    expectNoDifference(state.isFormValid, false)
  }

  func testFormValidation_invalidDate() async throws {
    var state = TripFormFeature.State()
    state.title = "旅行"
    state.destination = "東京"
    state.startDate = Date()
    state.endDate = Date().addingTimeInterval(-86400)
    expectNoDifference(state.isFormValid, false)
  }

  func testFormValidation_valid() async throws {
    var state = TripFormFeature.State()
    state.title = "東京之旅"
    state.destination = "日本東京"
    state.startDate = Date()
    state.endDate = Date().addingTimeInterval(86400)
    expectNoDifference(state.isFormValid, true)
  }

  func testSaveNewTrip() async throws {
    var initialState = TripFormFeature.State()
    initialState.title = "東京之旅"
    initialState.destination = "日本東京"
    initialState.startDate = Date()
    initialState.endDate = Date().addingTimeInterval(86400 * 5)

    let store = TestStore(
      initialState: initialState,
      reducer: { TripFormFeature() }
    ) {
      $0.tripPersistenceClient.add = { _ in }
    }

    await store.send(.saveButtonTapped) {
      $0.isSaving = true
    }
    await store.receive(\.delegate.tripSaved)
  }

  func testSaveInvalidFormDoesNothing() async throws {
    let store = TestStore(
      initialState: TripFormFeature.State(),
      reducer: { TripFormFeature() }
    )

    await store.send(.saveButtonTapped)
  }
}
