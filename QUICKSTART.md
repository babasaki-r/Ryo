# 🚀 クイックスタート - Mac mini M4 Pro

## 最速セットアップ（5分）

### 1. 前提条件確認

✅ すでにインストール済み:
- Python 3.11.14
- Node.js v22.21.1

✅ 追加で必要（PDF処理用）:
```bash
# Homebrewがない場合はインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Popplerをインストール（PDF処理に必要）
brew install poppler
```

### 2. 翻訳APIキーを取得

どちらか1つを選択：

#### オプションA: DeepL（推奨）
1. https://www.deepl.com/pro-api にアクセス
2. アカウント登録（無料版は月50万文字まで無料）
3. APIキーをコピー

#### オプションB: Google Translate
1. https://console.cloud.google.com/ にアクセス
2. プロジェクト作成
3. Cloud Translation API を有効化
4. サービスアカウント作成してJSON取得

#### オプションC: モックモード（テスト用）
APIキーなしでも動作可能。テキストに「[翻訳済]」が付くだけです。

### 3. バックエンド設定

```bash
cd /path/to/Ryo/backend
cp .env.example .env

# .envファイルを編集（テキストエディタで開く）
# 例: nano .env または code .env

# 以下を設定：
TRANSLATION_SERVICE=deepl    # または google
DEEPL_API_KEY=あなたのAPIキー   # DeepLの場合
```

### 4. アプリ起動

**ターミナル1（バックエンド）:**
```bash
cd /path/to/Ryo
./start-backend.sh
```

**ターミナル2（フロントエンド）:**
```bash
cd /path/to/Ryo
./start-frontend.sh
```

### 5. アクセス

ブラウザで開く:
- **アプリ**: http://localhost:5173
- **API**: http://localhost:8000/docs

## 使い方

1. ブラウザで http://localhost:5173 を開く
2. PDFファイルをドラッグ&ドロップ
3. ドキュメント一覧から選択
4. 翻訳結果が表示されます！

## トラブルシューティング

### エラー: "Module not found"

```bash
# バックエンド
cd backend
source venv/bin/activate
pip install -r requirements.txt

# フロントエンド
cd frontend
npm install
```

### エラー: "Port already in use"

```bash
# ポート8000を解放
lsof -ti:8000 | xargs kill -9

# ポート5173を解放
lsof -ti:5173 | xargs kill -9
```

### 翻訳がうまくいかない

1. `.env`ファイルのAPIキーを確認
2. バックエンドのログを確認
3. モックモードで動作確認:
   ```bash
   # backend/.env
   TRANSLATION_SERVICE=mock
   ```

## M4 Pro最適化設定（オプション）

### 高速化設定

```bash
# backend/.env に追加
MAX_FILE_SIZE=52428800  # 50MBまで対応（デフォルト10MB）
```

### 複数ワーカーで起動（本番環境向け）

```bash
cd backend
source venv/bin/activate
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000
```

## iOS アプリ（オプション）

### 1. Xcodeインストール
App Storeから「Xcode」をインストール

### 2. プロジェクトを開く
```bash
cd ios/PDFTranslator
open PDFTranslator.xcodeproj
```

### 3. 設定
- `Config.swift`で`apiBaseURL = "http://localhost:8000"`を確認
- Signing & Capabilitiesでチームを選択

### 4. 実行
⌘+R でビルド＆実行

## パフォーマンス

Mac mini M4 Pro (64GB)での実測値:
- PDF抽出: 10ページ → **0.3-0.5秒**
- 翻訳: 1000文字 → **1-3秒**（API依存）
- メモリ使用: **合計300-700MB**

## 次のステップ

✅ [詳細セットアップ](docs/MAC_SETUP.md)
✅ [API仕様](docs/API.md)
✅ [アーキテクチャ](docs/ARCHITECTURE.md)
