import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            // Main Content
            VStack(spacing: 0) {
                // Empty State Content
                VStack(spacing: 24) {
                    Image(systemName: "ellipsis.bubble")
                        .font(.system(size: 96))
                        .foregroundStyle(.gray.opacity(0.3))
                    
                    Text("To Get Started, Press Record")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 100) // Offset to account for tab bar and center in remaining space
            }
            .frame(maxHeight: .infinity)
            
            // Navigation Footer overlay at bottom
            VStack {
                Spacer()
                NavigationFooter(
                    onHomeTap: {
                        // Implement home navigation
                    },
                    onRecordTap: { serviceType in
                        print("Starting recording for: \(serviceType.rawValue)")
                        // We'll implement the actual recording later
                    },
                    onAccountTap: {
                        // Implement account navigation
                    }
                )
            }
        }
    }
}

#Preview {
    HomeView()
} 