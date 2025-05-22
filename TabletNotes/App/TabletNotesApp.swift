/* TabletNotesApp */

import SwiftUI
import SwiftData

@main
struct TabletNotesApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var recordingManager = RecordingManager.shared
    
    // Configure the model container for SwiftData
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SermonNote.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .modelContainer(sharedModelContainer)
                    .environmentObject(recordingManager)
            } else {
                LoginView(authService: authService)
                    .overlay(alignment: .bottom) {
                        if !authService.isAuthenticated {
                            Button("Skip Login (Test Account)") {
                                authService.signInWithTestAccount()
                            }
                            .buttonStyle(.bordered)
                            .padding(.bottom, 30)
                        }
                    }
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @Environment(\.modelContext) private var modelContext
    @State private var notesViewModel: NotesViewModel?
    @State private var showServiceTypeSelection = false
    
    var body: some View {
        TabView {
            // Sermons Tab
            Text("Sermons")
                .tabItem {
                    Label("Sermons", systemImage: "book.fill")
                }
            
            // Record Tab
            ZStack {
                if recordingManager.recordingState == .idle {
                    // Show empty state when not recording
                    VStack {
                        Text("Ready to Record")
                            .font(.title)
                            .padding()
                        
                        Button {
                            showServiceTypeSelection = true
                        } label: {
                            Label("Start Recording", systemImage: "mic.fill")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    // Show notes view when recording
                    if let viewModel = notesViewModel {
                        NotesView(viewModel: viewModel, recordingManager: recordingManager)
                    } else {
                        ProgressView("Loading notes...")
                    }
                }
            }
            .tabItem {
                Label("Record", systemImage: "mic.fill")
            }
            
            // Account Tab
            Text("Account")
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
        .sheet(isPresented: $showServiceTypeSelection) {
            ServiceTypeSelectionView { serviceType in
                // Start recording with selected service type
                recordingManager.startRecording(serviceType: serviceType)
                
                // Initialize notes for this recording session
                if let recordingId = recordingManager.currentRecordingId {
                    // Create view model with the model context
                    let viewModel = NotesViewModel(modelContext: modelContext)
                    viewModel.loadOrCreateNote(for: recordingId)
                    notesViewModel = viewModel
                }
            }
        }
        .onAppear {
            // Initialize the view model with model context
            notesViewModel = NotesViewModel(modelContext: modelContext)
        }
    }
}
