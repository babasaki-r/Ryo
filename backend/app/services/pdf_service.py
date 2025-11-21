"""PDF Processing Service"""
import PyPDF2
import pdfplumber
import hashlib
from pathlib import Path
from typing import List, Dict, Optional
import logging

logger = logging.getLogger(__name__)


class PDFService:
    """Service for handling PDF operations"""

    def extract_text(self, pdf_path: str) -> str:
        """
        Extract text from PDF file using pdfplumber for better accuracy

        Args:
            pdf_path: Path to PDF file

        Returns:
            Extracted text content
        """
        try:
            text_content = []

            with pdfplumber.open(pdf_path) as pdf:
                for page_num, page in enumerate(pdf.pages, 1):
                    text = page.extract_text()
                    if text:
                        text_content.append(f"--- Page {page_num} ---\n{text}\n")

            full_text = "\n".join(text_content)
            logger.info(f"Extracted {len(full_text)} characters from {pdf_path}")

            return full_text

        except Exception as e:
            logger.error(f"Error extracting text from PDF: {str(e)}")
            # Fallback to PyPDF2 if pdfplumber fails
            return self._extract_text_pypdf2(pdf_path)

    def _extract_text_pypdf2(self, pdf_path: str) -> str:
        """
        Fallback method using PyPDF2

        Args:
            pdf_path: Path to PDF file

        Returns:
            Extracted text content
        """
        try:
            text_content = []

            with open(pdf_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)

                for page_num in range(len(pdf_reader.pages)):
                    page = pdf_reader.pages[page_num]
                    text = page.extract_text()
                    if text:
                        text_content.append(f"--- Page {page_num + 1} ---\n{text}\n")

            return "\n".join(text_content)

        except Exception as e:
            logger.error(f"Error with PyPDF2 extraction: {str(e)}")
            raise

    def extract_text_by_page(self, pdf_path: str) -> List[Dict[str, any]]:
        """
        Extract text from PDF page by page

        Args:
            pdf_path: Path to PDF file

        Returns:
            List of dictionaries with page number and text
        """
        pages = []

        try:
            with pdfplumber.open(pdf_path) as pdf:
                for page_num, page in enumerate(pdf.pages, 1):
                    text = page.extract_text()
                    pages.append({
                        "page_number": page_num,
                        "text": text or "",
                        "width": page.width,
                        "height": page.height
                    })

            logger.info(f"Extracted {len(pages)} pages from {pdf_path}")
            return pages

        except Exception as e:
            logger.error(f"Error extracting pages: {str(e)}")
            raise

    def get_page_count(self, pdf_path: str) -> int:
        """
        Get number of pages in PDF

        Args:
            pdf_path: Path to PDF file

        Returns:
            Number of pages
        """
        try:
            with open(pdf_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                return len(pdf_reader.pages)
        except Exception as e:
            logger.error(f"Error getting page count: {str(e)}")
            return 0

    def create_document_id(self, filename: str) -> str:
        """
        Create unique document ID from filename

        Args:
            filename: Original filename

        Returns:
            Unique document identifier
        """
        hash_input = f"{filename}".encode('utf-8')
        return hashlib.md5(hash_input).hexdigest()[:16]

    def get_document_path(self, document_id: str, upload_dir: Path) -> Optional[str]:
        """
        Find document path by document ID

        Args:
            document_id: Document identifier
            upload_dir: Directory containing uploaded files

        Returns:
            Path to document or None if not found
        """
        for pdf_file in upload_dir.glob("*.pdf"):
            if self.create_document_id(pdf_file.name) == document_id:
                return str(pdf_file)
        return None

    def get_pdf_metadata(self, pdf_path: str) -> Dict:
        """
        Extract PDF metadata

        Args:
            pdf_path: Path to PDF file

        Returns:
            Dictionary containing metadata
        """
        try:
            with open(pdf_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                metadata = pdf_reader.metadata

                return {
                    "title": metadata.get("/Title", ""),
                    "author": metadata.get("/Author", ""),
                    "subject": metadata.get("/Subject", ""),
                    "creator": metadata.get("/Creator", ""),
                    "producer": metadata.get("/Producer", ""),
                    "creation_date": metadata.get("/CreationDate", ""),
                    "page_count": len(pdf_reader.pages)
                }
        except Exception as e:
            logger.error(f"Error getting PDF metadata: {str(e)}")
            return {}
