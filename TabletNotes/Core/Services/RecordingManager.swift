import Foundation
import AVFoundation
import SwiftData

#if os(iOS)
@Observable
final class RecordingManager {
    static let shared = RecordingManager()
    
    private(set) var isRecording = false
    private(set) var currentRecordingURL: URL?
    private var audioRecorder: AVAudioRecorder?
    private var recordingStartTime: Date?
    
    private init() {}
    
    func startRecording() async throws -> URL {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try await requestMicrophonePermission()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderBitRateKey: 128000,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
            currentRecordingURL = audioFilename
            recordingStartTime = Date()
            
            return audioFilename
        } catch {
            throw RecordingError.recordingFailed(error)
        }
    }
    
    func stopRecording() throws {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        isRecording = false
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            throw RecordingError.recordingFailed(error)
        }
    }
    
    func deleteRecording() {
        guard let url = currentRecordingURL else { return }
        
        try? FileManager.default.removeItem(at: url)
        currentRecordingURL = nil
    }
    
    private func requestMicrophonePermission() async throws {
        let status = AVAudioApplication.shared.recordPermission
        
        switch status {
        case .granted:
            return
        case .denied:
            throw RecordingError.permissionDenied
        case .undetermined:
            return try await withCheckedThrowingContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    if granted {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: RecordingError.permissionDenied)
                    }
                }
            }
        @unknown default:
            throw RecordingError.permissionDenied
        }
    }
}

enum RecordingError: LocalizedError {
    case permissionDenied
    case recordingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone access is required to record audio. Please enable it in Settings."
        case .recordingFailed(let error):
            return "Failed to record audio: \(error.localizedDescription)"
        }
    }
}
#endif 