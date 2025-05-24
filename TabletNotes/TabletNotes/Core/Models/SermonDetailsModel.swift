import Foundation
import SwiftData

@Model
final class SermonDetailsModel {
    // Identity
    @Attribute(.unique) var id: UUID
    var title: String
    
    // Metadata
    var date: Date
    var duration: TimeInterval
    var speaker: String
    @Attribute(originalName: "serviceType")
    private var _serviceType: String
    
    var serviceType: ServiceType {
        get {
            ServiceType(rawValue: _serviceType) ?? .sermon
        }
        set {
            _serviceType = newValue.rawValue
        }
    }
    
    // Content Sections
    var summary: String
    var transcript: String
    var notes: String
    
    // Timestamps
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String = "",
        date: Date = .now,
        duration: TimeInterval = 0,
        speaker: String = "",
        serviceType: ServiceType = .sermon,
        summary: String = "",
        transcript: String = "",
        notes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.duration = duration
        self.speaker = speaker
        self._serviceType = serviceType.rawValue
        self.summary = summary
        self.transcript = transcript
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Helper computed properties
    var formattedDuration: String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
    
    var formattedDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd - h:mma"
        return dateFormatter.string(from: date)
    }
    
    // Helper method to update notes
    func updateNotes(_ newNotes: String) {
        notes = newNotes
        updatedAt = .now
    }
    
    // Helper method to update AI summary
    func updateSummary(_ newSummary: String) {
        summary = newSummary
        updatedAt = .now
    }
    
    // Helper method to update transcript
    func updateTranscript(_ newTranscript: String) {
        transcript = newTranscript
        updatedAt = .now
    }
} 