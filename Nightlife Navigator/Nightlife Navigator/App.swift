import SwiftUI

@main
struct VenueFinderPrototypesApp: App {
    var body: some Scene {
        WindowGroup {
            PrototypeSwitcherView()
        }
    }
}

struct PrototypeSwitcherView: View {
    @State private var selectedPrototype = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedPrototype) {
            VenueListView()
                .tabItem {
                    Label("Venues", systemImage: "music.note.house.fill")
                }
                .tag(0)

            NavigationStack {
                GroupFitView()
            }
            .tabItem { Label("Group Fit", systemImage: "person.3") }
            .tag(1)
        }
        .accentColor(.blue)
    }
}

#Preview {
    PrototypeSwitcherView()
}
