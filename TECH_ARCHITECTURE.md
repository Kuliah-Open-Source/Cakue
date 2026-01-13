# 📋 CAKUE - Dokumentasi Teknologi & Arsitektur

## 🏗️ Arsitektur Sistem

### Overview
CAKUE adalah aplikasi manajemen keuangan full-stack dengan arsitektur **Client-Server** yang menggunakan pendekatan **Local-First** dengan sinkronisasi cloud.

```
┌─────────────────┐    HTTP/REST API    ┌─────────────────┐
│   Flutter App   │ ◄─────────────────► │  Express.js API │
│   (Mobile UI)   │                     │   (Backend)     │
└─────────────────┘                     └─────────────────┘
         │                                        │
         ▼                                        ▼
┌─────────────────┐                     ┌─────────────────┐
│  Hive Database  │                     │ MySQL Database │
│   (Local)       │                     │   (Cloud)       │
└─────────────────┘                     └─────────────────┘
```

## 🛠️ Stack Teknologi

### Frontend (Mobile)
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: ValueNotifier, setState
- **Local Database**: Hive (NoSQL)
- **HTTP Client**: http package
- **Charts**: Syncfusion Flutter Charts
- **File Operations**: path_provider, open_file
- **Permissions**: permission_handler

### Backend (API Server)
- **Runtime**: Node.js 18.x
- **Framework**: Express.js 5.x
- **Language**: JavaScript (ES6+)
- **Database**: MySQL 8.0
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: Helmet.js, CORS, bcrypt
- **PDF Generation**: PDFKit
- **Environment**: Docker containers

### Database
- **Primary**: MySQL 8.0 (Relational)
- **Local Cache**: Hive (Key-Value)
- **Admin Interface**: phpMyAdmin

### DevOps & Infrastructure
- **Containerization**: Docker & Docker Compose
- **Networking**: Docker bridge network
- **Volume Management**: Docker volumes
- **Health Checks**: MySQL health monitoring

## 📊 Arsitektur Database

### MySQL Schema
```sql
-- Users & Authentication
users (id, name, email, password_hash, telegram_chat_id, created_at, updated_at)

-- Account Management
accounts (id, user_id, name, type, created_at)

-- Transaction Categories
categories (id, account_id, name, type, created_at)

-- Financial Transactions
transactions (id, account_id, category_id, amount, type, description, 
             transaction_date, local_id, is_synced, created_at, updated_at)

-- Synchronization
sync_logs (id, user_id, device_id, last_sync)
telegram_logs (id, user_id, command, created_at)
```

### Hive Schema (Local)
```dart
@HiveType(typeId: 1)
class Add_data {
  @HiveField(0) String name;        // Category name
  @HiveField(1) String explain;     // Description
  @HiveField(2) String amount;      // Transaction amount
  @HiveField(3) String IN;          // Income/Expense type
  @HiveField(4) DateTime datetime;  // Transaction date
}
```

## 🔄 Data Flow Architecture

### 1. Local-First Approach
```
User Input → Hive (Immediate) → Background Sync → MySQL
```

### 2. Synchronization Strategy
- **Write**: Local first, then sync to cloud
- **Read**: Local first, fallback to cloud
- **Conflict Resolution**: Last-write-wins
- **Offline Support**: Full functionality without internet

### 3. API Communication
```
Flutter ←→ Express.js ←→ MySQL
   ↓           ↓           ↓
 Hive      JWT Auth   Persistent
(Local)   (Security)   Storage
```

## 🔐 Security Architecture

### Authentication Flow
```
1. User Login → Express.js validates → JWT Token generated
2. Token stored locally → Sent with each API request
3. Express.js verifies JWT → Access granted/denied
```

### Security Measures
- **Password Hashing**: bcrypt with salt rounds
- **JWT Tokens**: Secure token-based authentication
- **CORS Policy**: Controlled cross-origin requests
- **Input Validation**: Server-side validation
- **SQL Injection Protection**: Parameterized queries
- **Rate Limiting**: Brute force protection
- **Security Headers**: Helmet.js implementation

## 📱 Flutter Architecture

### Project Structure
```
lib/
├── config/          # App configuration
├── data/           # Data models & utilities
│   ├── model/      # Hive data models
│   └── utlity.dart # Data processing functions
├── Screens/        # UI screens
├── services/       # API & business logic
├── utils/          # Helper utilities
└── widgets/        # Reusable UI components
```

### State Management Pattern
- **Local State**: setState() for UI updates
- **Global State**: ValueNotifier for cross-widget communication
- **Data Persistence**: Hive for local storage
- **API State**: Future/async patterns

### Navigation Architecture
```
Main App → Bottom Navigation → Screen Stack
    ↓
┌─ Home Screen
├─ Add Transaction Screen
├─ Statistics Screen (with PDF export)
├─ Profile Screen
└─ Utility Screens (Sync, Debug)
```

## 🖥️ Backend Architecture

### Express.js Structure
```
backend/
├── server.js           # Main application file
├── middleware/         # Custom middleware (removed for simplicity)
├── package.json        # Dependencies
├── .env               # Environment variables
└── Dockerfile         # Container configuration
```

### API Endpoints
```
Authentication:
POST /api/auth/register  # User registration
POST /api/auth/login     # User login

Transactions:
GET  /api/transactions/:accountId     # Get transactions
POST /api/transactions-simple         # Create transaction (test)
GET  /api/transactions-count          # Get transaction count

Reports:
GET  /api/finance/pdf-test            # Generate PDF report

Accounts & Categories:
GET  /api/accounts                    # Get user accounts
GET  /api/categories/:accountId       # Get categories

Sync:
POST /api/sync/transactions           # Bulk sync transactions
```

### Middleware Stack
```
Request → Helmet (Security) → CORS → Body Parser → Routes → Response
```

## 🐳 Docker Architecture

### Container Orchestration
```yaml
Services:
├── mysql (Database)
│   ├── Port: 3306
│   ├── Volume: mysql_data
│   └── Health Check: mysqladmin ping
├── phpmyadmin (Database Admin)
│   ├── Port: 8080
│   └── Depends: mysql
└── backend (API Server)
    ├── Port: 3000
    ├── Volume: ./backend:/app
    └── Depends: mysql (healthy)
```

### Network Configuration
- **Bridge Network**: cakue_network
- **Internal Communication**: Container-to-container
- **External Access**: Host port mapping

## 📊 Performance Architecture

### Optimization Strategies
1. **Local-First**: Immediate UI response
2. **Background Sync**: Non-blocking data sync
3. **Connection Pooling**: MySQL connection management
4. **Caching**: Hive for local data caching
5. **Lazy Loading**: On-demand data fetching

### Scalability Considerations
- **Horizontal Scaling**: Multiple backend instances
- **Database Sharding**: User-based partitioning
- **CDN Integration**: Static asset delivery
- **Load Balancing**: Traffic distribution

## 🔄 Synchronization Architecture

### Sync Strategies
```
1. Manual Sync: User-triggered synchronization
2. Auto Sync: Background periodic sync
3. Conflict Resolution: Last-write-wins policy
4. Offline Queue: Store operations for later sync
```

### Data Consistency
- **Eventual Consistency**: Local and remote data converge
- **Optimistic Updates**: UI updates immediately
- **Rollback Mechanism**: Revert on sync failure

## 📈 Monitoring & Analytics

### Health Monitoring
- **Database Health**: MySQL ping checks
- **API Health**: Express.js health endpoints
- **Sync Status**: Local vs remote data comparison

### Performance Metrics
- **Response Time**: API endpoint performance
- **Sync Success Rate**: Data synchronization reliability
- **Error Tracking**: Exception monitoring

## 🚀 Deployment Architecture

### Development Environment
```
Local Machine → Docker Compose → Multi-container setup
```

### Production Considerations
- **Container Registry**: Docker image storage
- **Orchestration**: Kubernetes/Docker Swarm
- **Database**: Managed MySQL service
- **Monitoring**: Application performance monitoring
- **Backup**: Automated database backups

## 🔧 Configuration Management

### Environment Variables
```bash
# Database
DB_HOST=mysql
DB_USER=root
DB_PASSWORD=root123
DB_NAME=cakue_db

# Security
JWT_SECRET=secure-secret-key
JWT_EXPIRES_IN=24h

# Application
PORT=3000
NODE_ENV=production
```

### Flutter Configuration
```dart
class AppConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const int requestTimeout = 30;
  static const int maxRetries = 3;
}
```

## 📋 Technology Decisions

### Why Flutter?
- **Cross-platform**: Single codebase for iOS/Android
- **Performance**: Native compilation
- **UI Flexibility**: Custom widget system
- **Local Storage**: Hive integration

### Why Express.js?
- **Simplicity**: Minimal setup and configuration
- **Ecosystem**: Rich npm package ecosystem
- **Performance**: Non-blocking I/O
- **Flexibility**: Unopinionated framework

### Why MySQL?
- **ACID Compliance**: Data integrity
- **Mature Ecosystem**: Tools and community
- **Performance**: Optimized for read/write operations
- **Scalability**: Proven at scale

### Why Docker?
- **Consistency**: Same environment everywhere
- **Isolation**: Service separation
- **Scalability**: Easy horizontal scaling
- **Development**: Simplified local setup

## 🎯 Future Architecture Considerations

### Planned Enhancements
1. **Microservices**: Service decomposition
2. **Event Sourcing**: Audit trail implementation
3. **CQRS**: Command Query Responsibility Segregation
4. **Real-time Sync**: WebSocket implementation
5. **Multi-tenant**: SaaS architecture support

### Technology Upgrades
- **Flutter**: Latest stable version
- **Node.js**: LTS version updates
- **MySQL**: Version 8.x optimizations
- **Container**: Kubernetes migration

---

**Dokumentasi ini mencakup arsitektur lengkap sistem CAKUE dengan fokus pada skalabilitas, keamanan, dan maintainability.**