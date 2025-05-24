import SwiftUI
import SwiftData

struct NotesView: View {
    @ObservedObject var viewModel: NotesViewModel
    @ObservedObject var recordingManager: RecordingManager
    
    // State for the floating action buttons
    @State private var showFloatingButtons = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top pane: Recording status with waveform and controls
            if recordingManager.recordingState != .idle {
                RecordingStatusView(recordingManager: recordingManager)
                    .frame(height: 120)
            }
            
            // Bottom pane: Note taking area
            ZStack(alignment: .bottomTrailing) {
                // Text editor for notes
                VStack {
                    TextEditor(text: $viewModel.noteText)
                        .padding()
                        .onChange(of: viewModel.noteText) { 
                            viewModel.checkForTimestampTrigger(newText: viewModel.noteText)
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button(action: viewModel.addHighlight) {
                                    Image(systemName: "highlighter")
                                }
                                
                                Button(action: viewModel.addBookmark) {
                                    Image(systemName: "bookmark")
                                }
                                
                                Button(action: viewModel.showScriptureTagging) {
                                    Image(systemName: "book")
                                }
                                
                                Spacer()
                            }
                        }
                }
                
                // Floating action buttons
                if showFloatingButtons {
                    VStack(spacing: 16) {
                        Button(action: viewModel.addHighlight) {
                            Label("Highlight", systemImage: "highlighter")
                                .padding(8)
                                .background(Circle().fill(Color.yellow))
                                .foregroundColor(.black)
                        }
                        
                        Button(action: viewModel.addBookmark) {
                            Label("Bookmark", systemImage: "bookmark")
                                .padding(8)
                                .background(Circle().fill(Color.blue))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: viewModel.showScriptureTagging) {
                            Label("Scripture", systemImage: "book")
                                .padding(8)
                                .background(Circle().fill(Color.green))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .transition(.move(edge: .trailing))
                }
                
                // Toggle button for floating actions
                Button(action: {
                    withAnimation {
                        showFloatingButtons.toggle()
                    }
                }) {
                    Image(systemName: showFloatingButtons ? "xmark.circle.fill" : "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 3)
                }
                .padding()
            }
        }
        .onAppear {
            // Load or create notes for current recording if available
            if let recordingId = recordingManager.currentRecordingId {
                viewModel.loadOrCreateNote(for: recordingId)
            }
        }
        .sheet(isPresented: $viewModel.showingScriptureSheet) {
            ScriptureTaggingView { reference in
                viewModel.addScriptureReference(reference)
            }
        }
    }
}

#Preview {
    // Create a model container for SwiftData
    let modelContainer = try! ModelContainer(for: SermonNote.self)
    
    // Set up the view model with the model context
    let viewModel = NotesViewModel(modelContext: modelContainer.mainContext)
    
    // Set up recording manager
    let recordingManager = RecordingManager.shared
    
    // Mock recording started
    recordingManager.startRecording(serviceType: "Sunday Service")
    
    return NotesView(viewModel: viewModel, recordingManager: recordingManager)
} 