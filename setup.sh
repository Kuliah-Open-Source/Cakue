#!/bin/bash

echo "🚀 Setting up Cakue Management System..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f "./backend/.env" ]; then
    echo "📝 Creating environment configuration..."
    cp ./backend/.env.example ./backend/.env
    
    # Generate secure JWT secret
    JWT_SECRET=$(openssl rand -base64 32)
    sed -i "s/your_super_secure_jwt_secret_key_here_min_32_chars/$JWT_SECRET/" ./backend/.env
    
    echo "✅ Environment file created with secure JWT secret"
else
    echo "⚠️  Environment file already exists"
fi

# Install backend dependencies
echo "📦 Installing backend dependencies..."
cd backend
npm install
cd ..

# Install Flutter dependencies
echo "📱 Installing Flutter dependencies..."
cd flutter
flutter pub get
cd ..

# Start services
echo "🐳 Starting Docker services..."
docker-compose up -d

echo "✅ Setup complete!"
echo ""
echo "🌐 Services are now running:"
echo "   - Backend API: http://localhost:3000"
echo "   - phpMyAdmin: http://localhost:8080"
echo "   - MySQL: localhost:3306"
echo ""
echo "📱 To run Flutter app:"
echo "   cd flutter && flutter run"
echo ""
echo "🔐 Default database credentials:"
echo "   - Username: root"
echo "   - Password: root123"