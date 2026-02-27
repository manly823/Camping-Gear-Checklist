import SwiftUI

@MainActor
final class CampingManager: ObservableObject {
    @Published var trip: Trip { didSet { Storage.shared.save(trip, forKey: "trip") } }
    @Published var gear: [GearItem] { didSet { Storage.shared.save(gear, forKey: "gear") } }
    @Published var tripLog: [Trip] { didSet { Storage.shared.save(tripLog, forKey: "tripLog") } }
    @Published var settings: CampingSettings { didSet { Storage.shared.save(settings, forKey: "settings") } }

    init() {
        self.trip = Storage.shared.load(forKey: "trip", default: Trip())
        self.gear = Storage.shared.load(forKey: "gear", default: [])
        self.tripLog = Storage.shared.load(forKey: "tripLog", default: [])
        self.settings = Storage.shared.load(forKey: "settings", default: CampingSettings())
    }

    func setupTrip(_ t: Trip) {
        trip = t
        gear = generateGear(for: t)
        tripLog = [t]
    }

    // MARK: - CRUD
    func addGear(_ g: GearItem) { gear.append(g) }
    func deleteGear(_ g: GearItem) { gear.removeAll { $0.id == g.id } }
    func togglePacked(_ g: GearItem) {
        if let i = gear.firstIndex(where: { $0.id == g.id }) { gear[i].packed.toggle() }
    }
    func addTrip(_ t: Trip) { tripLog.insert(t, at: 0) }
    func deleteTrip(_ t: Trip) { tripLog.removeAll { $0.id == t.id } }

    // MARK: - Stats
    var totalWeight: Int { gear.reduce(0) { $0 + $1.weightGrams } }
    var packedWeight: Int { gear.filter { $0.packed }.reduce(0) { $0 + $1.weightGrams } }
    var packedCount: Int { gear.filter { $0.packed }.count }
    var essentialCount: Int { gear.filter { $0.essential }.count }
    var essentialPacked: Int { gear.filter { $0.essential && $0.packed }.count }
    var packProgress: Double { gear.isEmpty ? 0 : Double(packedCount) / Double(gear.count) }

    func itemsFor(_ cat: GearCategory) -> [GearItem] { gear.filter { $0.category == cat } }
    func packedFor(_ cat: GearCategory) -> Int { itemsFor(cat).filter { $0.packed }.count }
    func weightFor(_ cat: GearCategory) -> Int { itemsFor(cat).reduce(0) { $0 + $1.weightGrams } }

    func weightByCategory() -> [(cat: GearCategory, weight: Int)] {
        GearCategory.allCases.map { ($0, weightFor($0)) }.filter { $0.1 > 0 }.sorted { $0.1 > $1.1 }
    }

    // MARK: - Food Calculator
    func totalCalories() -> Int { settings.caloriesPerDay * trip.groupSize * trip.durationDays }
    func totalFoodWeightKg() -> Double { Double(totalCalories()) / 1250.0 }
    func waterLitersPerDay() -> Double { 3.0 }
    func totalWaterLiters() -> Double { waterLitersPerDay() * Double(trip.groupSize) * Double(trip.durationDays) }

    // MARK: - Export
    func exportJSON() -> String {
        struct Export: Codable { let trip: Trip; let gear: [GearItem]; let log: [Trip] }
        let e = Export(trip: trip, gear: gear, log: tripLog)
        guard let d = try? JSONEncoder().encode(e), let s = String(data: d, encoding: .utf8) else { return "{}" }
        return s
    }

    // MARK: - Knot Reference
    static let knots: [KnotInfo] = [
        KnotInfo(name: "Bowline", use: "Rescue, anchoring tent lines", difficulty: "Easy",
                 steps: ["Make a small loop in the rope", "Pass the end up through the loop", "Wrap around the standing line", "Pass back down through the loop", "Tighten by pulling the standing line"]),
        KnotInfo(name: "Clove Hitch", use: "Securing rope to poles or stakes", difficulty: "Easy",
                 steps: ["Wrap rope around the pole", "Cross over the standing line", "Wrap around the pole again", "Tuck under the last wrap", "Pull both ends to tighten"]),
        KnotInfo(name: "Taut-line Hitch", use: "Adjustable tent guy lines", difficulty: "Medium",
                 steps: ["Wrap around the stake", "Make two loops inside the main loop", "Wrap once more outside", "Pass through the outer loop", "Slide to adjust tension"]),
        KnotInfo(name: "Figure Eight", use: "Stopper knot, climbing safety", difficulty: "Easy",
                 steps: ["Make a loop in the rope", "Pass the end around the standing line", "Thread through the original loop", "Pull tight to form figure 8 shape"]),
        KnotInfo(name: "Sheet Bend", use: "Joining two ropes of different thickness", difficulty: "Medium",
                 steps: ["Make a bight in the thicker rope", "Pass thin rope up through the bight", "Wrap around both sides of the bight", "Tuck under itself", "Pull all four ends to tighten"]),
        KnotInfo(name: "Trucker's Hitch", use: "Securing heavy loads, tarp ridgeline", difficulty: "Hard",
                 steps: ["Tie a loop in the standing line", "Pass end around anchor point", "Thread through the loop", "Pull tight for mechanical advantage", "Secure with two half hitches"]),
        KnotInfo(name: "Prusik Knot", use: "Ascending a rope, adjustable grip", difficulty: "Medium",
                 steps: ["Make a loop from cord", "Wrap loop around main rope 3 times", "Pass loop through itself", "Dress the wraps neatly", "Grips when loaded, slides when free"]),
        KnotInfo(name: "Square Knot", use: "Joining two ropes of equal size", difficulty: "Easy",
                 steps: ["Right over left, tuck under", "Left over right, tuck under", "Pull both ends to tighten", "Should lay flat when correct"]),
    ]

    // MARK: - Smart Sample Data
    private func generateGear(for t: Trip) -> [GearItem] {
        var items: [GearItem] = []
        let base: [(String, GearCategory, Int, Bool)] = [
            ("Tent", .shelter, 2200, true), ("Groundsheet", .shelter, 300, false), ("Tarp", .shelter, 450, false),
            ("Sleeping Bag", .sleep, 1100, true), ("Sleeping Pad", .sleep, 500, true), ("Pillow", .sleep, 180, false),
            ("Stove", .cooking, 350, true), ("Pot Set", .cooking, 400, true), ("Lighter", .cooking, 20, true), ("Spork", .cooking, 18, false), ("Water Filter", .water, 300, true), ("Water Bottles 2L", .water, 200, true),
            ("Rain Jacket", .clothing, 350, true), ("Fleece", .clothing, 400, true), ("Hiking Boots", .clothing, 900, true), ("Extra Socks ×3", .clothing, 180, false), ("Hat", .clothing, 80, false),
            ("Map", .navigation, 50, true), ("Compass", .navigation, 60, true), ("Headlamp", .navigation, 90, true),
            ("First Aid Kit", .safety, 400, true), ("Whistle", .safety, 10, true), ("Emergency Blanket", .safety, 80, true),
            ("Sunscreen", .hygiene, 100, false), ("Toothbrush", .hygiene, 20, false), ("Soap", .hygiene, 50, false), ("Towel", .hygiene, 150, false),
            ("Knife", .tools, 120, true), ("Paracord 15m", .tools, 100, true), ("Duct Tape", .tools, 60, false),
        ]
        for (name, cat, w, ess) in base { items.append(GearItem(name: name, category: cat, weightGrams: w, packed: Bool.random(), essential: ess)) }

        switch t.tripType {
        case .winter:
            items.append(GearItem(name: "4-Season Tent", category: .shelter, weightGrams: 3200, essential: true))
            items.append(GearItem(name: "Down Jacket", category: .clothing, weightGrams: 600, essential: true))
            items.append(GearItem(name: "Hand Warmers ×4", category: .clothing, weightGrams: 40))
            items.append(GearItem(name: "Thermos 1L", category: .cooking, weightGrams: 450, essential: true))
        case .mountain:
            items.append(GearItem(name: "Trekking Poles", category: .tools, weightGrams: 500, essential: true))
            items.append(GearItem(name: "Gaiters", category: .clothing, weightGrams: 200))
            items.append(GearItem(name: "Altitude Sickness Pills", category: .safety, weightGrams: 30))
        case .lake, .beach:
            items.append(GearItem(name: "Swimwear", category: .clothing, weightGrams: 150))
            items.append(GearItem(name: "Dry Bag 20L", category: .tools, weightGrams: 120, essential: true))
            items.append(GearItem(name: "Fishing Kit", category: .tools, weightGrams: 350))
        case .desert:
            items.append(GearItem(name: "Sun Shelter", category: .shelter, weightGrams: 800, essential: true))
            items.append(GearItem(name: "Extra Water 5L", category: .water, weightGrams: 200, essential: true))
            items.append(GearItem(name: "Electrolyte Packets", category: .safety, weightGrams: 50, essential: true))
        default: break
        }
        return items
    }
}
