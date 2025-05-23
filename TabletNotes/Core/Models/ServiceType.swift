import Foundation

public enum ServiceType: String, CaseIterable, Identifiable {
    case sermon = "Sermon"
    case bibleStudy = "Bible Study"
    case youthGroup = "Youth Group"
    case conference = "Conference"
    
    public var id: String { rawValue }
} 