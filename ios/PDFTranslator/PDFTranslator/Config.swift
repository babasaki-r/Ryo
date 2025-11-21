import Foundation

enum Config {
    // API Configuration
    static let apiBaseURL = "http://localhost:8000"

    // For production, replace with your deployed API URL
    // static let apiBaseURL = "https://your-api-domain.com"

    // API Endpoints
    static let uploadEndpoint = "/api/v1/upload"
    static let translateEndpoint = "/api/v1/translate"
    static let documentsEndpoint = "/api/v1/documents"

    // App Configuration
    static let maxFileSize: Int64 = 10 * 1024 * 1024 // 10MB
    static let supportedFileTypes = ["pdf"]

    // Translation Settings
    static let defaultSourceLanguage = "en"
    static let defaultTargetLanguage = "ja"
}
