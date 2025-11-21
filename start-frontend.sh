#!/bin/bash

# PDF Translation App - Frontend Startup Script for Mac

set -e

echo "🚀 Starting PDF Translation Frontend..."

cd frontend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
else
    echo "✅ Dependencies already installed"
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from example..."
    cp .env.example .env
    echo "✅ Created .env with default settings"
fi

echo "✨ Starting Vite dev server on http://localhost:5173"
echo ""
echo "Make sure the backend is running on http://localhost:8000"
echo "Press Ctrl+C to stop the server"
echo ""

# Start the dev server
npm run dev
