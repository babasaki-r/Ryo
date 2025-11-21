"""Translation Service"""
import os
import logging
from typing import Optional, List
import asyncio

logger = logging.getLogger(__name__)


class TranslationService:
    """Service for handling text translation"""

    def __init__(self):
        self.service_type = os.getenv("TRANSLATION_SERVICE", "deepl").lower()
        self.deepl_api_key = os.getenv("DEEPL_API_KEY")
        self.google_credentials = os.getenv("GOOGLE_CREDENTIALS_PATH")

        # Initialize translation client
        self.client = None
        self._initialize_client()

    def _initialize_client(self):
        """Initialize the appropriate translation client"""
        try:
            if self.service_type == "deepl":
                if self.deepl_api_key:
                    import deepl
                    self.client = deepl.Translator(self.deepl_api_key)
                    logger.info("DeepL translator initialized")
                else:
                    logger.warning("DeepL API key not found, using mock translator")
                    self.client = None
            elif self.service_type == "google":
                if self.google_credentials:
                    from google.cloud import translate_v2 as translate
                    self.client = translate.Client()
                    logger.info("Google Translate initialized")
                else:
                    logger.warning("Google credentials not found, using mock translator")
                    self.client = None
            else:
                logger.warning(f"Unknown translation service: {self.service_type}, using mock")
                self.client = None

        except ImportError as e:
            logger.error(f"Translation library not installed: {str(e)}")
            self.client = None
        except Exception as e:
            logger.error(f"Error initializing translation client: {str(e)}")
            self.client = None

    async def translate(
        self,
        text: str,
        source_lang: str = "en",
        target_lang: str = "ja"
    ) -> str:
        """
        Translate text from source language to target language

        Args:
            text: Text to translate
            source_lang: Source language code
            target_lang: Target language code

        Returns:
            Translated text
        """
        if not text or not text.strip():
            return ""

        try:
            # Split long text into chunks if needed
            chunks = self._split_text(text, max_length=4000)
            translated_chunks = []

            for chunk in chunks:
                if self.service_type == "deepl" and self.client:
                    result = await self._translate_deepl(chunk, source_lang, target_lang)
                    translated_chunks.append(result)
                elif self.service_type == "google" and self.client:
                    result = await self._translate_google(chunk, source_lang, target_lang)
                    translated_chunks.append(result)
                else:
                    # Mock translation for testing/development
                    result = await self._mock_translate(chunk, source_lang, target_lang)
                    translated_chunks.append(result)

            return "\n".join(translated_chunks)

        except Exception as e:
            logger.error(f"Translation error: {str(e)}")
            raise

    async def _translate_deepl(
        self,
        text: str,
        source_lang: str,
        target_lang: str
    ) -> str:
        """Translate using DeepL API"""
        try:
            # Convert language codes to DeepL format
            target_lang_deepl = target_lang.upper()
            if target_lang_deepl == "JA":
                target_lang_deepl = "JA"
            elif target_lang_deepl == "EN":
                target_lang_deepl = "EN-US"

            # DeepL is synchronous, run in executor for async
            loop = asyncio.get_event_loop()
            result = await loop.run_in_executor(
                None,
                lambda: self.client.translate_text(
                    text,
                    source_lang=source_lang.upper() if source_lang else None,
                    target_lang=target_lang_deepl
                )
            )

            return result.text

        except Exception as e:
            logger.error(f"DeepL translation error: {str(e)}")
            raise

    async def _translate_google(
        self,
        text: str,
        source_lang: str,
        target_lang: str
    ) -> str:
        """Translate using Google Translate API"""
        try:
            # Google Translate is synchronous, run in executor for async
            loop = asyncio.get_event_loop()
            result = await loop.run_in_executor(
                None,
                lambda: self.client.translate(
                    text,
                    source_language=source_lang,
                    target_language=target_lang
                )
            )

            return result['translatedText']

        except Exception as e:
            logger.error(f"Google Translate error: {str(e)}")
            raise

    async def _mock_translate(
        self,
        text: str,
        source_lang: str,
        target_lang: str
    ) -> str:
        """
        Mock translation for development/testing
        Simply prefixes text with [TRANSLATED]
        """
        logger.info(f"Using mock translation from {source_lang} to {target_lang}")

        # Simulate API delay
        await asyncio.sleep(0.1)

        # Return mock translation
        lines = text.split('\n')
        translated_lines = []

        for line in lines:
            if line.strip():
                # Add Japanese mock translation marker
                if target_lang == "ja":
                    translated_lines.append(f"[翻訳済] {line}")
                else:
                    translated_lines.append(f"[TRANSLATED to {target_lang}] {line}")
            else:
                translated_lines.append(line)

        return '\n'.join(translated_lines)

    def _split_text(self, text: str, max_length: int = 4000) -> List[str]:
        """
        Split text into chunks that fit within API limits

        Args:
            text: Text to split
            max_length: Maximum length per chunk

        Returns:
            List of text chunks
        """
        if len(text) <= max_length:
            return [text]

        chunks = []
        current_chunk = []
        current_length = 0

        # Split by paragraphs/lines
        lines = text.split('\n')

        for line in lines:
            line_length = len(line) + 1  # +1 for newline

            if current_length + line_length > max_length:
                # Save current chunk and start new one
                if current_chunk:
                    chunks.append('\n'.join(current_chunk))
                    current_chunk = [line]
                    current_length = line_length
                else:
                    # Single line is too long, split it
                    chunks.append(line[:max_length])
                    current_chunk = [line[max_length:]]
                    current_length = len(line[max_length:])
            else:
                current_chunk.append(line)
                current_length += line_length

        # Add remaining chunk
        if current_chunk:
            chunks.append('\n'.join(current_chunk))

        return chunks

    def get_supported_languages(self) -> List[str]:
        """
        Get list of supported languages

        Returns:
            List of language codes
        """
        # Common languages supported by both services
        return ["en", "ja", "zh", "ko", "de", "fr", "es", "it", "pt", "ru"]
