import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

class APIService {
    static let shared = APIService()
    private let baseURL: String
    private let session: URLSession

    private init() {
        self.baseURL = Config.apiBaseURL
        self.session = URLSession.shared
    }

    // MARK: - Upload PDF

    func uploadPDF(fileURL: URL) -> AnyPublisher<DocumentResponse, APIError> {
        guard let url = URL(string: "\(baseURL)\(Config.uploadEndpoint)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let fileData = try? Data(contentsOf: fileURL) else {
            return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
        }

        let body = createMultipartBody(
            boundary: boundary,
            fileData: fileData,
            fileName: fileURL.lastPathComponent,
            mimeType: "application/pdf"
        )
        request.httpBody = body

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                if httpResponse.statusCode != 200 {
                    if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let detail = errorDict["detail"] as? String {
                        throw APIError.serverError(detail)
                    }
                    throw APIError.serverError("HTTP \(httpResponse.statusCode)")
                }

                return data
            }
            .decode(type: DocumentResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    return APIError.decodingError(error)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Translate Document

    func translateDocument(
        documentId: String,
        sourceLang: String = Config.defaultSourceLanguage,
        targetLang: String = Config.defaultTargetLanguage
    ) -> AnyPublisher<Translation, APIError> {
        var components = URLComponents(string: "\(baseURL)\(Config.translateEndpoint)/\(documentId)")
        components?.queryItems = [
            URLQueryItem(name: "source_lang", value: sourceLang),
            URLQueryItem(name: "target_lang", value: targetLang)
        ]

        guard let url = components?.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                if httpResponse.statusCode != 200 {
                    if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let detail = errorDict["detail"] as? String {
                        throw APIError.serverError(detail)
                    }
                    throw APIError.serverError("HTTP \(httpResponse.statusCode)")
                }

                return data
            }
            .decode(type: Translation.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    return APIError.decodingError(error)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - List Documents

    func listDocuments() -> AnyPublisher<DocumentListResponse, APIError> {
        guard let url = URL(string: "\(baseURL)\(Config.documentsEndpoint)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw APIError.invalidResponse
                }
                return data
            }
            .decode(type: DocumentListResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    return APIError.decodingError(error)
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Delete Document

    func deleteDocument(documentId: String) -> AnyPublisher<Void, APIError> {
        guard let url = URL(string: "\(baseURL)\(Config.documentsEndpoint)/\(documentId)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        return session.dataTaskPublisher(for: request)
            .tryMap { _, response -> Void in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw APIError.invalidResponse
                }
                return ()
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Helper Methods

    private func createMultipartBody(
        boundary: String,
        fileData: Data,
        fileName: String,
        mimeType: String
    ) -> Data {
        var body = Data()

        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}
