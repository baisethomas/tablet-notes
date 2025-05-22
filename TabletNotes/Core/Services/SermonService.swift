import Foundation
import Supabase

enum SermonError: LocalizedError {
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message),
             .saveFailed(let message),
             .deleteFailed(let message):
            return message
        }
    }
}

@MainActor
class SermonService: ObservableObject {
    static let shared = SermonService()
    
    private var supabase: SupabaseClient {
        AuthService.shared.supabase
    }
    
    private init() {}
    
    func fetchSermons() async throws -> [SermonModel] {
        do {
            let response: PostgrestResponse<[SermonDTO]> = try await supabase
                .from("sermons")
                .select()
                .execute()
            
            // Convert DTOs to models
            return response.value.map { $0.toModel() }
        } catch {
            throw SermonError.fetchFailed(error.localizedDescription)
        }
    }
    
    func saveSermon(_ sermon: SermonModel) async throws {
        do {
            // Convert model to DTO
            let dto = SermonDTO(from: sermon)
            
            try await supabase
                .from("sermons")
                .insert(dto)
                .execute()
        } catch {
            throw SermonError.saveFailed(error.localizedDescription)
        }
    }
    
    func deleteSermon(id: UUID) async throws {
        do {
            try await supabase
                .from("sermons")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            throw SermonError.deleteFailed(error.localizedDescription)
        }
    }
} 