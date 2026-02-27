import SwiftUI

struct CardStyle: ViewModifier {
    var opacity: Double = 0.08
    func body(content: Content) -> some View {
        content.padding()
            .background(Color.white.opacity(opacity))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
extension View {
    func cardStyle(opacity: Double = 0.08) -> some View { modifier(CardStyle(opacity: opacity)) }
}

struct Theme {
    static let bg = Color(red: 0.06, green: 0.09, blue: 0.06)
    static let surface = Color(red: 0.1, green: 0.14, blue: 0.1)
    static let forest = Color(red: 0.18, green: 0.55, blue: 0.25)
    static let campfire = Color(red: 0.92, green: 0.45, blue: 0.1)
    static let earth = Color(red: 0.6, green: 0.45, blue: 0.28)
    static let sky = Color(red: 0.35, green: 0.65, blue: 0.9)
    static let snow = Color(red: 0.85, green: 0.9, blue: 0.95)
    static let danger = Color(red: 0.85, green: 0.2, blue: 0.2)
    static let textPrimary = Color(red: 0.92, green: 0.94, blue: 0.9)
    static let textSecondary = Color(red: 0.5, green: 0.55, blue: 0.48)
    static var bgGradient: LinearGradient {
        LinearGradient(colors: [bg, Color(red: 0.04, green: 0.06, blue: 0.04)], startPoint: .top, endPoint: .bottom)
    }
}

func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

// MARK: - Hexagon Shape (Custom Shape — unique to this app)

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let cx = w / 2, cy = h / 2
        let r = min(w, h) / 2
        var path = Path()
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 - .pi / 6
            let x = cx + r * cos(angle)
            let y = cy + r * sin(angle)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

struct HexTile: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button { haptic(.light); action() } label: {
            VStack(spacing: 6) {
                ZStack {
                    HexagonShape().fill(color.opacity(0.15)).frame(width: 52, height: 52)
                    HexagonShape().stroke(color.opacity(0.3), lineWidth: 1).frame(width: 52, height: 52)
                    Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
                }
                Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(Theme.textPrimary).lineLimit(1)
                Text(value).font(.system(size: 9)).foregroundColor(Theme.textSecondary).lineLimit(1)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(Color.white.opacity(0.04)).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.05), lineWidth: 1))
        }
    }
}

// MARK: - Mountain Range (decorative header shape)

struct MountainRange: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: w * 0.15, y: h * 0.45))
        p.addLine(to: CGPoint(x: w * 0.25, y: h * 0.6))
        p.addLine(to: CGPoint(x: w * 0.4, y: h * 0.2))
        p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.35))
        p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.1))
        p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.4))
        p.addLine(to: CGPoint(x: w * 0.88, y: h * 0.3))
        p.addLine(to: CGPoint(x: w, y: h * 0.55))
        p.addLine(to: CGPoint(x: w, y: h))
        p.closeSubpath()
        return p
    }
}
