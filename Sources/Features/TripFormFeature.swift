import ComposableArchitecture
import DependencyClients
import Foundation
import Models

@Reducer
package struct TripFormFeature {
  @ObservableState
  package struct State: Equatable {
    package var title: String = ""
    package var destination: String = ""
    package var startDate: Date = Date()
    package var endDate: Date = Date().addingTimeInterval(86400)
    package var note: String = ""
    package var editingTrip: Trip?
    package var isSaving: Bool = false

    package var isEditing: Bool { editingTrip != nil }

    package var isFormValid: Bool {
      !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && endDate > startDate
    }

    package init(
      startDate: Date = Date(),
      endDate: Date? = nil
    ) {
      self.startDate = startDate
      self.endDate = endDate ?? startDate.addingTimeInterval(86400)
    }

    package init(trip: Trip) {
      self.editingTrip = trip
      self.title = trip.title
      self.destination = trip.destination
      self.startDate = trip.startDate
      self.endDate = trip.endDate
      self.note = trip.note
    }
  }

  @CasePathable
  package enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case saveButtonTapped
    case saveFailed
    case delegate(Delegate)

    @CasePathable
    package enum Delegate: Equatable {
      case tripSaved
    }
  }

  package init() {}

  package var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce(core)
  }

  package func core(
    into state: inout State, action: Action
  ) -> Effect<Action> {
    switch action {
    case .binding:
      return .none

    case .saveButtonTapped:
      guard state.isFormValid else { return .none }
      state.isSaving = true

      let title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)
      let destination = state.destination.trimmingCharacters(
        in: .whitespacesAndNewlines)
      let startDate = state.startDate
      let endDate = state.endDate
      let note = state.note
      let editingTrip = state.editingTrip

      return .run { send in
        @Dependency(\.tripPersistenceClient) var client

        if var existing = editingTrip {
          existing.title = title
          existing.destination = destination
          existing.startDate = startDate
          existing.endDate = endDate
          existing.note = note
          existing.updatedAt = Date()
          try await client.update(existing)
        } else {
          let trip = Trip(
            title: title,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            note: note
          )
          try await client.add(trip)
        }
        await send(.delegate(.tripSaved))
      } catch: { _, send in
        await send(.saveFailed)
      }

    case .saveFailed:
      state.isSaving = false
      return .none

    case .delegate:
      return .none
    }
  }
}
