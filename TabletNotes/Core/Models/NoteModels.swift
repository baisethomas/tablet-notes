import Foundation
import SwiftData

// Basic note entry with timestamp
struct NoteEntry: Identifiable, Codable {
    var id = UUID()
    var timestamp: TimeInterval
    var text: String
    var tags: [String]
    var scripture: String?
    
    init(timestamp: TimeInterval, text: String, tags: [String] = [], scripture: String? = nil) {
        self.timestamp = timestamp
        self.text = text
        self.tags = tags
        self.scripture = scripture
    }
}

// Main note container model for SwiftData storage
@Model
class SermonNote {
    var id: UUID
    var sermonId: UUID
    var content: String
    var entries: [NoteEntry]?
    var createdAt: Date
    var updatedAt: Date
    
    init(sermonId: UUID, content: String = "", entries: [NoteEntry]? = nil) {
        self.id = UUID()
        self.sermonId = sermonId
        self.content = content
        self.entries = entries
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Helper to add a timestamped entry
    func addEntry(text: String, tags: [String] = [], scripture: String? = nil, timestamp: TimeInterval) {
        let entry = NoteEntry(timestamp: timestamp, text: text, tags: tags, scripture: scripture)
        if entries == nil {
            entries = [entry]
        } else {
            entries?.append(entry)
        }
        updatedAt = Date()
    }
} 