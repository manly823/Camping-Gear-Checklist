import SwiftUI
import Charts

struct FoodCalcView: View {
    @EnvironmentObject var mgr: CampingManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        summaryCards
                        calorieBreakdown
                        waterSection
                        mealTips
                    }.padding()
                }
            }
            .navigationTitle("Food Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } } }
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 10) {
            statBox("Total Cal", "\(mgr.totalCalories())", "flame.fill", Theme.campfire)
            statBox("Food Wt", String(format: "%.1fkg", mgr.totalFoodWeightKg()), "scalemass.fill", Theme.earth)
            statBox("Water", String(format: "%.0fL", mgr.totalWaterLiters()), "drop.fill", Theme.sky)
        }
    }

    private func statBox(_ label: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(color)
            Text(value).font(.title3.bold()).foregroundColor(.white)
            Text(label).font(.caption2).foregroundColor(Theme.textSecondary)
        }.frame(maxWidth: .infinity).cardStyle()
    }

    private var calorieBreakdown: some View {
        let meals: [(String, Double, Color)] = [
            ("Breakfast", 0.25, Color(red: 0.95, green: 0.7, blue: 0.2)),
            ("Lunch", 0.30, Theme.forest),
            ("Dinner", 0.35, Theme.campfire),
            ("Snacks", 0.10, Theme.earth),
        ]
        return VStack(alignment: .leading, spacing: 10) {
            Text("Daily Breakdown").font(.subheadline.bold()).foregroundColor(.white)
            Text("Per person · \(mgr.settings.caloriesPerDay) cal/day").font(.caption2).foregroundColor(Theme.textSecondary)
            Chart(meals, id: \.0) { meal in
                SectorMark(angle: .value("Cal", meal.1), innerRadius: .ratio(0.5), angularInset: 2)
                    .foregroundStyle(meal.2).cornerRadius(4)
            }.frame(height: 180)
            ForEach(meals, id: \.0) { m in
                HStack(spacing: 8) {
                    Circle().fill(m.2).frame(width: 8, height: 8)
                    Text(m.0).font(.caption).foregroundColor(.white)
                    Spacer()
                    Text("\(Int(Double(mgr.settings.caloriesPerDay) * m.1)) cal").font(.caption.bold()).foregroundColor(Theme.textSecondary)
                }
            }
        }.cardStyle()
    }

    private var waterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Water Requirements").font(.subheadline.bold()).foregroundColor(.white)
            let days = mgr.trip.durationDays
            let group = mgr.trip.groupSize
            Chart(1...days, id: \.self) { day in
                BarMark(x: .value("Day", "Day \(day)"), y: .value("L", mgr.waterLitersPerDay() * Double(group)))
                    .foregroundStyle(Theme.sky.gradient).cornerRadius(4)
            }
            .chartYAxisLabel("Liters").frame(height: 140)
            .chartXAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary) } }
            .chartYAxis { AxisMarks { _ in AxisValueLabel().foregroundStyle(Theme.textSecondary); AxisGridLine().foregroundStyle(Color.white.opacity(0.05)) } }
            HStack {
                Text("3L per person per day").font(.caption2).foregroundColor(Theme.textSecondary)
                Spacer()
                Text(String(format: "Total: %.0fL (%.1fkg)", mgr.totalWaterLiters(), mgr.totalWaterLiters())).font(.caption2.bold()).foregroundColor(Theme.sky)
            }
        }.cardStyle()
    }

    private var mealTips: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) { Image(systemName: "lightbulb.fill").foregroundColor(Theme.campfire); Text("Packing Tips").font(.subheadline.bold()).foregroundColor(.white) }
            tip("Dehydrated meals save weight (~125g per meal)")
            tip("Pack 10% extra calories for cold weather trips")
            tip("Nuts and trail mix: 600 cal per 100g — best ratio")
            tip("Pre-portion meals into daily bags to stay organized")
            tip("Carry water purification tablets as backup")
        }.cardStyle()
    }

    private func tip(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle().fill(Theme.textSecondary).frame(width: 4, height: 4).padding(.top, 6)
            Text(text).font(.caption).foregroundColor(Theme.textSecondary)
        }
    }
}
