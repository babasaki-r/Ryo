import SwiftUI

@main
struct PDFTranslatorApp: App {
    @StateObject private var documentStore = DocumentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(documentStore)
        }
    }
}
