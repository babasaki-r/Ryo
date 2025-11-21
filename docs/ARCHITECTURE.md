# Architecture Overview

Technical architecture and design decisions for the PDF Translation App.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Client Layer                         │
├──────────────────┬──────────────────┬──────────────────────┤
│   React Web App  │   iOS Native App │   Future Clients     │
│   (Port 5173)    │   (Swift/SwiftUI)│                      │
└────────┬─────────┴────────┬─────────┴──────────────────────┘
         │                  │
         └─────────┬────────┘
                   │ HTTP/REST
         ┌─────────▼─────────┐
         │   Nginx Proxy     │
         │   (Port 80)       │
         └─────────┬─────────┘
                   │
         ┌─────────▼─────────────────────────────────────┐
         │         FastAPI Backend (Port 8000)           │
         ├───────────────────────────────────────────────┤
         │  ┌────────────┐  ┌─────────────┐             │
         │  │ API Layer  │  │  Services   │             │
         │  │            │  │             │             │
         │  │ - Routes   │  │ - PDF       │             │
         │  │ - Models   │  │ - Translation│            │
         │  └────────────┘  └─────────────┘             │
         └───────────────────┬───────────────────────────┘
                             │
         ┌───────────────────┴───────────────────────────┐
         │                                               │
    ┌────▼─────┐                              ┌────────▼────────┐
    │ File     │                              │  Translation    │
    │ Storage  │                              │  Service API    │
    │ (Local)  │                              │  (DeepL/Google) │
    └──────────┘                              └─────────────────┘
```

## Component Architecture

### Backend (FastAPI)

#### Layer Structure

```
backend/
├── app/
│   ├── main.py              # Application entry point
│   ├── api/                 # API endpoints (future organization)
│   ├── models/              # Pydantic data models
│   │   └── document.py      # Document & Translation models
│   └── services/            # Business logic
│       ├── pdf_service.py   # PDF processing
│       └── translation_service.py  # Translation API integration
```

#### Key Components

**1. Main Application (main.py)**
- FastAPI app initialization
- CORS middleware configuration
- Route definitions
- Error handling

**2. PDF Service**
- Text extraction using pdfplumber (primary) and PyPDF2 (fallback)
- Page-by-page processing
- Metadata extraction
- Document ID generation

**3. Translation Service**
- Multi-provider support (DeepL, Google Translate)
- Async translation processing
- Text chunking for API limits
- Mock translation for development

**4. Data Models**
- Request/Response validation using Pydantic
- Type safety
- Automatic API documentation

### Frontend (React + TypeScript)

#### Component Structure

```
frontend/src/
├── App.tsx                  # Main application component
├── components/
│   ├── FileUpload.tsx       # Drag-and-drop PDF upload
│   ├── DocumentList.tsx     # List of uploaded documents
│   └── TranslationView.tsx  # Side-by-side translation view
├── services/
│   └── api.ts              # API client with axios
└── types/
    └── index.ts            # TypeScript type definitions
```

#### Key Features

**1. File Upload Component**
- React Dropzone for drag-and-drop
- File validation (type, size)
- Progress indication
- Error handling

**2. Document List Component**
- Real-time document list
- Document selection
- Delete functionality
- Refresh capability

**3. Translation View Component**
- Side-by-side original and translated text
- Copy to clipboard
- Text highlighting
- Responsive layout

### iOS App (Swift + SwiftUI)

#### Architecture Pattern: MVVM

```
ios/PDFTranslator/
├── PDFTranslatorApp.swift   # App entry point
├── Config.swift             # Configuration
├── Models/                  # Data models
│   ├── Document.swift
│   └── Translation.swift
├── Services/                # Business logic
│   ├── APIService.swift     # Networking
│   └── DocumentStore.swift  # State management
└── Views/                   # UI components
    ├── ContentView.swift
    ├── TranslationView.swift
    └── DocumentPickerView.swift
```

#### Key Components

**1. APIService**
- Combine-based networking
- URLSession for HTTP
- Multipart form data upload
- Error handling

**2. DocumentStore (ObservableObject)**
- Centralized state management
- Document list management
- Upload/delete operations
- Reactive UI updates

**3. SwiftUI Views**
- Declarative UI
- Native iOS design patterns
- Document picker integration
- Responsive layouts

## Data Flow

### Document Upload Flow

```
1. User selects PDF file
   ↓
2. Client validates file (type, size)
   ↓
3. Client sends multipart/form-data POST to /api/v1/upload
   ↓
4. Backend receives and saves file
   ↓
5. Backend extracts text using pdfplumber
   ↓
6. Backend returns DocumentResponse with document_id
   ↓
7. Client updates UI with new document
```

### Translation Flow

```
1. User selects document from list
   ↓
2. Client sends POST to /api/v1/translate/{document_id}
   ↓
3. Backend retrieves document from storage
   ↓
4. Backend extracts full text from PDF
   ↓
5. Backend splits text into chunks (if needed)
   ↓
6. Backend calls translation API (DeepL/Google)
   ↓
7. Backend combines translated chunks
   ↓
8. Backend returns TranslationResponse
   ↓
9. Client displays original and translated text
```

## Technology Stack

### Backend

| Technology | Purpose | Version |
|------------|---------|---------|
| Python | Programming language | 3.11+ |
| FastAPI | Web framework | 0.104+ |
| Uvicorn | ASGI server | 0.24+ |
| Pydantic | Data validation | 2.5+ |
| PyPDF2 | PDF processing (fallback) | 3.0+ |
| pdfplumber | PDF processing (primary) | 0.10+ |
| DeepL | Translation API | 1.17+ |

### Frontend

| Technology | Purpose | Version |
|------------|---------|---------|
| React | UI framework | 18.2+ |
| TypeScript | Type safety | 5.2+ |
| Vite | Build tool | 5.0+ |
| Axios | HTTP client | 1.6+ |
| Tailwind CSS | Styling | 3.3+ |
| React Dropzone | File upload | 14.2+ |

### iOS

| Technology | Purpose | Version |
|------------|---------|---------|
| Swift | Programming language | 5.5+ |
| SwiftUI | UI framework | iOS 15+ |
| Combine | Reactive programming | iOS 15+ |
| URLSession | Networking | iOS 15+ |
| PDFKit | PDF rendering | iOS 15+ |

## Design Decisions

### 1. FastAPI for Backend

**Reasons:**
- Automatic API documentation (OpenAPI/Swagger)
- Built-in data validation with Pydantic
- Async support for better performance
- Type hints for better code quality
- Easy to learn and use

### 2. Separate Translation Service

**Reasons:**
- Provider flexibility (DeepL, Google, etc.)
- Easy to swap or add providers
- Mock mode for development
- Centralized error handling

### 3. SwiftUI for iOS

**Reasons:**
- Modern, declarative UI
- Less boilerplate than UIKit
- Better preview support
- Native performance
- Future-proof

### 4. Docker for Deployment

**Reasons:**
- Consistent environments
- Easy deployment
- Service isolation
- Scalability
- Simple orchestration with Docker Compose

## Security Considerations

### Current Implementation

1. **File Upload**
   - File type validation (PDF only)
   - File size limits (10MB default)
   - Temporary file storage

2. **CORS**
   - Configured allowed origins
   - Credential support enabled

3. **iOS**
   - NSAppTransportSecurity for local development
   - Secure file handling

### Production Recommendations

1. **Authentication & Authorization**
   - Implement JWT tokens
   - API key authentication
   - Role-based access control

2. **File Security**
   - Virus scanning
   - Encrypted storage
   - Automatic cleanup

3. **API Security**
   - Rate limiting
   - Request validation
   - SQL injection prevention (if using SQL)

4. **Network Security**
   - HTTPS only
   - Certificate pinning (iOS)
   - Secure API keys

## Performance Optimization

### Backend

1. **Async Processing**
   - Use async/await for I/O operations
   - Background task queues for long translations

2. **Caching**
   - Cache translated documents
   - Redis for distributed caching

3. **Database**
   - Index document IDs
   - Use PostgreSQL for production

### Frontend

1. **Code Splitting**
   - Lazy loading components
   - Dynamic imports

2. **Asset Optimization**
   - Image optimization
   - Minification
   - Compression

3. **API Optimization**
   - Request deduplication
   - Pagination
   - Optimistic updates

### iOS

1. **Networking**
   - Request cancellation
   - Image caching
   - Background downloads

2. **UI Performance**
   - List virtualization
   - Image lazy loading
   - Debounced search

## Scalability

### Horizontal Scaling

```
              Load Balancer
                    |
      ┌─────────────┼─────────────┐
      │             │             │
   Backend 1    Backend 2    Backend 3
      │             │             │
      └─────────────┼─────────────┘
                    |
              Shared Storage
           (S3, NFS, Database)
```

### Recommended Improvements

1. **File Storage**
   - Move to S3 or object storage
   - CDN for static files

2. **Database**
   - PostgreSQL with replicas
   - Connection pooling

3. **Translation**
   - Queue system (Celery, RabbitMQ)
   - Background workers
   - Result caching

4. **Monitoring**
   - Application metrics
   - Error tracking
   - Performance monitoring

## Future Enhancements

1. **Features**
   - Batch translation
   - Custom translation models
   - OCR support for scanned PDFs
   - Translation history

2. **Technical**
   - GraphQL API
   - WebSocket for real-time updates
   - Kubernetes deployment
   - Microservices architecture

3. **Mobile**
   - Android app
   - Offline mode
   - Push notifications
