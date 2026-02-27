import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var mgr: CampingManager
    @Environment(\.dismiss) var dismiss
    @State private var tripName: String = ""
    @State private var location: String = ""
    @State private var days: String = ""
    @State private var group: String = ""
    @State private var calories: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        tripSection
                        prefsSection
                        exportSection
                        resetSection
                    }.padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Done") { save(); dismiss() } } }
            .onAppear {
                tripName = mgr.trip.name; location = mgr.trip.location
                days = "\(mgr.trip.durationDays)"; group = "\(mgr.trip.groupSize)"
                calories = "\(mgr.settings.caloriesPerDay)"
            }
        }
    }

    private var tripSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            secHeader("Current Trip", icon: "tent.fill")
            field("Trip Name", text: $tripName)
            field("Location", text: $location)
            HStack(spacing: 10) { field("Days", text: $days, kb: .numberPad); field("Group", text: $group, kb: .numberPad) }
            VStack(alignment: .leading, spacing: 6) {
                Text("Trip Type").font(.caption).foregroundColor(Theme.textSecondary)
                Picker("", selection: $mgr.trip.tripType) {
                    ForEach(TripType.allCases) { t in Label(t.rawValue, systemImage: t.icon).tag(t) }
                }.pickerStyle(.menu).tint(Theme.forest)
            }
        }.cardStyle()
    }

    private var prefsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            secHeader("Preferences", icon: "slider.horizontal.3")
            field("Calories per day", text: $calories, kb: .numberPad)
            VStack(alignment: .leading, spacing: 6) {
                Text("Experience Level").font(.caption).foregroundColor(Theme.textSecondary)
                Picker("", selection: $mgr.settings.experienceLevel) {
                    Text("Beginner").tag("Beginner"); Text("Intermediate").tag("Intermediate"); Text("Expert").tag("Expert")
                }.pickerStyle(.segmented)
            }
        }.cardStyle()
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            secHeader("Data", icon: "square.and.arrow.up")
            ShareLink(item: mgr.exportJSON()) {
                HStack {
                    Image(systemName: "doc.text").foregroundColor(Theme.forest)
                    Text("Export All Data (JSON)").font(.subheadline).foregroundColor(.white)
                    Spacer(); Image(systemName: "chevron.right").foregroundColor(Theme.textSecondary)
                }
            }
        }.cardStyle()
    }

    private var resetSection: some View {
        Button { mgr.settings.hasCompletedOnboarding = false } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise").foregroundColor(Theme.danger)
                Text("Show Onboarding Again").font(.subheadline).foregroundColor(Theme.danger)
                Spacer()
            }
        }.cardStyle()
    }

    private func secHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) { Image(systemName: icon).foregroundColor(Theme.forest); Text(title).font(.subheadline.bold()).foregroundColor(.white) }
    }

    private func field(_ label: String, text: Binding<String>, kb: UIKeyboardType = .default) -> some View {
        HStack {
            Text(label).font(.caption).foregroundColor(Theme.textSecondary).frame(width: 110, alignment: .leading)
            TextField(label, text: text).foregroundColor(.white).keyboardType(kb)
        }
    }

    private func save() {
        mgr.trip.name = tripName; mgr.trip.location = location
        mgr.trip.durationDays = Int(days) ?? mgr.trip.durationDays
        mgr.trip.groupSize = Int(group) ?? mgr.trip.groupSize
        mgr.settings.caloriesPerDay = Int(calories) ?? mgr.settings.caloriesPerDay
    }
}
