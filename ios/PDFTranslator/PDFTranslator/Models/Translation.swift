import Foundation

struct Translation: Codable, Identifiable {
    let id: String
    let originalText: String
    let translatedText: String
    let sourceLang: String
    let targetLang: String
    let status: String
    let translatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "document_id"
        case originalText = "original_text"
        case translatedText = "translated_text"
        case sourceLang = "source_lang"
        case targetLang = "target_lang"
        case status
        case translatedAt = "translated_at"
    }
}

struct TranslationRequest: Codable {
    let sourceLang: String
    let targetLang: String

    enum CodingKeys: String, CodingKey {
        case sourceLang = "source_lang"
        case targetLang = "target_lang"
    }
}
