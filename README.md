# PDF Translation App - 設備仕様書翻訳アプリ

English PDF equipment specification translator with React + FastAPI + Swift native iOS app.

## 🌟 Features

- 📄 PDF upload and parsing
- 🌐 English to Japanese translation
- 📱 Native iOS app (Swift)
- 💻 Web interface (React)
- ⚡ Fast API backend (FastAPI)
- 🎯 Specialized for equipment specifications

## 🏗️ Architecture

```
Ryo/
├── backend/          # FastAPI backend
│   ├── app/
│   │   ├── api/      # API endpoints
│   │   ├── services/ # Business logic (PDF, translation)
│   │   └── models/   # Data models
│   └── requirements.txt
├── frontend/         # React web app
│   └── src/
└── ios/             # Swift iOS app
    └── PDFTranslator/
```

## 🚀 Tech Stack

### Backend
- **FastAPI**: Modern Python web framework
- **PyPDF2/pdfplumber**: PDF parsing
- **DeepL/Google Translate API**: Translation service
- **uvicorn**: ASGI server

### Frontend
- **React 18**: UI framework
- **TypeScript**: Type safety
- **Vite**: Build tool
- **React PDF**: PDF rendering
- **Tailwind CSS**: Styling

### iOS
- **Swift**: Native iOS development
- **SwiftUI**: Modern UI framework
- **PDFKit**: PDF rendering
- **Alamofire**: HTTP networking

## 📦 Installation

### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

### iOS Setup
1. Open `ios/PDFTranslator/PDFTranslator.xcodeproj` in Xcode
2. Select your development team
3. Build and run (Cmd+R)

## 🔧 Configuration

Create `.env` file in backend directory:
```env
TRANSLATION_API_KEY=your_api_key
TRANSLATION_SERVICE=deepl  # or google
API_HOST=0.0.0.0
API_PORT=8000
```

## 📱 Usage

### Web App
1. Access `http://localhost:5173`
2. Upload PDF file
3. View original and translated text side-by-side

### iOS App
1. Launch PDFTranslator app
2. Tap "Upload PDF" button
3. Select PDF from Files app
4. View translated document

## 🛠️ Development

### Backend API Endpoints
- `POST /api/v1/upload`: Upload PDF file
- `GET /api/v1/translate/{document_id}`: Get translation
- `GET /api/v1/documents`: List uploaded documents
- `GET /api/v1/download/{document_id}`: Download translated PDF

### Running Tests
```bash
# Backend
cd backend
pytest

# Frontend
cd frontend
npm test

# iOS
xcodebuild test -scheme PDFTranslator
```

## 📄 License

MIT License

## 👥 Contributors

Created for equipment specification translation needs.
