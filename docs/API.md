# API Documentation

Complete API reference for the PDF Translation backend.

## Base URL

```
http://localhost:8000
```

## Authentication

Currently, the API does not require authentication. For production use, implement JWT or API key authentication.

## Endpoints

### Health Check

Check if the API is running.

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "service": "pdf-translation-api"
}
```

---

### Upload PDF

Upload a PDF file for processing.

**Endpoint:** `POST /api/v1/upload`

**Content-Type:** `multipart/form-data`

**Parameters:**
- `file` (required): PDF file to upload

**Request Example:**
```bash
curl -X POST http://localhost:8000/api/v1/upload \
  -F "file=@/path/to/document.pdf"
```

**Response (200 OK):**
```json
{
  "document_id": "a1b2c3d4e5f6g7h8",
  "filename": "document.pdf",
  "status": "uploaded",
  "extracted_text": "Preview of extracted text...",
  "page_count": 10,
  "created_at": "2024-01-15T10:30:00"
}
```

**Error Responses:**

- `400 Bad Request`: Invalid file type or size
  ```json
  {
    "detail": "Only PDF files are accepted"
  }
  ```

- `500 Internal Server Error`: Processing error
  ```json
  {
    "detail": "Error processing file: [error message]"
  }
  ```

---

### Translate Document

Translate a previously uploaded document.

**Endpoint:** `POST /api/v1/translate/{document_id}`

**Path Parameters:**
- `document_id` (required): Document identifier from upload

**Query Parameters:**
- `source_lang` (optional): Source language code (default: "en")
- `target_lang` (optional): Target language code (default: "ja")

**Request Example:**
```bash
curl -X POST "http://localhost:8000/api/v1/translate/a1b2c3d4e5f6g7h8?source_lang=en&target_lang=ja"
```

**Response (200 OK):**
```json
{
  "document_id": "a1b2c3d4e5f6g7h8",
  "original_text": "Original English text here...",
  "translated_text": "翻訳された日本語テキストがここに...",
  "source_lang": "en",
  "target_lang": "ja",
  "status": "completed",
  "translated_at": "2024-01-15T10:31:00"
}
```

**Error Responses:**

- `404 Not Found`: Document not found
  ```json
  {
    "detail": "Document not found"
  }
  ```

- `500 Internal Server Error`: Translation error
  ```json
  {
    "detail": "Translation error: [error message]"
  }
  ```

---

### List Documents

Get a list of all uploaded documents.

**Endpoint:** `GET /api/v1/documents`

**Request Example:**
```bash
curl http://localhost:8000/api/v1/documents
```

**Response (200 OK):**
```json
{
  "documents": [
    {
      "filename": "document1.pdf",
      "document_id": "a1b2c3d4e5f6g7h8",
      "size": 1024000,
      "created_at": "1705315800.0"
    },
    {
      "filename": "document2.pdf",
      "document_id": "b2c3d4e5f6g7h8i9",
      "size": 2048000,
      "created_at": "1705315900.0"
    }
  ],
  "count": 2
}
```

---

### Delete Document

Delete a document from the system.

**Endpoint:** `DELETE /api/v1/documents/{document_id}`

**Path Parameters:**
- `document_id` (required): Document identifier

**Request Example:**
```bash
curl -X DELETE http://localhost:8000/api/v1/documents/a1b2c3d4e5f6g7h8
```

**Response (200 OK):**
```json
{
  "message": "Document deleted successfully",
  "document_id": "a1b2c3d4e5f6g7h8"
}
```

**Error Responses:**

- `404 Not Found`: Document not found
  ```json
  {
    "detail": "Document not found"
  }
  ```

---

## Data Models

### DocumentResponse

```typescript
{
  document_id: string      // Unique document identifier
  filename: string         // Original filename
  status: string          // Processing status
  extracted_text: string  // Preview of extracted text
  page_count: number      // Number of pages
  created_at?: string     // ISO 8601 timestamp
}
```

### TranslationResponse

```typescript
{
  document_id: string       // Document identifier
  original_text: string     // Original text from PDF
  translated_text: string   // Translated text
  source_lang: string       // Source language code
  target_lang: string       // Target language code
  status: string           // Translation status
  translated_at?: string   // ISO 8601 timestamp
}
```

### Document

```typescript
{
  document_id: string     // Unique identifier
  filename: string        // Original filename
  size?: number          // File size in bytes
  created_at?: string    // Unix timestamp
}
```

## Language Codes

Supported language codes:

| Code | Language |
|------|----------|
| en   | English  |
| ja   | Japanese |
| zh   | Chinese  |
| ko   | Korean   |
| de   | German   |
| fr   | French   |
| es   | Spanish  |
| it   | Italian  |
| pt   | Portuguese |
| ru   | Russian  |

## Rate Limits

No rate limiting is currently implemented. For production use:

- Implement rate limiting per IP/user
- Set appropriate quotas based on translation API limits
- Consider caching translated documents

## Error Handling

All errors follow this format:

```json
{
  "detail": "Error description here"
}
```

HTTP Status Codes:
- `200 OK`: Successful request
- `400 Bad Request`: Invalid input
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

## Interactive Documentation

FastAPI provides interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## Code Examples

### Python

```python
import requests

# Upload PDF
with open('document.pdf', 'rb') as f:
    response = requests.post(
        'http://localhost:8000/api/v1/upload',
        files={'file': f}
    )
    doc = response.json()
    document_id = doc['document_id']

# Translate
response = requests.post(
    f'http://localhost:8000/api/v1/translate/{document_id}',
    params={'source_lang': 'en', 'target_lang': 'ja'}
)
translation = response.json()
print(translation['translated_text'])
```

### JavaScript

```javascript
// Upload PDF
const formData = new FormData();
formData.append('file', fileInput.files[0]);

const uploadResponse = await fetch('http://localhost:8000/api/v1/upload', {
  method: 'POST',
  body: formData
});
const doc = await uploadResponse.json();

// Translate
const translateResponse = await fetch(
  `http://localhost:8000/api/v1/translate/${doc.document_id}?source_lang=en&target_lang=ja`,
  { method: 'POST' }
);
const translation = await translateResponse.json();
console.log(translation.translated_text);
```

### Swift

```swift
// Upload PDF
let url = URL(string: "http://localhost:8000/api/v1/upload")!
var request = URLRequest(url: url)
request.httpMethod = "POST"

let boundary = UUID().uuidString
request.setValue("multipart/form-data; boundary=\(boundary)",
                 forHTTPHeaderField: "Content-Type")

// ... create multipart body ...

let (data, _) = try await URLSession.shared.data(for: request)
let doc = try JSONDecoder().decode(DocumentResponse.self, from: data)

// Translate
let translateURL = URL(string: "http://localhost:8000/api/v1/translate/\(doc.documentId)?source_lang=en&target_lang=ja")!
var translateRequest = URLRequest(url: translateURL)
translateRequest.httpMethod = "POST"

let (translateData, _) = try await URLSession.shared.data(for: translateRequest)
let translation = try JSONDecoder().decode(Translation.self, from: translateData)
print(translation.translatedText)
```
