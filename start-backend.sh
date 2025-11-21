#!/bin/bash

# PDF Translation App - Backend Startup Script for Mac

set -e

echo "🚀 Starting PDF Translation Backend..."

cd backend

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Check if dependencies are installed
if [ ! -f "venv/.deps_installed" ]; then
    echo "📥 Installing dependencies..."
    pip install --upgrade pip
    pip install -r requirements.txt
    touch venv/.deps_installed
else
    echo "✅ Dependencies already installed"
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from example..."
    cp .env.example .env
    echo "⚠️  Please edit backend/.env and add your translation API key!"
    echo "   DEEPL_API_KEY=your_key_here"
    echo ""
    read -p "Press Enter to continue (or Ctrl+C to exit and configure)..."
fi

# Create uploads directory
mkdir -p uploads

echo "✨ Starting Uvicorn server on http://localhost:8000"
echo "📚 API Documentation: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
