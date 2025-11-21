import { useState, useCallback } from 'react'
import { useDropzone } from 'react-dropzone'
import { FiUploadCloud, FiCheckCircle, FiAlertCircle } from 'react-icons/fi'
import { uploadPDF } from '../services/api'

interface FileUploadProps {
  onUploadSuccess?: () => void
}

const FileUpload = ({ onUploadSuccess }: FileUploadProps) => {
  const [uploading, setUploading] = useState(false)
  const [uploadStatus, setUploadStatus] = useState<{
    type: 'success' | 'error' | null
    message: string
  }>({ type: null, message: '' })

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    if (acceptedFiles.length === 0) return

    const file = acceptedFiles[0]

    // Validate file type
    if (!file.name.endsWith('.pdf')) {
      setUploadStatus({
        type: 'error',
        message: 'PDFファイルのみアップロード可能です',
      })
      return
    }

    // Validate file size (10MB)
    if (file.size > 10 * 1024 * 1024) {
      setUploadStatus({
        type: 'error',
        message: 'ファイルサイズは10MB以下にしてください',
      })
      return
    }

    setUploading(true)
    setUploadStatus({ type: null, message: '' })

    try {
      const response = await uploadPDF(file)
      setUploadStatus({
        type: 'success',
        message: `${response.filename} をアップロードしました`,
      })

      if (onUploadSuccess) {
        onUploadSuccess()
      }

      // Clear success message after 3 seconds
      setTimeout(() => {
        setUploadStatus({ type: null, message: '' })
      }, 3000)
    } catch (error: any) {
      setUploadStatus({
        type: 'error',
        message: error.response?.data?.detail || 'アップロードに失敗しました',
      })
    } finally {
      setUploading(false)
    }
  }, [onUploadSuccess])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'application/pdf': ['.pdf'],
    },
    maxFiles: 1,
    disabled: uploading,
  })

  return (
    <div>
      <div
        {...getRootProps()}
        className={`
          border-2 border-dashed rounded-lg p-8 text-center cursor-pointer
          transition-colors duration-200
          ${isDragActive ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-blue-400'}
          ${uploading ? 'opacity-50 cursor-not-allowed' : ''}
        `}
      >
        <input {...getInputProps()} />
        <FiUploadCloud className="mx-auto text-4xl text-gray-400 mb-3" />
        {uploading ? (
          <div>
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto mb-2"></div>
            <p className="text-sm text-gray-600">アップロード中...</p>
          </div>
        ) : (
          <div>
            <p className="text-sm text-gray-600 mb-1">
              {isDragActive
                ? 'ここにドロップしてください'
                : 'PDFファイルをドラッグ&ドロップ'}
            </p>
            <p className="text-xs text-gray-500">
              または クリックして選択
            </p>
            <p className="text-xs text-gray-400 mt-2">
              最大サイズ: 10MB
            </p>
          </div>
        )}
      </div>

      {/* Status Messages */}
      {uploadStatus.type && (
        <div
          className={`
            mt-4 p-3 rounded-lg flex items-center space-x-2
            ${uploadStatus.type === 'success' ? 'bg-green-50 text-green-800' : 'bg-red-50 text-red-800'}
          `}
        >
          {uploadStatus.type === 'success' ? (
            <FiCheckCircle className="text-xl" />
          ) : (
            <FiAlertCircle className="text-xl" />
          )}
          <span className="text-sm">{uploadStatus.message}</span>
        </div>
      )}
    </div>
  )
}

export default FileUpload
