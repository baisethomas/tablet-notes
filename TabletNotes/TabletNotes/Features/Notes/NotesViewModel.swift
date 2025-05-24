import Foundation
import SwiftData
import Combine

class NotesViewModel: ObservableObject {
    // Published properties for UI binding
    @Published var noteText = ""
    @Published var elapsedTime: TimeInterval = 0
    @Published var showingScriptureSheet = false
    @Published var selectedScripture: String?
    
    // State for the note
    private var currentRecordingId: UUID?
    private var modelContext: ModelContext?
    private var currentNote: SermonNote?
    
    // Timers for recording and debouncing
    private var timer: Timer?
    private var saveDebounceTimer: Timer?
    private var lastTypingTimestamp: Date?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        startTimer()
    }
    
    // Start the elapsed time timer
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1.0
            
            // For UI updates when testing
            self.objectWillChange.send()
        }
    }
    
    // Load or create notes for a recording
    func loadOrCreateNote(for recordingId: UUID) {
        guard let modelContext = modelContext else { return }
        self.currentRecordingId = recordingId
        
        // Try to find existing note
        let predicate = #Predicate<SermonNote> { note in
            note.sermonId == recordingId
        }
        
        do {
            let existingNotes = try modelContext.fetch(FetchDescriptor<SermonNote>(predicate: predicate))
            if let existingNote = existingNotes.first {
                self.currentNote = existingNote
                self.noteText = existingNote.content
            } else {
                // Create a new note
                let newNote = SermonNote(sermonId: recordingId)
                modelContext.insert(newNote)
                try modelContext.save()
                self.currentNote = newNote
            }
        } catch {
            print("Error loading note: \(error)")
            // Create a new note as fallback
            let newNote = SermonNote(sermonId: recordingId)
            modelContext.insert(newNote)
            self.currentNote = newNote
        }
    }
    
    // Check for timestamp triggers (Enter key or pause)
    func checkForTimestampTrigger(newText: String) {
        // Check if Enter was pressed
        if newText.contains("\n") && (noteText.isEmpty || !noteText.contains("\n")) {
            addTimestamp()
        }
        
        // Set up pause detection
        lastTypingTimestamp = Date()
        saveDebounceTimer?.invalidate()
        saveDebounceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.addTimestamp()
        }
        
        // Update and save the note text
        noteText = newText
        saveNote()
    }
    
    // Add a timestamp entry
    func addTimestamp() {
        guard let currentNote = currentNote else { return }
        
        // Get the last line or paragraph of text
        let lines = noteText.components(separatedBy: .newlines)
        if let lastLine = lines.last, !lastLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            currentNote.addEntry(text: lastLine, timestamp: elapsedTime)
            try? modelContext?.save()
        }
    }
    
    // Add a highlight to selected text
    func addHighlight() {
        guard let currentNote = currentNote else { return }
        // This would be more complex in a real app with NSAttributedString
        // For now, just add a simple entry with [HIGHLIGHT] tag
        currentNote.addEntry(text: "[HIGHLIGHT] \(noteText)", tags: ["highlight"], timestamp: elapsedTime)
        try? modelContext?.save()
    }
    
    // Add a bookmark at current timestamp
    func addBookmark() {
        guard let currentNote = currentNote else { return }
        let formattedTime = formatTime(elapsedTime)
        currentNote.addEntry(text: "Bookmark at \(formattedTime)", tags: ["bookmark"], timestamp: elapsedTime)
        try? modelContext?.save()
    }
    
    // Show scripture tagging sheet
    func showScriptureTagging() {
        showingScriptureSheet = true
    }
    
    // Add scripture reference
    func addScriptureReference(_ reference: String) {
        guard let currentNote = currentNote else { return }
        currentNote.addEntry(text: "Scripture: \(reference)", tags: ["scripture"], scripture: reference, timestamp: elapsedTime)
        try? modelContext?.save()
        showingScriptureSheet = false
    }
    
    // Save the note content (debounced)
    func saveNote() {
        guard let currentNote = currentNote else { return }
        
        saveDebounceTimer?.invalidate()
        saveDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            currentNote.content = self.noteText
            currentNote.updatedAt = Date()
            try? self.modelContext?.save()
        }
    }
    
    // Format time for display (MM:SS)
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Cleanup when done
    func cleanup() {
        timer?.invalidate()
        saveDebounceTimer?.invalidate()
        timer = nil
        saveDebounceTimer = nil
    }
    
    deinit {
        cleanup()
    }
} 