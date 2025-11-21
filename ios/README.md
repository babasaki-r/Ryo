# PDF Translator iOS App

Native iOS application for translating English PDF equipment specifications to Japanese.

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

## Features

- PDF file selection and upload
- Real-time translation display
- Side-by-side original and translated view
- Document management
- Offline viewing of translated documents

## Setup

1. Open `PDFTranslator.xcodeproj` in Xcode
2. Configure your development team in Signing & Capabilities
3. Update API endpoint in `Config.swift`
4. Build and run (Cmd+R)

## Project Structure

```
PDFTranslator/
├── Views/              # SwiftUI views
│   ├── ContentView.swift
│   ├── DocumentListView.swift
│   ├── PDFUploadView.swift
│   └── TranslationView.swift
├── Models/            # Data models
│   ├── Document.swift
│   └── Translation.swift
├── Services/          # API and business logic
│   ├── APIService.swift
│   ├── PDFService.swift
│   └── TranslationService.swift
├── Resources/         # Assets and resources
└── PDFTranslatorApp.swift
```

## Configuration

Create a `Config.swift` file with your API endpoint:

```swift
enum Config {
    static let apiBaseURL = "http://localhost:8000"
    // For production: use your deployed API URL
}
```

## Usage

1. Launch the app
2. Tap the "Upload PDF" button
3. Select a PDF file from Files app
4. Wait for translation to complete
5. View original and translated text side-by-side

## Architecture

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for API calls
- **PDFKit**: Native PDF rendering
- **URLSession**: HTTP networking

## License

MIT License
