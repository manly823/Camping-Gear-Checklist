import SwiftUI

@main
struct CampingGearApp: App {
    @StateObject private var manager = CampingManager()
    var body: some Scene {
        WindowGroup {
            if manager.settings.hasCompletedOnboarding {
                MainView().environmentObject(manager)
            } else {
                OnboardingView().environmentObject(manager)
            }
        }
    }
}
