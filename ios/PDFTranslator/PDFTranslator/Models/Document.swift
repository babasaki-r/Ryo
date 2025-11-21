import Foundation

struct Document: Identifiable, Codable, Hashable {
    let id: String
    let filename: String
    let size: Int?
    let createdAt: String?
    let pageCount: Int?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id = "document_id"
        case filename
        case size
        case createdAt = "created_at"
        case pageCount = "page_count"
        case status
    }
}

struct DocumentResponse: Codable {
    let documentId: String
    let filename: String
    let status: String
    let extractedText: String
    let pageCount: Int
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case documentId = "document_id"
        case filename
        case status
        case extractedText = "extracted_text"
        case pageCount = "page_count"
        case createdAt = "created_at"
    }
}

struct DocumentListResponse: Codable {
    let documents: [Document]
    let count: Int
}
