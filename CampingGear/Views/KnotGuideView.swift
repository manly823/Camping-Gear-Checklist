import SwiftUI

struct KnotGuideView: View {
    @Environment(\.dismiss) var dismiss
    @State private var expanded: UUID?

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(CampingManager.knots) { knot in knotCard(knot) }
                    }.padding()
                }
            }
            .navigationTitle("Knot Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } } }
        }
    }

    private func knotCard(_ knot: KnotInfo) -> some View {
        let isExpanded = expanded == knot.id
        return VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.35)) { expanded = isExpanded ? nil : knot.id }
                haptic(.light)
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        HexagonShape().fill(Theme.earth.opacity(0.2)).frame(width: 40, height: 40)
                        Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill").font(.system(size: 14)).foregroundColor(Theme.earth)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(knot.name).font(.subheadline.bold()).foregroundColor(.white)
                        Text(knot.use).font(.caption).foregroundColor(Theme.textSecondary).lineLimit(isExpanded ? nil : 1)
                    }
                    Spacer()
                    diffBadge(knot.difficulty)
                    Image(systemName: "chevron.right").font(.caption).foregroundColor(Theme.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(knot.steps.enumerated()), id: \.offset) { i, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(i + 1)").font(.caption.bold()).foregroundColor(Theme.campfire)
                                .frame(width: 20, height: 20)
                                .background(Theme.campfire.opacity(0.15)).cornerRadius(6)
                            Text(step).font(.caption).foregroundColor(Theme.textSecondary)
                        }
                    }
                }.padding(.leading, 52).transition(.opacity.combined(with: .move(edge: .top)))
            }
        }.cardStyle()
    }

    private func diffBadge(_ diff: String) -> some View {
        let color: Color = diff == "Easy" ? Theme.forest : diff == "Medium" ? Theme.campfire : Theme.danger
        return Text(diff).font(.system(size: 9, weight: .bold)).foregroundColor(color)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(color.opacity(0.15)).cornerRadius(6)
    }
}
