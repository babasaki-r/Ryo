import SwiftUI
import Combine

struct TranslationView: View {
    let document: Document

    @State private var translation: Translation?
    @State private var isLoading = false
    @State private var error: String?
    @State private var showOriginal = true
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            if isLoading {
                loadingView
            } else if let error = error {
                errorView(message: error)
            } else if let translation = translation {
                translationContentView(translation: translation)
            } else {
                Text("翻訳を読み込んでいます...")
                    .foregroundColor(.secondary)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            loadTranslation()
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.filename)
                        .font(.headline)
                        .lineLimit(1)

                    Text("英語 → 日本語")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: loadTranslation) {
                    Image(systemName: "arrow.clockwise")
                        .font(.body)
                        .foregroundColor(.blue)
                }
                .disabled(isLoading)
            }
            .padding()

            Divider()
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("翻訳中...")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("数秒かかる場合があります")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("エラー")
                .font(.headline)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: loadTranslation) {
                Label("再試行", systemImage: "arrow.clockwise")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Translation Content View

    private func translationContentView(translation: Translation) -> some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("View", selection: $showOriginal) {
                Text("原文").tag(true)
                Text("翻訳").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()

            // Text Content
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if showOriginal {
                        textSection(
                            title: "原文 (英語)",
                            text: translation.originalText,
                            backgroundColor: Color(.systemGray6)
                        )
                    } else {
                        textSection(
                            title: "翻訳 (日本語)",
                            text: translation.translatedText,
                            backgroundColor: Color.blue.opacity(0.1)
                        )
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Text("ステータス: \(translation.status)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    copyToClipboard(showOriginal ? translation.originalText : translation.translatedText)
                }) {
                    Label("コピー", systemImage: "doc.on.doc")
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }

    // MARK: - Text Section

    private func textSection(title: String, text: String, backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor)
                .cornerRadius(8)
        }
    }

    // MARK: - Load Translation

    private func loadTranslation() {
        isLoading = true
        error = nil

        APIService.shared.translateDocument(documentId: document.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    self.error = error.localizedDescription
                }
            } receiveValue: { result in
                self.translation = result
            }
            .store(in: &cancellables)
    }

    // MARK: - Copy to Clipboard

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView(document: Document(
            id: "test123",
            filename: "sample.pdf",
            size: 1024000,
            createdAt: nil,
            pageCount: 5,
            status: "uploaded"
        ))
    }
}
