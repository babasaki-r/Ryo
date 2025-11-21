import SwiftUI

struct ContentView: View {
    @EnvironmentObject var documentStore: DocumentStore
    @State private var selectedDocument: Document?
    @State private var showingDocumentPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView

                // Main Content
                if documentStore.documents.isEmpty && !documentStore.isLoading {
                    emptyStateView
                } else {
                    documentListView
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPickerView { url in
                    uploadDocument(url: url)
                }
            }

            // Detail View
            if let document = selectedDocument {
                TranslationView(document: document)
            } else {
                placeholderView
            }
        }
        .navigationViewStyle(.automatic)
        .onAppear {
            documentStore.fetchDocuments()
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "globe")
                    .font(.title)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text("PDF Translator")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("設備仕様書翻訳")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { showingDocumentPicker = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .padding()

            Divider()
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Document List View

    private var documentListView: some View {
        List(documentStore.documents, selection: $selectedDocument) { document in
            DocumentRowView(document: document)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedDocument = document
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        documentStore.deleteDocument(document.id)
                        if selectedDocument?.id == document.id {
                            selectedDocument = nil
                        }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
        }
        .listStyle(.plain)
        .refreshable {
            documentStore.fetchDocuments()
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("ドキュメントがありません")
                .font(.title3)
                .foregroundColor(.secondary)

            Text("PDFファイルをアップロードして翻訳を開始")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: { showingDocumentPicker = true }) {
                Label("PDFをアップロード", systemImage: "plus.circle")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Placeholder View

    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray)

            Text("ドキュメントを選択")
                .font(.title3)
                .foregroundColor(.secondary)

            Text("左側のリストからPDFを選択してください")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Upload Document

    private func uploadDocument(url: URL) {
        documentStore.uploadDocument(fileURL: url) { result in
            switch result {
            case .success(let response):
                print("Uploaded: \(response.filename)")
            case .failure(let error):
                print("Upload error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Document Row View

struct DocumentRowView: View {
    let document: Document

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(document.filename)
                    .font(.body)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    if let size = document.size {
                        Text(formatFileSize(size))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if let pageCount = document.pageCount {
                        Text("\(pageCount) ページ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatFileSize(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024.0
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        }
        return String(format: "%.1f MB", kb / 1024.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DocumentStore())
    }
}
