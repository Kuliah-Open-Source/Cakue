# Cakue Management System

A full-stack financial management application built with Flutter (mobile) and Express.js (backend).

## 🏗️ Project Structure

```
Cakue/
├── flutter/              # Flutter mobile application
│   ├── lib/
│   │   ├── Screens/      # UI screens (login, register, home, add, statistics)
│   │   ├── data/         # Data models and utilities
│   │   ├── widgets/      # Reusable UI components
│   │   └── services/     # API services
│   └── pubspec.yaml
├── backend/              # Express.js REST API
│   ├── server.js         # Main server file
│   ├── package.json      # Node.js dependencies
│   └── Dockerfile        # Backend container config
├── docker-compose.yml    # Multi-container orchestration
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Flutter SDK (for mobile development)
- Node.js (for backend development)

### 1. Automated Setup (Recommended)
```bash
# Clone and setup everything
git clone <repository-url>
cd Cakue
./setup.sh
```

### 2. Manual Setup

#### Backend Setup
```bash
cd backend

# Copy environment template
cp .env.example .env

# Edit .env file and set secure JWT_SECRET (minimum 32 characters)
nano .env

# Install dependencies
npm install

# Start services
docker-compose up -d
```

#### Flutter Setup
```bash
cd flutter
flutter pub get
flutter run
```

## 📱 Flutter App Features

### ✅ Current Features
- **Authentication**: Login & Register screens
- **Dashboard**: Balance overview, income/expense tracking
- **Transaction Management**: Add, view, delete transactions
- **Statistics**: Charts and analytics (daily, weekly, monthly, yearly)
- **Local Storage**: Hive database for offline functionality
- **Categories**: Food, Transfer, Transportation, Education

### 🎨 UI Design
- **Color Theme**: Teal green (`#368983`)
- **Consistent Styling**: Rounded corners, shadows, clean typography
- **Responsive Layout**: Adaptive to different screen sizes

## 🔧 Backend API

### Database Schema
```sql
-- Users table (for authentication)
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### API Endpoints
```
GET  /                    # Health check
GET  /api/users          # Get all users
POST /api/users          # Create user
POST /api/auth/login     # User login (planned)
POST /api/auth/register  # User registration (planned)
```

### Database Access
- **phpMyAdmin**: http://localhost:8080
- **Credentials**: 
  - Server: `mysql`
  - Username: `root`
  - Password: `root123`
  - Database: `cakue_db`

## 🛠️ Development

### Flutter Development
```bash
cd flutter

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter packages pub run build_runner build

# Run app
flutter run

# Build for production
flutter build apk
```

### Backend Development
```bash
cd backend

# Install dependencies
npm install

# Run in development mode
npm run dev

# Run in production mode
npm start
```

### Docker Commands
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild backend
docker-compose build backend
```

## 📊 Data Flow

1. **Local-First**: Flutter app works offline with Hive storage
2. **Sync Ready**: Backend API ready for cloud synchronization
3. **Multi-User**: Database structure supports multiple users

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication with configurable expiry
- **Password Security**: Bcrypt hashing with salt rounds
- **Input Validation**: Comprehensive server-side and client-side validation
- **Rate Limiting**: Protection against brute force attacks
- **CORS Configuration**: Controlled cross-origin resource sharing
- **Security Headers**: Helmet.js for additional security headers
- **Environment Variables**: Secure credential management
- **SQL Injection Protection**: Parameterized queries
- **Error Handling**: Consistent error responses without information leakage

## 🎯 Roadmap

### Phase 1 (Current)
- ✅ Flutter UI complete
- ✅ Local data storage
- ✅ Backend infrastructure
- ✅ Authentication screens

### Phase 2 (Next)
- [ ] Connect Flutter to backend API
- [ ] User authentication implementation
- [ ] Cloud data synchronization
- [ ] Multi-device support

### Phase 3 (Future)
- [ ] Push notifications
- [ ] Data export/import
- [ ] Advanced analytics
- [ ] Budget planning features

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.