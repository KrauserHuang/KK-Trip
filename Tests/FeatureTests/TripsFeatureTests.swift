import ComposableArchitecture
import Features
import Models
import XCTest

@MainActor
final class TripsFeatureTests: XCTestCase {
  func testTaskLoadsTrips() async throws {
    let trips = [
      Trip(
        title: "東京之旅",
        destination: "日本東京",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 5)
      )
    ]

    let store = TestStore(
      initialState: TripsFeature.State(),
      reducer: { TripsFeature() }
    ) {
      $0.tripPersistenceClient.fetchAll = { trips }
    }

    await store.send(.task)
    await store.receive(\.tripsLoaded) {
      $0.trips = trips
    }
  }

  func testAddButtonTappedPushesForm() async throws {
    let now = Date()
    let store = TestStore(
      initialState: TripsFeature.State(),
      reducer: { TripsFeature() }
    ) {
      $0.date = .constant(now)
    }

    await store.send(.addButtonTapped) {
      $0.path.append(
        .tripForm(
          TripFormFeature.State(
            startDate: now,
            endDate: now.addingTimeInterval(86400)
          )
        )
      )
    }
  }

  func testDeleteTripReloads() async throws {
    let trip = Trip(
      title: "東京之旅",
      destination: "日本東京",
      startDate: Date(),
      endDate: Date().addingTimeInterval(86400 * 5)
    )

    let store = TestStore(
      initialState: {
        var state = TripsFeature.State()
        state.trips = [trip]
        return state
      }(),
      reducer: { TripsFeature() }
    ) {
      $0.tripPersistenceClient.delete = { _ in }
      $0.tripPersistenceClient.fetchAll = { [] }
    }

    await store.send(.deleteTrip(trip.id))
    await store.receive(\.tripDeleted)
    await store.receive(\.tripsLoaded) {
      $0.trips = []
    }
  }
}
