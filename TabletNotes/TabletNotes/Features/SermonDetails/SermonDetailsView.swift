import SwiftUI
import SwiftData

struct SermonDetailsView: View {
    let sermon: SermonDetailsModel
    @State private var selectedTab: Int = 0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - View Components
    
    private var headerMetadata: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sermon.title)
                .font(.system(size: 18, weight: .semibold))
            
            HStack(spacing: 4) {
                Text(sermon.formattedDateTime)
                Text("-")
                Text(sermon.formattedDuration)
                Text("-")
                Text(sermon.speaker)
                Text("-")
                Text(sermon.serviceType.rawValue)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private var tabBar: some View {
        HStack(spacing: 20) {
            TabButton(title: "Summary", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "Transcript", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "Notes", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var contentView: some View {
        TabView(selection: $selectedTab) {
            SummaryContentView(summary: sermon.summary)
                .tag(0)
            
            TranscriptContentView(transcript: sermon.transcript)
                .tag(1)
            
            NotesContentView(sermonId: sermon.id)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            headerMetadata
            tabBar
            contentView
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
        }
    }
}

private struct SummaryContentView: View {
    let summary: String
    
    var body: some View {
        ScrollView {
            Text(summary)
                .padding()
        }
    }
}

private struct TranscriptContentView: View {
    let transcript: String
    
    var body: some View {
        ScrollView {
            Text(transcript)
                .padding()
        }
    }
}

private struct NotesContentView: View {
    let sermonId: UUID
    @State private var notesText: String = ""
    
    var body: some View {
        ScrollView {
            TextEditor(text: $notesText)
                .frame(minHeight: 200)
                .padding()
        }
    }
}

#Preview {
    // Sample data for preview
    let sermon = SermonDetailsModel(
        id: UUID(),
        title: "Message Title",
        date: Date(),
        duration: 45 * 60, // 45 minutes
        speaker: "Steve Furtick",
        serviceType: .sermon,
        summary: "This is a sample summary of the sermon...",
        transcript: "This is a sample transcript of the sermon...",
        notes: "These are sample notes for the sermon...",
        createdAt: .now,
        updatedAt: .now
    )
    
    NavigationStack {
        SermonDetailsView(sermon: sermon)
    }
} 
