"""Document and Translation Models"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class DocumentResponse(BaseModel):
    """Response model for uploaded documents"""
    document_id: str = Field(..., description="Unique document identifier")
    filename: str = Field(..., description="Original filename")
    status: str = Field(..., description="Processing status")
    extracted_text: str = Field(..., description="Preview of extracted text")
    page_count: int = Field(..., description="Number of pages in PDF")
    created_at: Optional[datetime] = Field(default_factory=datetime.now)


class TranslationRequest(BaseModel):
    """Request model for translation"""
    text: str = Field(..., description="Text to translate")
    source_lang: str = Field(default="en", description="Source language code")
    target_lang: str = Field(default="ja", description="Target language code")


class TranslationResponse(BaseModel):
    """Response model for translation"""
    document_id: str = Field(..., description="Document identifier")
    original_text: str = Field(..., description="Original text")
    translated_text: str = Field(..., description="Translated text")
    source_lang: str = Field(..., description="Source language")
    target_lang: str = Field(..., description="Target language")
    status: str = Field(..., description="Translation status")
    translated_at: Optional[datetime] = Field(default_factory=datetime.now)


class PageTranslation(BaseModel):
    """Translation for a single page"""
    page_number: int = Field(..., description="Page number")
    original_text: str = Field(..., description="Original text from page")
    translated_text: str = Field(..., description="Translated text")


class DocumentMetadata(BaseModel):
    """Document metadata"""
    filename: str
    document_id: str
    size: int
    page_count: int
    created_at: datetime
    status: str = "pending"
