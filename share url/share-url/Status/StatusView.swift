import SwiftUI
import share_api

struct StatusView<ViewModel: StatusViewModelProtocol>: View {
    @State private var isLoading = false
    @ObservedObject var viewModel: ViewModel
    @State private var hasLoaded = false
    @State private var selectedItem: DownloadItem?
    @State private var showDetailSheet = false
    @State private var showConfirmationDialog = false
    @Environment(\.colorScheme) var colorScheme
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if viewModel.downloadedItems.isEmpty {
                    emptyStateView
                } else {
                    downloadListView
                }
            }
            .navigationTitle("Downloads")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: refreshData) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        
                        Button(role: .destructive, action: {
                            showConfirmationDialog = true
                        }) {
                            Label("Clear History", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Sort by Date", action: {})
                        Button("Sort by Status", action: {})
                        Button("Sort by Title", action: {})
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear {
                if !hasLoaded {
                    hasLoaded = true
                    refreshData()
                }
            }
            .refreshable {
                await refreshDataAsync()
            }
            .sheet(isPresented: $showDetailSheet) {
                if let item = selectedItem {
                    downloadDetailView(item: item)
                }
            }
            .confirmationDialog(
                "Clear Download History",
                isPresented: $showConfirmationDialog,
                titleVisibility: .visible
            ) {
                Button("Clear History", role: .destructive) {
                    clearDownloadHistory()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear all download history. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Component Views
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Loading downloads...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 70))
                .foregroundColor(.secondary.opacity(0.7))
            
            Text(String(localized: "no_files_downloaded_yet"))
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: refreshData) {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
    }
    
    private var downloadListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.downloadedItems, id: \.started) { item in
                    downloadItemView(item: item)
                        .onTapGesture {
                            selectedItem = item
                            showDetailSheet = true
                        }
                }
            }
            .padding()
        }
    }
    
    private func downloadItemView(item: DownloadItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Status icon
                statusIcon(for: item.status)
                
                // Title
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            // Progress indicator
            if item.status.lowercased().contains("progress") {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle())
            }
            
            HStack {
                // Date info
                VStack(alignment: .leading, spacing: 4) {
                    Label {
                        Text(formatDate(item.started))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                    }
                    
                    if !item.status.lowercased().contains("progress") {
                        Label {
                            Text(formatDate(item.ended))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "flag.checkered")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Status badge
                Text(item.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: item.status).opacity(0.2))
                    .foregroundColor(statusColor(for: item.status))
                    .cornerRadius(8)
            }
            
            // Display resolution if available
            if let resolution = item.resolution, !resolution.isEmpty {
                HStack {
                    Label {
                        Text(resolution)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
    
    private func downloadDetailView(item: DownloadItem) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(item.title)
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Status section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            statusIcon(for: item.status)
                                .font(.title2)
                            
                            Text(item.status)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Resolution section (if available)
                    if let resolution = item.resolution, !resolution.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Resolution")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text(resolution)
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Timing section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Timing")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Started")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatDate(item.started))
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Ended")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatDate(item.ended))
                                    .font(.body)
                            }
                        }
                        
                        if item.status.lowercased().contains("error"), let errorMessage = item.errored {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Error")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(errorMessage)
                                    .font(.body)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Path section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("File Path")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(item.filePath)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(3)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Download Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showDetailSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func refreshData() {
        Task {
            await refreshDataAsync()
        }
    }
    
    func refreshDataAsync() async {
        isLoading = true
        await viewModel.fetchDownloadedItems()
        isLoading = false
    }
    
    func clearDownloadHistory() {
        isLoading = true
        Task {
            do {
                try await viewModel.clearDownloadHistory()
                await refreshDataAsync()
            } catch {
                print("Error clearing history: \(error)")
                // Show error toast or alert
            }
            isLoading = false
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        // Convert server date string to a more readable format
        // Implement proper date formatting based on your date format
        return dateString
    }
    
    func statusIcon(for status: String) -> some View {
        let lowercase = status.lowercased()
        
        let systemName: String
        let color: Color
        
        if lowercase.contains("error") {
            systemName = "xmark.circle.fill"
            color = .red
        } else if lowercase.contains("progress") {
            systemName = "arrow.triangle.2.circlepath"
            color = .orange
        } else if lowercase.contains("download") {
            systemName = "checkmark.circle.fill"
            color = .green
        } else {
            systemName = "questionmark.circle.fill"
            color = .gray
        }
        
        return Image(systemName: systemName)
            .foregroundColor(color)
    }
    
    func statusColor(for status: String) -> Color {
        let lowercase = status.lowercased()
        
        if lowercase.contains("error") {
            return .red
        } else if lowercase.contains("progress") {
            return .orange
        } else if lowercase.contains("download") {
            return .green
        } else {
            return .gray
        }
    }
}
