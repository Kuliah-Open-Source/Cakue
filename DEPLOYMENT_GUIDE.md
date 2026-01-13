# 🚀 CAKUE - Deployment & Setup Guide

## 📋 Prerequisites

### System Requirements
- **OS**: Linux, macOS, or Windows with WSL2
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Flutter SDK**: Version 3.0+ (for mobile development)
- **Node.js**: Version 18+ (for local backend development)

### Hardware Requirements
- **RAM**: Minimum 4GB, Recommended 8GB
- **Storage**: 10GB free space
- **CPU**: 2+ cores recommended

## 🐳 Docker Deployment (Recommended)

### 1. Quick Start
```bash
# Clone repository
git clone <repository-url>
cd Cakue

# Start all services
docker-compose up -d

# Check status
docker-compose ps
```

### 2. Service URLs
- **Backend API**: http://localhost:3000
- **phpMyAdmin**: http://localhost:8080
- **MySQL**: localhost:3306

### 3. Default Credentials
```
MySQL:
- Root Password: root123
- Database: cakue_db
- User: cakue_user
- Password: cakue123

phpMyAdmin:
- Username: root
- Password: root123
```

## 🔧 Manual Setup

### Backend Setup
```bash
cd backend

# Install dependencies
npm install

# Setup environment
cp .env.example .env
nano .env  # Edit configuration

# Start MySQL (via Docker)
docker-compose up -d mysql

# Start backend
npm start
```

### Flutter Setup
```bash
cd flutter

# Install dependencies
flutter pub get

# Generate Hive adapters
flutter packages pub run build_runner build

# Run app (with device connected)
flutter run
```

## ⚙️ Configuration

### Environment Variables (.env)
```bash
# Database Configuration
DB_HOST=mysql                    # Use 'localhost' for local development
DB_PORT=3306
DB_USER=root
DB_PASSWORD=root123
DB_NAME=cakue_db

# JWT Configuration
JWT_SECRET=your-super-secure-jwt-secret-key-minimum-32-characters
JWT_EXPIRES_IN=24h

# Server Configuration
PORT=3000
NODE_ENV=production              # Use 'development' for local

# Frontend Configuration
FRONTEND_URL=http://localhost:3000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### Flutter Configuration
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String baseUrl = 'http://localhost:3000';  // Change for production
  static const int requestTimeout = 30;
  static const int maxRetries = 3;
}
```

## 🗄️ Database Setup

### Automatic Setup (Docker)
Database schema is automatically initialized when backend starts.

### Manual Setup
```sql
-- Connect to MySQL
mysql -u root -p

-- Create database
CREATE DATABASE cakue_db;
USE cakue_db;

-- Tables are auto-created by backend on first run
```

### Sample Data
```sql
-- Insert sample user
INSERT INTO users (name, email, password_hash) 
VALUES ('Test User', 'test@example.com', '$2b$12$...');

-- Insert sample account
INSERT INTO accounts (user_id, name, type) 
VALUES (1, 'Personal Account', 'personal');

-- Insert sample categories
INSERT INTO categories (account_id, name, type) VALUES
(1, 'Food', 'expense'),
(1, 'Transportation', 'expense'),
(1, 'Salary', 'income');
```

## 🔐 Security Setup

### JWT Secret Generation
```bash
# Generate secure JWT secret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### SSL/HTTPS (Production)
```nginx
# Nginx configuration
server {
    listen 443 ssl;
    server_name api.cakue.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 📱 Mobile App Deployment

### Android Build
```bash
cd flutter

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS Build
```bash
cd flutter

# Build for iOS
flutter build ios --release

# Archive for App Store
# Use Xcode for final build and submission
```

## 🐳 Production Docker Setup

### docker-compose.prod.yml
```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
    volumes:
      - mysql_data:/var/lib/mysql
    restart: unless-stopped
    
  backend:
    build: ./backend
    environment:
      NODE_ENV: production
      DB_HOST: mysql
      JWT_SECRET: ${JWT_SECRET}
    ports:
      - "3000:3000"
    depends_on:
      - mysql
    restart: unless-stopped

volumes:
  mysql_data:
```

### Production Environment
```bash
# Set production environment variables
export MYSQL_ROOT_PASSWORD=secure_password_here
export MYSQL_DATABASE=cakue_db
export JWT_SECRET=your_secure_jwt_secret_here

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

## 🔍 Monitoring & Logging

### Health Checks
```bash
# Check API health
curl http://localhost:3000/api/test

# Check database connection
docker exec cakue_mysql mysqladmin ping -h localhost -u root -p

# Check all services
docker-compose ps
```

### Log Monitoring
```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f mysql

# View recent logs
docker-compose logs --tail=50 backend
```

## 🔄 Backup & Recovery

### Database Backup
```bash
# Create backup
docker exec cakue_mysql mysqldump -u root -proot123 cakue_db > backup.sql

# Restore backup
docker exec -i cakue_mysql mysql -u root -proot123 cakue_db < backup.sql
```

### Automated Backup Script
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
docker exec cakue_mysql mysqldump -u root -proot123 cakue_db > "backup_${DATE}.sql"
echo "Backup created: backup_${DATE}.sql"
```

## 🚀 CI/CD Pipeline

### GitHub Actions Example
```yaml
# .github/workflows/deploy.yml
name: Deploy CAKUE

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build and Deploy
        run: |
          docker-compose build
          docker-compose up -d
          
      - name: Run Tests
        run: |
          curl -f http://localhost:3000/api/test
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Port Already in Use
```bash
# Check what's using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>
```

#### 2. Database Connection Failed
```bash
# Check MySQL status
docker logs cakue_mysql

# Restart MySQL
docker-compose restart mysql
```

#### 3. Flutter Build Issues
```bash
# Clean Flutter cache
flutter clean
flutter pub get

# Regenerate Hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 4. Docker Issues
```bash
# Clean Docker system
docker system prune -a

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Performance Optimization

#### Database Optimization
```sql
-- Add indexes for better performance
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_user ON transactions(account_id);
CREATE INDEX idx_transactions_type ON transactions(type);
```

#### Backend Optimization
```javascript
// Enable compression
const compression = require('compression');
app.use(compression());

// Connection pooling
const pool = mysql.createPool({
  connectionLimit: 10,
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});
```

## 📊 Scaling Considerations

### Horizontal Scaling
```yaml
# docker-compose.scale.yml
version: '3.8'

services:
  backend:
    build: ./backend
    deploy:
      replicas: 3
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
```

### Load Balancer Configuration
```nginx
# nginx.conf
upstream backend {
    server backend_1:3000;
    server backend_2:3000;
    server backend_3:3000;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

## 🔒 Security Checklist

- [ ] Change default passwords
- [ ] Use strong JWT secret (32+ characters)
- [ ] Enable HTTPS in production
- [ ] Configure firewall rules
- [ ] Regular security updates
- [ ] Database access restrictions
- [ ] API rate limiting enabled
- [ ] Input validation implemented
- [ ] Error logging configured
- [ ] Backup strategy in place

## 📞 Support & Maintenance

### Regular Maintenance Tasks
1. **Weekly**: Check logs and system health
2. **Monthly**: Update dependencies and security patches
3. **Quarterly**: Database optimization and cleanup
4. **Yearly**: Security audit and architecture review

### Monitoring Alerts
Set up alerts for:
- High CPU/Memory usage
- Database connection failures
- API response time > 2 seconds
- Disk space < 20%
- Failed authentication attempts > 10/minute

---

**Panduan ini mencakup semua aspek deployment dan maintenance sistem CAKUE untuk environment development hingga production.**