import SwiftUI

struct AddGearView: View {
    @EnvironmentObject var mgr: CampingManager
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var category: GearCategory = .tools
    @State private var weight = ""
    @State private var essential = false
    @State private var notes = ""

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY").font(.caption.bold()).foregroundColor(Theme.textSecondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(GearCategory.allCases) { c in
                                        Button { category = c } label: {
                                            VStack(spacing: 4) {
                                                ZStack {
                                                    HexagonShape().fill(category == c ? c.color.opacity(0.3) : Color.white.opacity(0.05)).frame(width: 36, height: 36)
                                                    Image(systemName: c.icon).font(.system(size: 13)).foregroundColor(category == c ? c.color : Theme.textSecondary)
                                                }
                                                Text(c.rawValue).font(.system(size: 8)).foregroundColor(category == c ? .white : Theme.textSecondary)
                                            }
                                        }
                                    }
                                }
                            }
                        }.cardStyle()

                        inputField("Gear Name", text: $name, icon: "tag", placeholder: "e.g. Headlamp")
                        inputField("Weight (grams)", text: $weight, icon: "scalemass", placeholder: "e.g. 90", keyboard: .numberPad)
                        inputField("Notes", text: $notes, icon: "note.text", placeholder: "Optional notes")
                        Toggle(isOn: $essential) {
                            HStack { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Theme.campfire); Text("Essential item").foregroundColor(.white) }
                        }.tint(Theme.campfire).cardStyle()
                    }.padding()
                }
            }
            .navigationTitle("Add Gear")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let item = GearItem(name: name, category: category, weightGrams: Int(weight) ?? 0, essential: essential, notes: notes)
                        mgr.addGear(item); haptic(.heavy); dismiss()
                    }.foregroundColor(Theme.forest).bold().disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func inputField(_ label: String, text: Binding<String>, icon: String, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(Theme.textSecondary).frame(width: 24)
            TextField(placeholder, text: text).foregroundColor(.white).keyboardType(keyboard)
        }.cardStyle()
    }
}
