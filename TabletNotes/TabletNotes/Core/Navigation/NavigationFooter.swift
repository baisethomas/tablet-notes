import SwiftUI

struct NavigationFooter: View {
    var onHomeTap: () -> Void = {}
    var onRecordTap: (ServiceType) -> Void = { _ in }
    var onAccountTap: () -> Void = {}
    
    @State private var showServiceTypeSelection = false
    @State private var selectedServiceType: ServiceType?
    @State private var showRecordingView = false
    @State private var isRecording = false
    
    var body: some View {
        HStack {
            FooterButton(icon: "house.fill", text: "Home", action: onHomeTap)
                .frame(maxWidth: .infinity)
            
            // Center Record Button
            Button(action: {
                if isRecording {
                    showRecordingView = true
                } else {
                    showServiceTypeSelection = true
                }
            }) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: isRecording ? "waveform.circle" : "microphone")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .offset(y: -20)
            }
            .frame(maxWidth: .infinity)
            .confirmationDialog("Select Service Type", isPresented: $showServiceTypeSelection, titleVisibility: .visible) {
                ForEach(ServiceType.allCases) { serviceType in
                    Button(serviceType.rawValue) {
                        selectedServiceType = serviceType
                        showRecordingView = true
                        isRecording = true
                    }
                }
            }
            
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
        .sheet(isPresented: $showRecordingView) {
            if let serviceType = selectedServiceType {
                RecordingView(serviceType: serviceType)
            }
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
        NavigationFooter(
            onHomeTap: {},
            onRecordTap: { _ in },
            onAccountTap: {}
        )
    }
} 