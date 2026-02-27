import SwiftUI

enum TripType: String, Codable, CaseIterable, Identifiable {
    case mountain = "Mountain"
    case forest = "Forest"
    case lake = "Lake"
    case winter = "Winter"
    case desert = "Desert"
    case beach = "Beach"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .mountain: return "mountain.2.fill"
        case .forest: return "tree.fill"
        case .lake: return "water.waves"
        case .winter: return "snowflake"
        case .desert: return "sun.max.fill"
        case .beach: return "beach.umbrella.fill"
        }
    }
    var color: Color {
        switch self {
        case .mountain: return Color(red: 0.55, green: 0.55, blue: 0.6)
        case .forest: return Color(red: 0.2, green: 0.65, blue: 0.3)
        case .lake: return Color(red: 0.2, green: 0.55, blue: 0.85)
        case .winter: return Color(red: 0.6, green: 0.8, blue: 0.95)
        case .desert: return Color(red: 0.9, green: 0.7, blue: 0.3)
        case .beach: return Color(red: 0.95, green: 0.6, blue: 0.2)
        }
    }
}

enum GearCategory: String, Codable, CaseIterable, Identifiable {
    case shelter = "Shelter"
    case sleep = "Sleep"
    case cooking = "Cooking"
    case clothing = "Clothing"
    case navigation = "Navigation"
    case safety = "Safety"
    case hygiene = "Hygiene"
    case water = "Water"
    case tools = "Tools"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .shelter: return "tent.fill"
        case .sleep: return "bed.double.fill"
        case .cooking: return "flame.fill"
        case .clothing: return "tshirt.fill"
        case .navigation: return "map.fill"
        case .safety: return "cross.case.fill"
        case .hygiene: return "hands.and.sparkles.fill"
        case .water: return "drop.fill"
        case .tools: return "wrench.and.screwdriver.fill"
        }
    }
    var color: Color {
        switch self {
        case .shelter: return Color(red: 0.6, green: 0.45, blue: 0.3)
        case .sleep: return Color(red: 0.4, green: 0.35, blue: 0.65)
        case .cooking: return Color(red: 0.9, green: 0.4, blue: 0.15)
        case .clothing: return Color(red: 0.3, green: 0.6, blue: 0.5)
        case .navigation: return Color(red: 0.2, green: 0.55, blue: 0.85)
        case .safety: return Color(red: 0.85, green: 0.2, blue: 0.2)
        case .hygiene: return Color(red: 0.5, green: 0.75, blue: 0.85)
        case .water: return Color(red: 0.2, green: 0.65, blue: 0.9)
        case .tools: return Color(red: 0.55, green: 0.55, blue: 0.6)
        }
    }
}

struct GearItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var category: GearCategory
    var weightGrams: Int = 0
    var packed: Bool = false
    var essential: Bool = false
    var notes: String = ""
}

struct Trip: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String = ""
    var tripType: TripType = .forest
    var date: Date = Date()
    var durationDays: Int = 3
    var groupSize: Int = 2
    var location: String = ""
    var notes: String = ""
}

struct KnotInfo: Identifiable {
    let id = UUID()
    let name: String
    let use: String
    let difficulty: String
    let steps: [String]
}

struct CampingSettings: Codable {
    var hasCompletedOnboarding: Bool = false
    var userName: String = ""
    var experienceLevel: String = "Beginner"
    var weightUnit: String = "g"
    var caloriesPerDay: Int = 2500
}
