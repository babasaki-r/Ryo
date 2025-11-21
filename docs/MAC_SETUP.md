# Mac mini M4 Pro セットアップガイド

## 環境仕様
- CPU: Apple M4 Pro (ARM64)
- RAM: 64GB Unified Memory
- OS: macOS

## ローカル開発セットアップ（推奨）

Apple Siliconのネイティブパフォーマンスを最大限活用できます。

### 1. バックエンドセットアップ

```bash
# プロジェクトディレクトリへ移動
cd /home/user/Ryo/backend

# 仮想環境を作成（Python 3.11使用）
python3 -m venv venv

# 仮想環境を有効化
source venv/bin/activate

# 依存関係をインストール
pip install --upgrade pip
pip install -r requirements.txt

# 環境変数を設定
cp .env.example .env

# .envファイルを編集（重要！）
# テキストエディタで開いて、以下を設定：
# TRANSLATION_SERVICE=deepl または google
# DEEPL_API_KEY=あなたのAPIキー（DeepLを使う場合）
```

#### バックエンド起動

```bash
cd /home/user/Ryo/backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**アクセス:**
- API: http://localhost:8000
- APIドキュメント: http://localhost:8000/docs

### 2. フロントエンドセットアップ

```bash
# プロジェクトディレクトリへ移動
cd /home/user/Ryo/frontend

# 依存関係をインストール
npm install

# 環境変数を設定
cp .env.example .env

# .envファイルを編集
# VITE_API_URL=http://localhost:8000
```

#### フロントエンド起動

```bash
cd /home/user/Ryo/frontend
npm run dev
```

**アクセス:** http://localhost:5173

### 3. 両方を同時起動

2つのターミナルウィンドウを開いて：

**ターミナル1（バックエンド）:**
```bash
cd /home/user/Ryo/backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**ターミナル2（フロントエンド）:**
```bash
cd /home/user/Ryo/frontend
npm run dev
```

## iOS開発（オプション）

iOSアプリを開発する場合は、Xcodeが必要です。

### Xcodeインストール

```bash
# App Storeからインストール
# または
xcode-select --install
```

### iOSプロジェクトを開く

```bash
cd /home/user/Ryo/ios/PDFTranslator
open PDFTranslator.xcodeproj
```

Xcodeで：
1. `Config.swift`を開く
2. `apiBaseURL`を編集:
   ```swift
   static let apiBaseURL = "http://localhost:8000"
   ```
3. Signing & Capabilitiesで開発チームを選択
4. ⌘+R でビルド＆実行

## Apple Silicon最適化のヒント

### PDF処理の高速化

M4 Proの強力なNeural Engineを活用するため：

```bash
# Rosetta 2は不要 - すべてARM64ネイティブで動作
```

### メモリ設定

64GB RAMを活用して、大きなPDFも快適に処理：

```python
# backend/.env
MAX_FILE_SIZE=52428800  # 50MBまで対応可能
```

### 並列処理

M4 Proの複数コアを活用：

```bash
# Uvicornをワーカー数を増やして起動
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000
```

## Dockerを使う場合（オプション）

Docker Desktopをインストール済みの場合：

### Docker Desktopインストール

```bash
# https://www.docker.com/products/docker-desktop
# Apple Silicon版をダウンロード＆インストール
```

### 起動

```bash
cd /home/user/Ryo
docker-compose build
docker-compose up
```

## トラブルシューティング

### Python依存関係のエラー

```bash
# Homebrewがインストールされていない場合
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Poppler（PDF処理ライブラリ）をインストール
brew install poppler
```

### Node.jsモジュールのエラー

```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### ポートが使用中

```bash
# 8000番ポートを使用しているプロセスを確認
lsof -ti:8000 | xargs kill -9

# 5173番ポートを使用しているプロセスを確認
lsof -ti:5173 | xargs kill -9
```

## パフォーマンス期待値

Mac mini M4 Pro (64GB RAM)での予想パフォーマンス：

- **PDFテキスト抽出**: 10ページ → 約0.5秒
- **翻訳処理**: 1000文字 → 約1-2秒（API依存）
- **同時処理**: 複数PDF同時アップロード可能
- **メモリ使用**: バックエンド 200-500MB、フロントエンド 100-200MB

## 開発効率化

### VS Code統合ターミナル

```bash
# VS Codeで開く
code /home/user/Ryo

# 統合ターミナルで
# Ctrl+Shift+` で新しいターミナル
# 1つ目: バックエンド
# 2つ目: フロントエンド
```

### Hot Reload

- バックエンド: `--reload`フラグで自動再起動
- フロントエンド: Viteが自動でHot Module Replacement

## 次のステップ

1. 翻訳APIキーを取得
   - DeepL: https://www.deepl.com/pro-api
   - Google Translate: https://console.cloud.google.com/

2. `.env`ファイルに設定

3. バックエンド＆フロントエンドを起動

4. http://localhost:5173 でアプリを開く
