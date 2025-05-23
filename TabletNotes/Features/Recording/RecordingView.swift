import SwiftUI

struct RecordingView: View {
    let serviceType: ServiceType
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var recordingTime: TimeInterval = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Header
            VStack(spacing: 8) {
  
                
                // Title on separate line
                Text("Recording")
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
            
            // Recording Controls
            HStack(spacing: 24) {
                // Pause Button
                Button(action: {
                    // Implement pause/resume
                }) {
                    Image(systemName: "pause.fill")
                        .font(.title2)
                }
                
                // Waveform (placeholder)
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Timer with recording indicator
                HStack(spacing: 6) {
                    Text(formatTime(recordingTime))
                        .monospacedDigit()
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            
            // Notes Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField("Title", text: $title)
                        .font(.title3)
                        .textFieldStyle(.plain)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.title3)
                    }
                }
                
                TextEditor(text: $notes)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .placeholder(when: notes.isEmpty) {
                        Text("This is where you take notes.")
                            .foregroundStyle(.gray)
                    }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.1))
            }
            .padding()
        }
        .background(.white)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .topLeading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    RecordingView(serviceType: .sermon)
} 