# Setup Guide - PDF Translation App

Complete setup guide for the PDF Translation application.

## Prerequisites

### For Backend Development
- Python 3.11+
- pip
- virtualenv (recommended)

### For Frontend Development
- Node.js 18+
- npm or yarn

### For iOS Development
- macOS with Xcode 14+
- Swift 5.5+
- iOS 15.0+ SDK

### For Docker Deployment
- Docker 20.10+
- Docker Compose 2.0+

## Quick Start with Docker

The fastest way to get started:

```bash
# 1. Clone the repository
git clone <repository-url>
cd Ryo

# 2. Setup environment variables
make env-setup
# Edit .env, backend/.env, and frontend/.env with your API keys

# 3. Build and start services
make build
make up

# 4. Access the application
# Frontend: http://localhost:80
# Backend API: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

## Local Development Setup

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

5. **Run development server**
   ```bash
   uvicorn app.main:app --reload
   ```

   The API will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your API endpoint
   ```

4. **Run development server**
   ```bash
   npm run dev
   ```

   The app will be available at `http://localhost:5173`

### iOS App Setup

1. **Navigate to iOS directory**
   ```bash
   cd ios/PDFTranslator
   ```

2. **Open in Xcode**
   ```bash
   open PDFTranslator.xcodeproj
   ```

3. **Configure API endpoint**
   - Open `Config.swift`
   - Update `apiBaseURL` with your backend URL
   - For local development: `http://localhost:8000`
   - For simulator: `http://127.0.0.1:8000` or your machine's IP

4. **Select development team**
   - In Xcode, select your project
   - Go to Signing & Capabilities
   - Select your development team

5. **Build and run**
   - Press Cmd+R or click the Play button
   - Select a simulator or connected device

## Translation API Configuration

### DeepL API

1. **Get API Key**
   - Sign up at [DeepL Pro](https://www.deepl.com/pro-api)
   - Get your API key from the dashboard

2. **Configure**
   ```bash
   # In backend/.env
   TRANSLATION_SERVICE=deepl
   DEEPL_API_KEY=your_api_key_here
   ```

### Google Translate API

1. **Setup Google Cloud Project**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project
   - Enable Cloud Translation API
   - Create service account and download credentials JSON

2. **Configure**
   ```bash
   # In backend/.env
   TRANSLATION_SERVICE=google
   GOOGLE_CREDENTIALS_PATH=/path/to/credentials.json
   ```

## Testing

### Backend Tests

```bash
cd backend
pytest
```

### Frontend Tests

```bash
cd frontend
npm test
```

## Production Deployment

### Docker Deployment

1. **Setup environment**
   ```bash
   cp .env.example .env
   # Edit with production values
   ```

2. **Build images**
   ```bash
   docker-compose build
   ```

3. **Start services**
   ```bash
   docker-compose up -d
   ```

4. **Check status**
   ```bash
   docker-compose ps
   docker-compose logs -f
   ```

### Environment Variables

#### Backend (.env)
```env
API_HOST=0.0.0.0
API_PORT=8000
TRANSLATION_SERVICE=deepl
DEEPL_API_KEY=your_key
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760
DATABASE_URL=sqlite:///./pdf_translator.db
```

#### Frontend (.env)
```env
VITE_API_URL=http://your-api-domain.com
```

## Troubleshooting

### Backend Issues

**Problem: PDF extraction fails**
- Ensure poppler-utils is installed
- Check PDF file is not corrupted
- Verify file size is within limits

**Problem: Translation fails**
- Verify API key is correct
- Check API quota/limits
- Review logs for detailed errors

### Frontend Issues

**Problem: Cannot connect to API**
- Verify API URL in .env
- Check CORS settings in backend
- Ensure backend is running

**Problem: File upload fails**
- Check file size limit
- Verify file is PDF format
- Check network connection

### iOS Issues

**Problem: Cannot connect to backend**
- For simulator, use `http://127.0.0.1:8000`
- For device, use your machine's IP address
- Ensure backend allows connections from your device
- Check NSAppTransportSecurity settings in Info.plist

**Problem: Document picker not working**
- Verify Info.plist has correct permissions
- Check UISupportsDocumentBrowser is enabled

## Useful Commands

### Docker Commands

```bash
# View logs
make logs

# Restart services
make restart

# Stop services
make down

# Clean up
make clean

# Access backend shell
make shell-backend

# Access frontend shell
make shell-frontend
```

### Development Commands

```bash
# Start backend dev server
make dev-backend

# Start frontend dev server
make dev-frontend

# Run backend tests
make test-backend

# Run frontend tests
make test-frontend
```

## Next Steps

1. [API Documentation](./API.md)
2. [Architecture Overview](./ARCHITECTURE.md)
3. [Contributing Guide](./CONTRIBUTING.md)
