import { useState, useEffect } from 'react'
import { FiRefreshCw, FiCopy, FiCheck } from 'react-icons/fi'
import { translateDocument } from '../services/api'
import { Document, TranslationResponse } from '../types'

interface TranslationViewProps {
  document: Document
}

const TranslationView = ({ document }: TranslationViewProps) => {
  const [translation, setTranslation] = useState<TranslationResponse | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [copiedOriginal, setCopiedOriginal] = useState(false)
  const [copiedTranslated, setCopiedTranslated] = useState(false)

  const fetchTranslation = async () => {
    if (!document) return

    setLoading(true)
    setError(null)

    try {
      const response = await translateDocument(document.document_id)
      setTranslation(response)
    } catch (err: any) {
      setError(err.response?.data?.detail || '翻訳に失敗しました')
      console.error('Translation error:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchTranslation()
  }, [document?.document_id])

  const handleCopy = (text: string, isOriginal: boolean) => {
    navigator.clipboard.writeText(text)
    if (isOriginal) {
      setCopiedOriginal(true)
      setTimeout(() => setCopiedOriginal(false), 2000)
    } else {
      setCopiedTranslated(true)
      setTimeout(() => setCopiedTranslated(false), 2000)
    }
  }

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center h-96">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
        <p className="text-gray-600">翻訳中...</p>
        <p className="text-sm text-gray-400 mt-2">
          数秒かかる場合があります
        </p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center h-96">
        <div className="text-red-600 mb-4">
          <p className="text-lg font-semibold">エラー</p>
          <p className="text-sm">{error}</p>
        </div>
        <button
          onClick={fetchTranslation}
          className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          <FiRefreshCw />
          <span>再試行</span>
        </button>
      </div>
    )
  }

  if (!translation) {
    return (
      <div className="flex items-center justify-center h-96 text-gray-400">
        <p>翻訳データがありません</p>
      </div>
    )
  }

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6 pb-4 border-b">
        <div>
          <h2 className="text-xl font-semibold text-gray-900">
            {document.filename}
          </h2>
          <p className="text-sm text-gray-600 mt-1">
            英語 → 日本語
          </p>
        </div>
        <button
          onClick={fetchTranslation}
          disabled={loading}
          className="flex items-center space-x-2 px-3 py-2 text-sm bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors disabled:opacity-50"
        >
          <FiRefreshCw className={loading ? 'animate-spin' : ''} />
          <span>再翻訳</span>
        </button>
      </div>

      {/* Translation Content */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Original Text */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-700">
              原文 (英語)
            </h3>
            <button
              onClick={() => handleCopy(translation.original_text, true)}
              className="flex items-center space-x-1 text-sm text-gray-600 hover:text-blue-600 transition-colors"
            >
              {copiedOriginal ? (
                <>
                  <FiCheck className="text-green-600" />
                  <span className="text-green-600">コピー済</span>
                </>
              ) : (
                <>
                  <FiCopy />
                  <span>コピー</span>
                </>
              )}
            </button>
          </div>
          <div className="bg-gray-50 rounded-lg p-4 max-h-96 overflow-y-auto">
            <pre className="whitespace-pre-wrap text-sm text-gray-800 font-sans">
              {translation.original_text}
            </pre>
          </div>
        </div>

        {/* Translated Text */}
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-700">
              翻訳 (日本語)
            </h3>
            <button
              onClick={() => handleCopy(translation.translated_text, false)}
              className="flex items-center space-x-1 text-sm text-gray-600 hover:text-blue-600 transition-colors"
            >
              {copiedTranslated ? (
                <>
                  <FiCheck className="text-green-600" />
                  <span className="text-green-600">コピー済</span>
                </>
              ) : (
                <>
                  <FiCopy />
                  <span>コピー</span>
                </>
              )}
            </button>
          </div>
          <div className="bg-blue-50 rounded-lg p-4 max-h-96 overflow-y-auto">
            <pre className="whitespace-pre-wrap text-sm text-gray-800 font-sans">
              {translation.translated_text}
            </pre>
          </div>
        </div>
      </div>

      {/* Translation Info */}
      <div className="mt-6 pt-4 border-t">
        <div className="flex items-center justify-between text-xs text-gray-500">
          <span>ステータス: {translation.status}</span>
          {translation.translated_at && (
            <span>
              翻訳日時: {new Date(translation.translated_at).toLocaleString('ja-JP')}
            </span>
          )}
        </div>
      </div>
    </div>
  )
}

export default TranslationView
