import SwiftUI

struct ScriptureTaggingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var onSave: (String) -> Void
    
    @State private var book = ""
    @State private var chapter = ""
    @State private var verse = ""
    
    // Common Bible books for quick selection
    private let commonBooks = [
        "Genesis", "Exodus", "Psalms", "Proverbs",
        "Matthew", "Mark", "Luke", "John",
        "Romans", "1 Corinthians", "2 Corinthians", "Galatians",
        "Ephesians", "Philippians", "Colossians", "Revelation"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Book selection
                VStack(alignment: .leading, spacing: 5) {
                    Text("Book")
                        .font(.headline)
                    
                    TextField("e.g., John", text: $book)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Quick selection of common books
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonBooks, id: \.self) { bookName in
                                Button(bookName) {
                                    book = bookName
                                }
                                .buttonStyle(.bordered)
                                .tint(book == bookName ? .blue : .gray)
                            }
                        }
                    }
                }
                
                // Chapter and verse
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Chapter")
                            .font(.headline)
                        
                        TextField("e.g., 3", text: $chapter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Verse(s)")
                            .font(.headline)
                        
                        TextField("e.g., 16 or 16-17", text: $verse)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                // Preview
                VStack(alignment: .leading, spacing: 5) {
                    Text("Preview")
                        .font(.headline)
                    
                    Text(formattedReference)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Scripture Reference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(formattedReference)
                        dismiss()
                    }
                    .disabled(formattedReference.isEmpty)
                }
            }
        }
    }
    
    private var formattedReference: String {
        guard !book.isEmpty else { return "" }
        
        var result = book.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !chapter.isEmpty {
            result += " " + chapter
            
            if !verse.isEmpty {
                result += ":" + verse
            }
        }
        
        return result
    }
}

#Preview {
    ScriptureTaggingView { reference in
        print("Added reference: \(reference)")
    }
} 