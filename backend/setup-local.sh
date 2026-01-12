#!/bin/bash

echo "🚀 Setting up Cakue Backend for Local Development"

# Install dependencies
echo "📦 Installing Node.js dependencies..."
npm install

# Copy local environment
echo "⚙️  Setting up local environment..."
cp .env.local .env

# Start MySQL with Docker (only database)
echo "🗄️  Starting MySQL database..."
docker-compose up -d mysql

echo "⏳ Waiting for MySQL to be ready..."
sleep 10

echo "✅ Setup complete!"
echo ""
echo "To start the server locally:"
echo "  npm run dev"
echo ""
echo "To access phpMyAdmin:"
echo "  docker-compose up -d phpmyadmin"
echo "  Open: http://localhost:8080"