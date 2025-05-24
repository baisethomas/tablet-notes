import SwiftUI
import SwiftData

@main
struct TabletNotesApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                Text("Sermons")
                    .tabItem {
                        Label("Sermons", systemImage: "book.fill")
                    }
                
                Text("Record")
                    .tabItem {
                        Label("Record", systemImage: "mic.fill")
                    }
                
                Text("Account")
                    .tabItem {
                        Label("Account", systemImage: "person.fill")
                    }
            }
        }
    }
} 