import Foundation
import AVFoundation
import SwiftUI

// Recording status state
enum RecordingState {
    case idle
    case recording
    case paused
    case finished
}

// Simple recording manager
class RecordingManager: ObservableObject {
    // Shared instance
    static let shared = RecordingManager()
    
    // Published properties for UI binding
    @Published var recordingState: RecordingState = .idle
    @Published var currentRecordingId: UUID?
    @Published var elapsedTime: TimeInterval = 0
    
    // Audio properties
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    // Initialize manager
    private init() {
        #if os(iOS)
        setupAudioSession()
        #endif
    }
    
    // Setup audio session for recording
    #if os(iOS)
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    #endif
    
    // Request microphone permissions
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        #if os(iOS)
        AVAudioApplication.requestRecordPermission { granted in
            completion(granted)
        }
        #else
        // For macOS - would need different approach
        completion(false)
        #endif
    }
    
    // Start recording with a service type
    func startRecording(serviceType: String) {
        // Create a new recording ID
        let recordingId = UUID()
        self.currentRecordingId = recordingId
        
        // Set up recording file URL in documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsDirectory.appendingPathComponent("\(recordingId.uuidString).m4a")
        
        // Configure audio recording settings
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // Start recording
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            // Start timer to track elapsed time
            startTimer()
            
            // Update state
            recordingState = .recording
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }
    
    // Pause recording
    func pauseRecording() {
        audioRecorder?.pause()
        timer?.invalidate()
        recordingState = .paused
    }
    
    // Resume recording
    func resumeRecording() {
        audioRecorder?.record()
        startTimer()
        recordingState = .recording
    }
    
    // Stop recording
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        recordingState = .finished
    }
    
    // Start timer for tracking elapsed time
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let recorder = self.audioRecorder, recorder.isRecording {
                self.elapsedTime = recorder.currentTime
            }
        }
    }
    
    // Reset for a new recording session
    func reset() {
        stopRecording()
        elapsedTime = 0
        recordingState = .idle
        currentRecordingId = nil
    }
    
    deinit {
        audioRecorder?.stop()
        timer?.invalidate()
    }
} 
