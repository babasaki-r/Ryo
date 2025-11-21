import { useState, useEffect } from 'react'
import { FiFile, FiTrash2, FiClock } from 'react-icons/fi'
import { listDocuments, deleteDocument } from '../services/api'
import { Document } from '../types'

interface DocumentListProps {
  refreshKey?: number
  onDocumentSelect?: (doc: Document) => void
  selectedDocumentId?: string
}

const DocumentList = ({ refreshKey, onDocumentSelect, selectedDocumentId }: DocumentListProps) => {
  const [documents, setDocuments] = useState<Document[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchDocuments = async () => {
    try {
      setLoading(true)
      setError(null)
      const response = await listDocuments()
      setDocuments(response.documents)
    } catch (err: any) {
      setError('ドキュメントの取得に失敗しました')
      console.error('Error fetching documents:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchDocuments()
  }, [refreshKey])

  const handleDelete = async (documentId: string, event: React.MouseEvent) => {
    event.stopPropagation()

    if (!window.confirm('このドキュメントを削除しますか?')) {
      return
    }

    try {
      await deleteDocument(documentId)
      setDocuments(docs => docs.filter(doc => doc.document_id !== documentId))
    } catch (err) {
      console.error('Error deleting document:', err)
      alert('削除に失敗しました')
    }
  }

  const formatFileSize = (bytes?: number) => {
    if (!bytes) return 'N/A'
    const kb = bytes / 1024
    if (kb < 1024) return `${kb.toFixed(1)} KB`
    return `${(kb / 1024).toFixed(1)} MB`
  }

  const formatDate = (timestamp?: string) => {
    if (!timestamp) return 'N/A'
    const date = new Date(parseFloat(timestamp) * 1000)
    return date.toLocaleDateString('ja-JP', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  if (loading) {
    return (
      <div className="flex justify-center py-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="text-center py-8 text-red-600">
        <p>{error}</p>
      </div>
    )
  }

  if (documents.length === 0) {
    return (
      <div className="text-center py-8 text-gray-400">
        <FiFile className="mx-auto text-4xl mb-2" />
        <p className="text-sm">ドキュメントがありません</p>
      </div>
    )
  }

  return (
    <div className="space-y-2 max-h-96 overflow-y-auto">
      {documents.map((doc) => (
        <div
          key={doc.document_id}
          onClick={() => onDocumentSelect && onDocumentSelect(doc)}
          className={`
            p-3 rounded-lg cursor-pointer transition-colors
            ${selectedDocumentId === doc.document_id
              ? 'bg-blue-50 border-2 border-blue-500'
              : 'bg-gray-50 hover:bg-gray-100 border-2 border-transparent'
            }
          `}
        >
          <div className="flex items-start justify-between">
            <div className="flex-1 min-w-0">
              <div className="flex items-center space-x-2">
                <FiFile className="text-blue-600 flex-shrink-0" />
                <h3 className="text-sm font-medium text-gray-900 truncate">
                  {doc.filename}
                </h3>
              </div>
              <div className="mt-1 flex items-center space-x-3 text-xs text-gray-500">
                <span>{formatFileSize(doc.size)}</span>
                {doc.created_at && (
                  <span className="flex items-center space-x-1">
                    <FiClock className="text-xs" />
                    <span>{formatDate(doc.created_at)}</span>
                  </span>
                )}
              </div>
            </div>
            <button
              onClick={(e) => handleDelete(doc.document_id, e)}
              className="ml-2 p-1 text-gray-400 hover:text-red-600 transition-colors"
              title="削除"
            >
              <FiTrash2 className="text-sm" />
            </button>
          </div>
        </div>
      ))}
    </div>
  )
}

export default DocumentList
