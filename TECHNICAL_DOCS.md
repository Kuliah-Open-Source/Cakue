# Cakue Management System - Technical Documentation

## 🏗️ Architecture Overview

Cakue is a full-stack financial management system designed for offline-first operation with multi-device synchronization capabilities.

### Tech Stack
- **Frontend**: Flutter (Mobile)
- **Backend**: Express.js (Node.js)
- **Database**: MySQL 8.0
- **Containerization**: Docker & Docker Compose
- **Authentication**: JWT
- **Local Storage**: Hive (Flutter)

---

## 📊 Database Schema

### Core Tables

#### 1. `users` - User Management
```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  telegram_chat_id BIGINT UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 2. `accounts` - Personal & Business Accounts
```sql
CREATE TABLE accounts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  type ENUM('personal', 'business') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### 3. `categories` - Transaction Categories
```sql
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  account_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  type ENUM('income', 'expense') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
);
```

#### 4. `transactions` - Financial Records
```sql
CREATE TABLE transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  account_id INT NOT NULL,
  category_id INT NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  type ENUM('income', 'expense') NOT NULL,
  description TEXT,
  transaction_date DATE NOT NULL,
  local_id VARCHAR(100) UNIQUE,
  is_synced BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (account_id) REFERENCES accounts(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

#### 5. `sync_logs` - Multi-Device Synchronization
```sql
CREATE TABLE sync_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  device_id VARCHAR(100) NOT NULL,
  last_sync TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## 🔄 Offline Synchronization Strategy

### Flutter Local Storage (Hive)
```dart
@HiveType(typeId: 0)
class LocalTransaction extends HiveObject {
  @HiveField(0) String localId;        // UUID for offline tracking
  @HiveField(1) int accountId;
  @HiveField(2) int categoryId;
  @HiveField(3) double amount;
  @HiveField(4) String type;           // income/expense
  @HiveField(5) String description;
  @HiveField(6) DateTime transactionDate;
  @HiveField(7) bool isSynced;         // false when offline
  @HiveField(8) DateTime createdAt;
}
```

### Sync Flow
1. **Offline Mode**: Store transactions locally with `isSynced = false`
2. **Online Detection**: Queue unsynced transactions
3. **Batch Sync**: Send all pending transactions to backend
4. **Conflict Resolution**: Use `local_id` for deduplication
5. **Update Status**: Mark transactions as `isSynced = true`

---

## 🔐 Authentication & Security

### JWT Implementation
- **Login**: Returns JWT token valid for 24 hours
- **Protected Routes**: Require `Authorization: Bearer <token>`
- **Password Security**: bcrypt hashing with salt rounds

### API Endpoints
```
POST /api/auth/register    # User registration
POST /api/auth/login       # User authentication
GET  /api/accounts         # Get user accounts
POST /api/transactions     # Create transaction
POST /api/sync/transactions # Batch sync offline data
GET  /api/reports/:accountId # Financial reports
```

---

## 📱 Flutter App Structure

### Screens
- **LoginScreen**: JWT authentication
- **RegisterScreen**: User registration
- **Home**: Dashboard with balance overview
- **Statistics**: Charts and analytics
- **Add**: Transaction input form
- **WalletScreen**: Account management
- **ProfileScreen**: User settings

### Services
- **AuthService**: API authentication
- **SyncService**: Offline synchronization
- **HiveService**: Local data management

---

## 🐳 Docker Deployment

### Services
- **MySQL**: Database server (port 3306)
- **phpMyAdmin**: Database management (port 8080)
- **Backend**: Express.js API (port 3000)

### Environment Variables
```env
DB_HOST=mysql
DB_PORT=3306
DB_NAME=cakue_db
DB_USER=cakue_user
DB_PASSWORD=cakue123
JWT_SECRET=cakue_jwt_secret_key_2024
```

---

## 🚀 Quick Start

### 1. Start Backend Services
```bash
docker-compose up -d
```

### 2. Run Flutter App
```bash
cd flutter
flutter pub get
flutter run
```

### 3. Access Services
- Backend API: http://localhost:3000
- phpMyAdmin: http://localhost:8080
- MySQL: localhost:3306

---

## 🔮 Future Enhancements

### Phase 2 - Telegram Bot Integration
- Connect via `telegram_chat_id`
- Daily/Monthly reports via bot
- PDF export functionality
- Voice transaction input

### Phase 3 - Advanced Features
- Budget planning & alerts
- Expense categorization AI
- Multi-currency support
- Investment tracking
- Receipt scanning (OCR)

---

## 🛠️ Development Guidelines

### Database Best Practices
- Use DECIMAL(15,2) for monetary values
- Store timestamps in UTC
- Index frequently queried columns
- Implement proper foreign key constraints

### Flutter Best Practices
- Offline-first architecture
- Proper error handling
- Secure local storage encryption
- Batch API calls for efficiency

### Security Considerations
- Never store passwords in plaintext
- Validate all user inputs
- Use HTTPS in production
- Implement rate limiting
- Regular security audits

---

## 📈 Performance Metrics

### Target Benchmarks
- App startup: < 3 seconds
- Transaction sync: < 5 seconds for 100 items
- Database queries: < 100ms average
- Offline capability: 30 days without sync

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Follow coding standards
4. Write comprehensive tests
5. Submit pull request

---

## 📄 License

MIT License - see LICENSE file for details