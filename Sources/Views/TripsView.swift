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
              TripRowView(trip: trip, now: store.now)
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
  let now: Date?

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
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

      Spacer(minLength: 0)

      if let now {
        CountdownBadge(countdown: trip.countdown(asOf: now))
      }
    }
    .padding(.vertical, 4)
  }
}

private struct CountdownBadge: View {
  let countdown: TripCountdown

  var body: some View {
    Text(label)
      .font(.caption.weight(.semibold))
      .foregroundStyle(tint)
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(tint.opacity(0.12), in: .capsule)
      .fixedSize()
      .accessibilityLabel(accessibilityLabel)
  }

  private var label: LocalizedStringKey {
    switch countdown {
    case .upcoming(let days): "還有 \(days) 天"
    case .departingToday: "今天出發"
    case .ongoing(let dayNumber, let totalDays): "第 \(dayNumber)/\(totalDays) 天"
    case .completed: "已完成"
    }
  }

  private var accessibilityLabel: Text {
    switch countdown {
    case .upcoming(let days): Text("距離出發還有 \(days) 天")
    case .departingToday: Text("今天出發")
    case .ongoing(let dayNumber, let totalDays): Text("旅程進行中，第 \(dayNumber) 天，共 \(totalDays) 天")
    case .completed: Text("旅程已完成")
    }
  }

  private var tint: Color {
    switch countdown {
    case .upcoming: .blue
    case .departingToday: .orange
    case .ongoing: .green
    case .completed: .secondary
    }
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

#Preview("All Countdown States") {
  let now = Date()
  let day: TimeInterval = 86400

  TripsListView(
    store: .init(
      initialState: {
        var state = TripsFeature.State()
        state.now = now
        state.trips = [
          Trip(
            title: "首爾美食行",
            destination: "韓國首爾",
            startDate: now.addingTimeInterval(day * 30),
            endDate: now.addingTimeInterval(day * 35)
          ),
          Trip(
            title: "東京之旅",
            destination: "日本東京",
            startDate: now,
            endDate: now.addingTimeInterval(day * 5)
          ),
          Trip(
            title: "京都賞楓",
            destination: "日本京都",
            startDate: now.addingTimeInterval(-day * 2),
            endDate: now.addingTimeInterval(day * 3)
          ),
          Trip(
            title: "沖繩跳島",
            destination: "日本沖繩",
            startDate: now.addingTimeInterval(-day * 20),
            endDate: now.addingTimeInterval(-day * 14)
          ),
        ]
        return state
      }(),
      reducer: { TripsFeature() }
    )
  )
}
