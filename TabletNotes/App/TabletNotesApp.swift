/* TabletNotesApp */

import SwiftUI

@main
struct TabletNotesApp: App {
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                LoginView(authService: authService)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
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
