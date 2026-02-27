import SwiftUI

struct MainView: View {
    @EnvironmentObject var mgr: CampingManager
    @State private var activeSheet: Dest?

    enum Dest: String, Identifiable {
        case checklist, addGear, foodCalc, weight, knots, tripLog, settings
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            Theme.bgGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    tripHeader
                    packProgress
                    hexGrid
                    quickStats
                }.padding()
            }
        }
        .sheet(item: $activeSheet) { d in sheetFor(d) }
    }

    // MARK: - Trip Header with Mountain
    private var tripHeader: some View {
        ZStack(alignment: .bottom) {
            MountainRange().fill(mgr.trip.tripType.color.opacity(0.08)).frame(height: 80)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mgr.trip.name).font(.title3.bold()).foregroundColor(.white)
                    HStack(spacing: 8) {
                        Label("\(mgr.trip.durationDays)d", systemImage: "calendar").font(.caption)
                        Label("\(mgr.trip.groupSize)", systemImage: "person.2").font(.caption)
                        Label(mgr.trip.tripType.rawValue, systemImage: mgr.trip.tripType.icon).font(.caption)
                    }.foregroundColor(Theme.textSecondary)
                }
                Spacer()
                Button { activeSheet = .settings } label: {
                    Image(systemName: "gearshape.fill").font(.title3).foregroundColor(Theme.textSecondary)
                }
            }
        }.cardStyle()
    }

    // MARK: - Pack Progress
    private var packProgress: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Packing Progress").font(.subheadline.bold()).foregroundColor(.white)
                Spacer()
                Text("\(mgr.packedCount)/\(mgr.gear.count)").font(.caption.bold()).foregroundColor(Theme.forest)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.07)).frame(height: 10)
                    RoundedRectangle(cornerRadius: 6).fill(Theme.forest).frame(width: geo.size.width * mgr.packProgress, height: 10)
                }
            }.frame(height: 10)
            HStack {
                Label("\(mgr.essentialPacked)/\(mgr.essentialCount) essentials", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption2).foregroundColor(mgr.essentialPacked == mgr.essentialCount ? Theme.forest : Theme.campfire)
                Spacer()
                Text(String(format: "%.1f kg total", Double(mgr.totalWeight) / 1000)).font(.caption2).foregroundColor(Theme.textSecondary)
            }
        }.cardStyle()
    }

    // MARK: - Hexagon Grid (NOT circles, NOT arc gauges — hexagons!)
    private var hexGrid: some View {
        VStack(spacing: 6) {
            HStack { Text("Sections").font(.headline).foregroundColor(.white); Spacer() }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                HexTile(icon: "checklist.checked", label: "Checklist", value: "\(mgr.packedCount) packed", color: Theme.forest) { activeSheet = .checklist }
                HexTile(icon: "plus.circle", label: "Add Gear", value: "\(mgr.gear.count) items", color: Theme.campfire) { activeSheet = .addGear }
                HexTile(icon: "scalemass.fill", label: "Weight", value: formatWeight(mgr.totalWeight), color: Theme.sky) { activeSheet = .weight }
                HexTile(icon: "fork.knife", label: "Food Calc", value: "\(mgr.totalCalories()) cal", color: Theme.earth) { activeSheet = .foodCalc }
                HexTile(icon: "point.topleft.down.to.point.bottomright.curvepath.fill", label: "Knots", value: "\(CampingManager.knots.count) knots", color: Theme.snow) { activeSheet = .knots }
                HexTile(icon: "book.fill", label: "Trip Log", value: "\(mgr.tripLog.count) trips", color: Theme.textSecondary) { activeSheet = .tripLog }
            }
        }
    }

    // MARK: - Quick Stats (category overview)
    private var quickStats: some View {
        VStack(spacing: 8) {
            HStack { Text("By Category").font(.subheadline.bold()).foregroundColor(.white); Spacer() }
            ForEach(GearCategory.allCases) { cat in
                let items = mgr.itemsFor(cat)
                if !items.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: cat.icon).foregroundColor(cat.color).frame(width: 20)
                        Text(cat.rawValue).font(.caption).foregroundColor(.white)
                        Spacer()
                        Text("\(mgr.packedFor(cat))/\(items.count)").font(.caption2).foregroundColor(Theme.textSecondary)
                        Text(formatWeight(mgr.weightFor(cat))).font(.caption2.bold()).foregroundColor(cat.color).frame(width: 50, alignment: .trailing)
                    }
                }
            }
        }.cardStyle()
    }

    private func formatWeight(_ g: Int) -> String { g >= 1000 ? String(format: "%.1fkg", Double(g)/1000) : "\(g)g" }

    @ViewBuilder
    private func sheetFor(_ d: Dest) -> some View {
        switch d {
        case .checklist: ChecklistView().environmentObject(mgr)
        case .addGear: AddGearView().environmentObject(mgr)
        case .foodCalc: FoodCalcView().environmentObject(mgr)
        case .weight: WeightView().environmentObject(mgr)
        case .knots: KnotGuideView()
        case .tripLog: TripLogView().environmentObject(mgr)
        case .settings: SettingsView().environmentObject(mgr)
        }
    }
}
