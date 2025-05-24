import SwiftUI

struct DashboardView: View {
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

#Preview {
    DashboardView()
} 