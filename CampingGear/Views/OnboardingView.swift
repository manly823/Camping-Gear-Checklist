import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var mgr: CampingManager
    @State private var page = 0
    @State private var tripName = ""
    @State private var tripType: TripType = .forest
    @State private var days = "3"
    @State private var group = "2"
    @State private var location = ""
    @State private var experience = "Beginner"

    private var canFinish: Bool { !tripName.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            Theme.bgGradient.ignoresSafeArea()
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    obPage(icon: "backpack.fill", title: "Camping Gear", sub: "Never forget a thing",
                           desc: "Smart checklists tailored to your trip type. Track what's packed, analyze weight, plan food, and learn essential knots.", color: Theme.forest).tag(0)
                    obPage(icon: "checklist.checked", title: "Smart Checklists", sub: "Pack with confidence",
                           desc: "Gear lists generated for mountain, forest, lake, winter, desert, or beach trips. Check items off, search and filter by category.", color: Theme.campfire).tag(1)
                    obPage(icon: "chart.pie.fill", title: "Weight Analysis", sub: "Lighten your load",
                           desc: "See exactly where the weight goes. Pie chart by category, total pack weight, and progress toward your packing goal.", color: Theme.sky).tag(2)
                    obPage(icon: "fork.knife", title: "Food Planner", sub: "Fuel your adventure",
                           desc: "Calculate total calories and food weight for your group. Water requirements per day, meal planning by trip duration.", color: Theme.earth).tag(3)
                    tripSetupPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                if page == 4 {
                    Button {
                        let t = Trip(name: tripName.trimmingCharacters(in: .whitespaces), tripType: tripType,
                                     durationDays: Int(days) ?? 3, groupSize: Int(group) ?? 2, location: location)
                        mgr.settings.experienceLevel = experience
                        mgr.setupTrip(t)
                        haptic(.heavy)
                        withAnimation { mgr.settings.hasCompletedOnboarding = true }
                    } label: {
                        Text("Start Packing").font(.headline).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(canFinish ? Theme.forest : Theme.forest.opacity(0.3)).cornerRadius(14)
                    }.disabled(!canFinish).padding(.horizontal, 40).padding(.bottom, 40)
                }
            }
        }
    }

    private var tripSetupPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                Spacer().frame(height: 20)
                ZStack {
                    Circle().fill(Theme.forest.opacity(0.12)).frame(width: 110, height: 110)
                    Image(systemName: "tent.fill").font(.system(size: 40)).foregroundColor(Theme.forest)
                }
                Text("Plan Your Trip").font(.title.bold()).foregroundColor(.white)

                VStack(spacing: 12) {
                    field("Trip Name *", text: $tripName, icon: "pencil", placeholder: "e.g. Weekend at Yosemite")
                    field("Location", text: $location, icon: "mappin", placeholder: "e.g. Yosemite Valley")

                    VStack(alignment: .leading, spacing: 6) {
                        Text("TRIP TYPE").font(.caption.bold()).foregroundColor(Theme.textSecondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(TripType.allCases) { t in
                                    Button { tripType = t } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: t.icon).font(.title3)
                                            Text(t.rawValue).font(.system(size: 9))
                                        }.foregroundColor(tripType == t ? .white : Theme.textSecondary)
                                        .frame(width: 60, height: 52)
                                        .background(tripType == t ? t.color.opacity(0.3) : Color.white.opacity(0.05)).cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tripType == t ? t.color : Color.clear, lineWidth: 1))
                                    }
                                }
                            }
                        }
                    }.cardStyle()

                    HStack(spacing: 12) {
                        field("Days", text: $days, icon: "calendar", placeholder: "3", keyboard: .numberPad)
                        field("Group Size", text: $group, icon: "person.2", placeholder: "2", keyboard: .numberPad)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("EXPERIENCE").font(.caption.bold()).foregroundColor(Theme.textSecondary)
                        Picker("", selection: $experience) {
                            Text("Beginner").tag("Beginner"); Text("Intermediate").tag("Intermediate"); Text("Expert").tag("Expert")
                        }.pickerStyle(.segmented)
                    }.cardStyle()
                }.padding(.horizontal, 24)
                Spacer().frame(height: 80)
            }
        }
    }

    private func field(_ label: String, text: Binding<String>, icon: String, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption.bold()).foregroundColor(Theme.textSecondary)
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundColor(Theme.forest).frame(width: 24)
                TextField(placeholder, text: text).foregroundColor(.white).keyboardType(keyboard)
            }.padding().background(Color.white.opacity(0.08)).cornerRadius(12)
        }
    }

    private func obPage(icon: String, title: String, sub: String, desc: String, color: Color) -> some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                MountainRange().fill(color.opacity(0.06)).frame(height: 120).offset(y: 30)
                Circle().fill(color.opacity(0.12)).frame(width: 140, height: 140)
                Image(systemName: icon).font(.system(size: 50)).foregroundColor(color)
            }
            Text(title).font(.largeTitle.bold()).foregroundColor(.white)
            Text(sub).font(.title3).foregroundColor(color)
            Text(desc).font(.body).foregroundColor(Theme.textSecondary).multilineTextAlignment(.center).padding(.horizontal, 40)
            Spacer(); Spacer()
        }
    }
}
