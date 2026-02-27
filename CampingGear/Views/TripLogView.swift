import SwiftUI

struct TripLogView: View {
    @EnvironmentObject var mgr: CampingManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                if mgr.tripLog.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book").font(.system(size: 40)).foregroundColor(Theme.textSecondary)
                        Text("No trips yet").foregroundColor(Theme.textSecondary)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(mgr.tripLog) { trip in tripCard(trip) }
                        }.padding()
                    }
                }
            }
            .navigationTitle("Trip Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } } }
        }
    }

    private func tripCard(_ trip: Trip) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(trip.tripType.color.opacity(0.15)).frame(width: 48, height: 48)
                Image(systemName: trip.tripType.icon).foregroundColor(trip.tripType.color).font(.title3)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name).font(.subheadline.bold()).foregroundColor(.white)
                HStack(spacing: 8) {
                    if !trip.location.isEmpty { Label(trip.location, systemImage: "mappin").font(.caption2) }
                    Label("\(trip.durationDays) days", systemImage: "calendar").font(.caption2)
                    Label("\(trip.groupSize)", systemImage: "person.2").font(.caption2)
                }.foregroundColor(Theme.textSecondary)
            }
            Spacer()
            Text(trip.date, style: .date).font(.caption2).foregroundColor(Theme.textSecondary)
        }.cardStyle()
    }
}
