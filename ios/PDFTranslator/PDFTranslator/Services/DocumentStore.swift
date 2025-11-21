import Foundation
import Combine

class DocumentStore: ObservableObject {
    @Published var documents: [Document] = []
    @Published var isLoading = false
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared

    func fetchDocuments() {
        isLoading = true
        error = nil

        apiService.listDocuments()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                self?.documents = response.documents
            }
            .store(in: &cancellables)
    }

    func uploadDocument(fileURL: URL, completion: @escaping (Result<DocumentResponse, APIError>) -> Void) {
        isLoading = true
        error = nil

        apiService.uploadPDF(fileURL: fileURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.error = error.localizedDescription
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] response in
                self?.fetchDocuments()
                completion(.success(response))
            }
            .store(in: &cancellables)
    }

    func deleteDocument(_ documentId: String) {
        apiService.deleteDocument(documentId: documentId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.documents.removeAll { $0.id == documentId }
            }
            .store(in: &cancellables)
    }
}
