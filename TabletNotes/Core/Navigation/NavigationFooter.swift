import SwiftUI

struct NavigationFooter: View {
    var onHomeTap: () -> Void = {}
    var onRecordTap: () -> Void = {}
    var onAccountTap: () -> Void = {}
    
    var body: some View {
        HStack {
            FooterButton(icon: "house.fill", text: "Home", action: onHomeTap)
                .frame(maxWidth: .infinity)
            
            // Center Record Button
            Button(action: onRecordTap) {
                Circle()
                    .fill(.blue)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "microphone")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .offset(y: -20)
            }
            .frame(maxWidth: .infinity)
            
            FooterButton(icon: "person", text: "Account", action: onAccountTap)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background {
            Rectangle()
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 3, y: -1)
                .ignoresSafeArea()
        }
    }
}

private struct FooterButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(text)
                    .font(.caption)
            }
        }
        .foregroundStyle(.gray)
    }
}

#Preview {
    VStack {
        Spacer()
        NavigationFooter()
    }
} 