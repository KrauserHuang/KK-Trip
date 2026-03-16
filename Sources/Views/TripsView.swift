import ComposableArchitecture
import Features
import Models
import SwiftUI

package struct TripsListView: View {
  @Bindable package var store: StoreOf<TripsFeature>

  package init(store: StoreOf<TripsFeature>) {
    self.store = store
  }

  package var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      Group {
        if store.trips.isEmpty {
          ContentUnavailableView(
            "沒有旅行計劃",
            systemImage: "airplane.departure",
            description: Text("點擊右上角的 + 開始規劃你的旅程")
          )
        } else {
          List {
            ForEach(store.trips) { trip in
              TripRowView(trip: trip)
            }
            .onDelete { indexSet in
              for index in indexSet {
                store.send(.deleteTrip(store.trips[index].id))
              }
            }
          }
        }
      }
      .navigationTitle("旅行計劃")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            store.send(.addButtonTapped)
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    } destination: { store in
      switch store.case {
      case .tripForm(let formStore):
        TripFormView(store: formStore)
      }
    }
    .task {
      await store.send(.task).finish()
    }
  }
}

private struct TripRowView: View {
  let trip: Trip

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(trip.title)
        .font(.headline)
      Text(trip.destination)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      HStack {
        Text(trip.startDate, format: .dateTime.year().month().day())
        Text("–")
        Text(trip.endDate, format: .dateTime.year().month().day())
      }
      .font(.caption)
      .foregroundStyle(.tertiary)
    }
    .padding(.vertical, 4)
  }
}

#Preview("Empty") {
  TripsListView(
    store: .init(
      initialState: TripsFeature.State(),
      reducer: { TripsFeature() }
    )
  )
}

#Preview("With Trips") {
  TripsListView(
    store: .init(
      initialState: {
        var state = TripsFeature.State()
        state.trips = [
          Trip(
            title: "東京之旅",
            destination: "日本東京",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 5)
          ),
          Trip(
            title: "首爾美食行",
            destination: "韓國首爾",
            startDate: Date().addingTimeInterval(86400 * 30),
            endDate: Date().addingTimeInterval(86400 * 35)
          ),
        ]
        return state
      }(),
      reducer: { TripsFeature() }
    )
  )
}
