import SwiftUI
import UIKit

struct RecordingStatusView: View {
    @ObservedObject var recordingManager: RecordingManager
    
    var body: some View {
        VStack(spacing: 8) {
            // Recording status indicator
            HStack {
                Circle()
                    .fill(recordingManager.recordingState == .recording ? Color.red : Color.gray)
                    .frame(width: 12, height: 12)
                    .opacity(recordingManager.recordingState == .recording ? pulsingOpacity : 1)
                
                Text(statusText)
                    .font(.headline)
                    .foregroundColor(recordingManager.recordingState == .recording ? .red : .primary)
                
                Spacer()
                
                // Timer display
                Text(formattedTime)
                    .font(.title2.monospacedDigit())
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            
            // Waveform visualization (simplified)
            WaveformView(isRecording: recordingManager.recordingState == .recording)
                .frame(height: 40)
                .padding(.horizontal)
            
            // Recording controls
            HStack(spacing: 24) {
                Spacer()
                
                // Pause/Resume button
                Button(action: togglePauseResume) {
                    Image(systemName: recordingManager.recordingState == .recording ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(recordingManager.recordingState == .recording ? .red : .blue)
                }
                .disabled(recordingManager.recordingState == .idle || recordingManager.recordingState == .finished)
                
                // Stop button
                Button(action: stopRecording) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.red)
                }
                .disabled(recordingManager.recordingState == .idle || recordingManager.recordingState == .finished)
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .padding(.vertical)
        .background(Color(uiColor: .systemGray6))
    }
    
    // Computed properties
    private var statusText: String {
        switch recordingManager.recordingState {
        case .idle:
            return "Ready"
        case .recording:
            return "Recording"
        case .paused:
            return "Paused"
        case .finished:
            return "Finished"
        }
    }
    
    private var formattedTime: String {
        let minutes = Int(recordingManager.elapsedTime) / 60
        let seconds = Int(recordingManager.elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @State private var pulsingOpacity: Double = 1.0
    
    // Actions
    private func togglePauseResume() {
        if recordingManager.recordingState == .recording {
            recordingManager.pauseRecording()
        } else if recordingManager.recordingState == .paused {
            recordingManager.resumeRecording()
        }
    }
    
    private func stopRecording() {
        recordingManager.stopRecording()
    }
}

// Simple audio waveform visualization
struct WaveformView: View {
    var isRecording: Bool
    @State private var phase = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let midHeight = height / 2
                let barWidth: CGFloat = 3
                let barSpacing: CGFloat = 3
                let barCount = Int(width / (barWidth + barSpacing))
                
                for i in 0..<barCount {
                    let x = CGFloat(i) * (barWidth + barSpacing)
                    
                    if isRecording {
                        let progress = Double(i) / Double(barCount)
                        let amplitude = sin(progress * 10 + phase) * 0.5 + 0.5
                        let barHeight = CGFloat(amplitude * 0.8) * height
                        let y = midHeight - barHeight / 2
                        
                        let bar = Path(CGRect(x: x, y: y, width: barWidth, height: barHeight))
                        context.fill(bar, with: .color(.blue.opacity(0.7)))
                    } else {
                        let barHeight: CGFloat = 4
                        let y = midHeight - barHeight / 2
                        
                        let bar = Path(CGRect(x: x, y: y, width: barWidth, height: barHeight))
                        context.fill(bar, with: .color(.gray.opacity(0.5)))
                    }
                }
            }
            .onAppear {
                if isRecording {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        phase = .pi * 2
                    }
                }
            }
            .onChange(of: isRecording) {
                if isRecording {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        phase = .pi * 2
                    }
                }
            }
        }
    }
}

#Preview {
    RecordingStatusView(recordingManager: RecordingManager.shared)
        .padding()
} 