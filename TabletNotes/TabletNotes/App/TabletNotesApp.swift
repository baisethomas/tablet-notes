/* TabletNotesApp */

import SwiftUI
import SwiftData

@main
struct TabletNotesApp: App {
    // Configure the model container for SwiftData
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SermonNote.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}

struct ContentView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Header
            NavigationHeader(
                title: "Conversations",
                onSearchTap: {
                    // Implement search
                },
                onAITap: {
                    // Implement AI features
                }
            )
            
            // Main Content Area
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
