import Foundation

// Data Transfer Object for Supabase network operations
struct SermonDTO: Codable {
    var id: String // Using String for UUID in JSON
    var title: String
    var date: String // ISO8601 date format
    var notes: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case date
        case notes
    }
    
    // Convert from SwiftData model to DTO
    init(from model: SermonModel) {
        self.id = model.id.uuidString
        self.title = model.title
        self.date = ISO8601DateFormatter().string(from: model.date)
        self.notes = model.notes
    }
    
    // Convert DTO to SwiftData model
    func toModel() -> SermonModel {
        let dateFormatter = ISO8601DateFormatter()
        let parsedDate = dateFormatter.date(from: self.date) ?? Date()
        return SermonModel(
            id: UUID(uuidString: self.id) ?? UUID(),
            title: self.title,
            date: parsedDate,
            notes: self.notes
        )
    }
} 