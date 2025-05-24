import SwiftUI

struct NavigationHeader: View {
    let title: String
    var onSearchTap: () -> Void = {}
    var onAITap: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 8) {
            // Top row with icon and buttons
            HStack {
                // Left - App Icon
                Image(systemName: "book.pages.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Spacer()
                
                // Right - Action Buttons
                HStack(spacing: 24) {
                    Button(action: onSearchTap) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    
                    Button(action: onAITap) {
                        Image(systemName: "bubbles.and.sparkles")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            // Title on separate line
            Text(title)
                .font(.headline)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background {
            Rectangle()
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    VStack {
        NavigationHeader(
            title: "Conversations",
            onSearchTap: {},
            onAITap: {}
        )
        Spacer()
    }
} 