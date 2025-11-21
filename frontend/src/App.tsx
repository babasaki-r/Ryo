import { useState } from 'react'
import { FiUpload, FiFile, FiGlobe } from 'react-icons/fi'
import FileUpload from './components/FileUpload'
import DocumentList from './components/DocumentList'
import TranslationView from './components/TranslationView'
import { Document } from './types'

function App() {
  const [selectedDocument, setSelectedDocument] = useState<Document | null>(null)
  const [refreshKey, setRefreshKey] = useState(0)

  const handleUploadSuccess = () => {
    setRefreshKey(prev => prev + 1)
  }

  const handleDocumentSelect = (doc: Document) => {
    setSelectedDocument(doc)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <FiGlobe className="text-3xl text-blue-600" />
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  PDF Translator
                </h1>
                <p className="text-sm text-gray-600">
                  設備仕様書翻訳システム
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-2 text-sm text-gray-600">
              <FiFile />
              <span>English → Japanese</span>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left Sidebar - Upload & Documents */}
          <div className="lg:col-span-1 space-y-6">
            {/* Upload Section */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <div className="flex items-center space-x-2 mb-4">
                <FiUpload className="text-xl text-blue-600" />
                <h2 className="text-lg font-semibold text-gray-900">
                  PDFをアップロード
                </h2>
              </div>
              <FileUpload onUploadSuccess={handleUploadSuccess} />
            </div>

            {/* Document List */}
            <div className="bg-white rounded-lg shadow-md p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                ドキュメント一覧
              </h2>
              <DocumentList
                refreshKey={refreshKey}
                onDocumentSelect={handleDocumentSelect}
                selectedDocumentId={selectedDocument?.document_id}
              />
            </div>
          </div>

          {/* Right Content - Translation View */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow-md p-6">
              {selectedDocument ? (
                <TranslationView document={selectedDocument} />
              ) : (
                <div className="flex flex-col items-center justify-center h-96 text-gray-400">
                  <FiFile className="text-6xl mb-4" />
                  <p className="text-lg">
                    ドキュメントを選択してください
                  </p>
                  <p className="text-sm mt-2">
                    左側のリストからPDFを選択すると翻訳が表示されます
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <p className="text-center text-sm text-gray-600">
            PDF Translation App - Equipment Specification Translator
          </p>
        </div>
      </footer>
    </div>
  )
}

export default App
