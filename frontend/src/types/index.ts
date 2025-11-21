export interface Document {
  document_id: string
  filename: string
  size?: number
  created_at?: string
  page_count?: number
  status?: string
}

export interface DocumentResponse {
  document_id: string
  filename: string
  status: string
  extracted_text: string
  page_count: number
  created_at?: string
}

export interface TranslationResponse {
  document_id: string
  original_text: string
  translated_text: string
  source_lang: string
  target_lang: string
  status: string
  translated_at?: string
}

export interface DocumentListResponse {
  documents: Document[]
  count: number
}
