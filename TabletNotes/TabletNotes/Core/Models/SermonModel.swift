import Foundation
import SwiftData

@Model
final class SermonModel {
    var id: UUID
    var title: String
    var date: Date
    var notes: String
    
    init(id: UUID = UUID(), title: String = "", date: Date = .now, notes: String = "") {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
    }
} 