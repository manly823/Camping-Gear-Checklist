import SwiftUI
import Charts

struct WeightView: View {
    @EnvironmentObject var mgr: CampingManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        weightSummary
                        pieChart
                        categoryBars
                        weightTips
                    }.padding()
                }
            }
            .navigationTitle("Weight Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } } }
        }
    }

    private var weightSummary: some View {
        HStack(spacing: 10) {
            VStack(spacing: 4) {
                Text("Total").font(.caption2).foregroundColor(Theme.textSecondary)
                Text(String(format: "%.1f kg", Double(mgr.totalWeight) / 1000)).font(.title2.bold()).foregroundColor(.white)
            }.frame(maxWidth: .infinity)
            Divider().frame(height: 40).background(Color.white.opacity(0.1))
            VStack(spacing: 4) {
                Text("Packed").font(.caption2).foregroundColor(Theme.textSecondary)
                Text(String(format: "%.1f kg", Double(mgr.packedWeight) / 1000)).font(.title2.bold()).foregroundColor(Theme.forest)
            }.frame(maxWidth: .infinity)
            Divider().frame(height: 40).background(Color.white.opacity(0.1))
            VStack(spacing: 4) {
                Text("Items").font(.caption2).foregroundColor(Theme.textSecondary)
                Text("\(mgr.gear.count)").font(.title2.bold()).foregroundColor(Theme.campfire)
            }.frame(maxWidth: .infinity)
        }.cardStyle()
    }

    private var pieChart: some View {
        let data = mgr.weightByCategory()
        return VStack(alignment: .leading, spacing: 10) {
            Text("Weight by Category").font(.subheadline.bold()).foregroundColor(.white)
            if data.isEmpty {
                Text("No data").foregroundColor(Theme.textSecondary)
            } else {
                Chart(data, id: \.cat) { item in
                    SectorMark(angle: .value("Weight", item.weight), innerRadius: .ratio(0.5), angularInset: 2)
                        .foregroundStyle(item.cat.color).cornerRadius(4)
                }.frame(height: 200)
                ForEach(data, id: \.cat) { item in
                    HStack(spacing: 8) {
                        ZStack {
                            HexagonShape().fill(item.cat.color.opacity(0.2)).frame(width: 18, height: 18)
                            Image(systemName: item.cat.icon).font(.system(size: 8)).foregroundColor(item.cat.color)
                        }
                        Text(item.cat.rawValue).font(.caption).foregroundColor(.white)
                        Spacer()
                        Text(fmt(item.weight)).font(.caption.bold()).foregroundColor(Theme.textSecondary)
                        Text(pct(item.weight)).font(.caption2).foregroundColor(item.cat.color).frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }.cardStyle()
    }

    private var categoryBars: some View {
        let data = mgr.weightByCategory()
        let maxW = data.map(\.weight).max() ?? 1
        return VStack(alignment: .leading, spacing: 10) {
            Text("Category Comparison").font(.subheadline.bold()).foregroundColor(.white)
            ForEach(data, id: \.cat) { item in
                VStack(alignment: .leading, spacing: 3) {
                    HStack { Text(item.cat.rawValue).font(.caption).foregroundColor(.white); Spacer(); Text(fmt(item.weight)).font(.caption2).foregroundColor(Theme.textSecondary) }
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4).fill(item.cat.color.opacity(0.3))
                            .frame(width: geo.size.width * Double(item.weight) / Double(maxW), height: 8)
                    }.frame(height: 8)
                }
            }
        }.cardStyle()
    }

    private var weightTips: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) { Image(systemName: "lightbulb.fill").foregroundColor(Theme.campfire); Text("Weight Tips").font(.subheadline.bold()).foregroundColor(.white) }
            tipRow("Ultralight target", "< 5 kg base weight")
            tipRow("Lightweight target", "5–8 kg base weight")
            tipRow("Traditional", "8–15 kg base weight")
            tipRow("Big 3 focus", "Tent + Bag + Pad = 50% of weight")
            tipRow("Cut weight by", "Sharing gear between group members")
        }.cardStyle()
    }

    private func tipRow(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(Theme.forest).frame(width: 4, height: 4).padding(.top, 6)
            Text(title).font(.caption.bold()).foregroundColor(.white) + Text(" — \(detail)").font(.caption).foregroundColor(Theme.textSecondary)
        }
    }

    private func fmt(_ g: Int) -> String { g >= 1000 ? String(format: "%.1fkg", Double(g)/1000) : "\(g)g" }
    private func pct(_ g: Int) -> String { mgr.totalWeight > 0 ? "\(g * 100 / mgr.totalWeight)%" : "—" }
}
