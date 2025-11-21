import axios from 'axios'
import { DocumentResponse, TranslationResponse, DocumentListResponse } from '../types'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

export const uploadPDF = async (file: File): Promise<DocumentResponse> => {
  const formData = new FormData()
  formData.append('file', file)

  const response = await api.post<DocumentResponse>('/api/v1/upload', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  })

  return response.data
}

export const translateDocument = async (
  documentId: string,
  sourceLang: string = 'en',
  targetLang: string = 'ja'
): Promise<TranslationResponse> => {
  const response = await api.post<TranslationResponse>(
    `/api/v1/translate/${documentId}`,
    null,
    {
      params: {
        source_lang: sourceLang,
        target_lang: targetLang,
      },
    }
  )

  return response.data
}

export const listDocuments = async (): Promise<DocumentListResponse> => {
  const response = await api.get<DocumentListResponse>('/api/v1/documents')
  return response.data
}

export const deleteDocument = async (documentId: string): Promise<void> => {
  await api.delete(`/api/v1/documents/${documentId}`)
}

export default api
