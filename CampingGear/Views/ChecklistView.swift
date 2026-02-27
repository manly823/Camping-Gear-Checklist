import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject var mgr: CampingManager
    @Environment(\.dismiss) var dismiss
    @State private var search = ""
    @State private var filter: GearCategory?
    @State private var showEssentialOnly = false

    var filtered: [GearItem] {
        var list = mgr.gear
        if let f = filter { list = list.filter { $0.category == f } }
        if showEssentialOnly { list = list.filter { $0.essential } }
        if !search.isEmpty { list = list.filter { $0.name.localizedCaseInsensitiveContains(search) || $0.notes.localizedCaseInsensitiveContains(search) } }
        return list
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                VStack(spacing: 0) {
                    filterBar
                    if filtered.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "checklist").font(.system(size: 40)).foregroundColor(Theme.textSecondary)
                            Text("No items").foregroundColor(Theme.textSecondary)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filtered) { item in gearRow(item) }
                                .onDelete { idx in idx.map { filtered[$0] }.forEach { mgr.deleteGear($0) } }
                                .listRowBackground(Color.clear)
                        }.listStyle(.plain).scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Checklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Close") { dismiss() } } }
        }
        .searchable(text: $search, prompt: "Search gear…")
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                chip("All", active: filter == nil && !showEssentialOnly) { filter = nil; showEssentialOnly = false }
                chip("Essential", active: showEssentialOnly, color: Theme.campfire) { showEssentialOnly.toggle(); if showEssentialOnly { filter = nil } }
                ForEach(GearCategory.allCases) { c in
                    chip(c.rawValue, active: filter == c, color: c.color) { filter = (filter == c ? nil : c); showEssentialOnly = false }
                }
            }.padding(.horizontal).padding(.vertical, 8)
        }
    }

    private func chip(_ label: String, active: Bool, color: Color = Theme.forest, action: @escaping () -> Void) -> some View {
        Button { haptic(.light); action() } label: {
            Text(label).font(.caption.bold()).foregroundColor(active ? .white : Theme.textSecondary)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(active ? color.opacity(0.3) : Color.white.opacity(0.05)).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(active ? color.opacity(0.5) : Color.clear, lineWidth: 1))
        }
    }

    private func gearRow(_ item: GearItem) -> some View {
        HStack(spacing: 12) {
            Button { haptic(.light); mgr.togglePacked(item) } label: {
                Image(systemName: item.packed ? "checkmark.circle.fill" : "circle")
                    .font(.title3).foregroundColor(item.packed ? Theme.forest : Theme.textSecondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(item.name).font(.subheadline).foregroundColor(item.packed ? Theme.textSecondary : .white)
                        .strikethrough(item.packed, color: Theme.textSecondary)
                    if item.essential { Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 9)).foregroundColor(Theme.campfire) }
                }
                HStack(spacing: 6) {
                    Image(systemName: item.category.icon).font(.system(size: 9)).foregroundColor(item.category.color)
                    Text(item.category.rawValue).font(.caption2).foregroundColor(Theme.textSecondary)
                }
            }
            Spacer()
            Text("\(item.weightGrams)g").font(.caption.bold()).foregroundColor(Theme.textSecondary)
        }.padding(.vertical, 3)
    }
}
