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
            ContentView()
                .tabItem {
                    Label("Hello", systemImage: "hand.wave.fill")
                }
                .tag(0)
            
            HelloStylesView()
                .tabItem {
                    Label("Styles", systemImage: "paintpalette.fill")
                }
                .tag(1)
            
            VenueListView()
                .tabItem {
                    Label("Venues", systemImage: "music.note.house.fill")
                }
                .tag(2)
        }
        .accentColor(.blue) // Makes selected tab blue
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Hello, World!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                
                Text("Venue Finder App")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("✅ Swift/SwiftUI Prototype")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.top, 20)
                
                Text("This demonstrates we can create and run iOS apps")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    PrototypeSwitcherView()
}
