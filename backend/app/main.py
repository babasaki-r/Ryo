"""FastAPI Main Application"""
from fastapi import FastAPI, HTTPException, UploadFile, File, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional
import os
from pathlib import Path
import logging

from app.services.pdf_service import PDFService
from app.services.translation_service import TranslationService
from app.models.document import DocumentResponse, TranslationResponse

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="PDF Translation API",
    description="API for translating PDF equipment specifications from English to Japanese",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS Configuration
cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:5173,http://localhost:3000").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
pdf_service = PDFService()
translation_service = TranslationService()

# Ensure upload directory exists
UPLOAD_DIR = Path(os.getenv("UPLOAD_DIR", "./uploads"))
UPLOAD_DIR.mkdir(exist_ok=True)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "PDF Translation API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "pdf-translation-api"}


@app.post("/api/v1/upload", response_model=DocumentResponse)
async def upload_pdf(file: UploadFile = File(...)):
    """
    Upload a PDF file for translation

    Args:
        file: PDF file to upload

    Returns:
        DocumentResponse with document ID and extracted text
    """
    try:
        # Validate file type
        if not file.filename.endswith('.pdf'):
            raise HTTPException(status_code=400, detail="Only PDF files are accepted")

        # Validate file size
        max_size = int(os.getenv("MAX_FILE_SIZE", 10485760))  # 10MB default
        contents = await file.read()
        if len(contents) > max_size:
            raise HTTPException(
                status_code=400,
                detail=f"File size exceeds maximum allowed size of {max_size} bytes"
            )

        # Save file
        file_path = UPLOAD_DIR / file.filename
        with open(file_path, "wb") as f:
            f.write(contents)

        logger.info(f"Uploaded file: {file.filename}")

        # Extract text from PDF
        extracted_text = pdf_service.extract_text(str(file_path))

        # Create document record
        document_id = pdf_service.create_document_id(file.filename)

        return DocumentResponse(
            document_id=document_id,
            filename=file.filename,
            status="uploaded",
            extracted_text=extracted_text[:500],  # Preview only
            page_count=pdf_service.get_page_count(str(file_path))
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error uploading file: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")


@app.post("/api/v1/translate/{document_id}", response_model=TranslationResponse)
async def translate_document(
    document_id: str,
    source_lang: str = "en",
    target_lang: str = "ja"
):
    """
    Translate a previously uploaded document

    Args:
        document_id: Document identifier
        source_lang: Source language code (default: en)
        target_lang: Target language code (default: ja)

    Returns:
        TranslationResponse with translated text
    """
    try:
        # Find document file
        document_path = pdf_service.get_document_path(document_id, UPLOAD_DIR)
        if not document_path:
            raise HTTPException(status_code=404, detail="Document not found")

        # Extract text
        extracted_text = pdf_service.extract_text(document_path)

        logger.info(f"Translating document: {document_id}")

        # Translate text
        translated_text = await translation_service.translate(
            text=extracted_text,
            source_lang=source_lang,
            target_lang=target_lang
        )

        return TranslationResponse(
            document_id=document_id,
            original_text=extracted_text,
            translated_text=translated_text,
            source_lang=source_lang,
            target_lang=target_lang,
            status="completed"
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error translating document: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Translation error: {str(e)}")


@app.get("/api/v1/documents")
async def list_documents():
    """
    List all uploaded documents

    Returns:
        List of documents with metadata
    """
    try:
        documents = []
        for file_path in UPLOAD_DIR.glob("*.pdf"):
            documents.append({
                "filename": file_path.name,
                "document_id": pdf_service.create_document_id(file_path.name),
                "size": file_path.stat().st_size,
                "created_at": file_path.stat().st_ctime
            })

        return {"documents": documents, "count": len(documents)}

    except Exception as e:
        logger.error(f"Error listing documents: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error listing documents: {str(e)}")


@app.delete("/api/v1/documents/{document_id}")
async def delete_document(document_id: str):
    """
    Delete a document

    Args:
        document_id: Document identifier

    Returns:
        Success message
    """
    try:
        document_path = pdf_service.get_document_path(document_id, UPLOAD_DIR)
        if not document_path:
            raise HTTPException(status_code=404, detail="Document not found")

        os.remove(document_path)
        logger.info(f"Deleted document: {document_id}")

        return {"message": "Document deleted successfully", "document_id": document_id}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting document: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error deleting document: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=os.getenv("API_HOST", "0.0.0.0"),
        port=int(os.getenv("API_PORT", 8000)),
        reload=os.getenv("API_RELOAD", "true").lower() == "true"
    )
