import SwiftUI

struct ServiceTypeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSelect: (String) -> Void
    
    // Service types from the PRD
    private let serviceTypes = [
        "Sunday Service",
        "Bible Study",
        "Midweek",
        "Conference",
        "Guest Speaker"
    ]
    
    // Optional metadata
    @State private var speaker = ""
    @State private var title = ""
    @State private var scripture = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Service type selection
                VStack(alignment: .leading, spacing: 5) {
                    Text("Service Type")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(serviceTypes, id: \.self) { type in
                                ServiceTypeButton(type: type) {
                                    onSelect(type)
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Divider()
                
                // Optional metadata
                VStack(alignment: .leading, spacing: 16) {
                    Text("Optional Information")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Speaker
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Speaker")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g., Pastor John Smith", text: $speaker)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Title
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Title")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g., The Good Shepherd", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Scripture
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Main Scripture")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g., John 10:1-18", text: $scripture)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Start recording button
                Button {
                    // Include metadata in the selection
                    var serviceInfo = "Sunday Service" // Default
                    
                    // Add metadata if available
                    var metadataItems = [String]()
                    if !speaker.isEmpty { metadataItems.append("Speaker: \(speaker)") }
                    if !title.isEmpty { metadataItems.append("Title: \(title)") }
                    if !scripture.isEmpty { metadataItems.append("Scripture: \(scripture)") }
                    
                    if !metadataItems.isEmpty {
                        serviceInfo += " | " + metadataItems.joined(separator: " | ")
                    }
                    
                    onSelect(serviceInfo)
                    dismiss()
                } label: {
                    Text("Start Recording")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("New Recording")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ServiceTypeButton: View {
    let type: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(backgroundColor)
                    .clipShape(Circle())
                
                Text(type)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 80)
            }
        }
    }
    
    // Get appropriate icon and color for each service type
    private var iconName: String {
        switch type {
        case "Sunday Service":
            return "sun.max.fill"
        case "Bible Study":
            return "book.fill"
        case "Midweek":
            return "calendar.badge.clock"
        case "Conference":
            return "person.3.fill"
        case "Guest Speaker":
            return "person.fill.questionmark"
        default:
            return "mic.fill"
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case "Sunday Service":
            return .blue
        case "Bible Study":
            return .green
        case "Midweek":
            return .orange
        case "Conference":
            return .purple
        case "Guest Speaker":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    ServiceTypeSelectionView { serviceType in
        print("Selected: \(serviceType)")
    }
} 