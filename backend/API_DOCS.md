# Cakue Backend API Documentation

Based on flow.txt specifications supporting offline sync, multi-device, and Telegram bot integration.

## Base URL
```
http://localhost:3000
```

## Authentication
All protected endpoints require JWT token in Authorization header:
```
Authorization: Bearer <token>
```

## Endpoints

### Authentication

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "User registered successfully",
  "userId": 1
}
```

#### Login User
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

### Accounts

#### Get User Accounts
```http
GET /api/accounts
Authorization: Bearer <token>
```

#### Create Account
```http
POST /api/accounts
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Business Account",
  "type": "business"
}
```

### Categories

#### Get Account Categories
```http
GET /api/categories/{accountId}
Authorization: Bearer <token>
```

### Transactions

#### Get Account Transactions
```http
GET /api/transactions/{accountId}
Authorization: Bearer <token>
```

#### Create Transaction
```http
POST /api/transactions
Authorization: Bearer <token>
Content-Type: application/json

{
  "account_id": 1,
  "category_id": 1,
  "amount": 50000.00,
  "type": "expense",
  "description": "Lunch",
  "transaction_date": "2024-01-15",
  "local_id": "uuid-123-456"
}
```

### Sync (Offline Support)

#### Sync Transactions
```http
POST /api/sync/transactions
Authorization: Bearer <token>
Content-Type: application/json

{
  "device_id": "device_uuid",
  "transactions": [
    {
      "account_id": 1,
      "category_id": 1,
      "amount": 25000.00,
      "type": "expense",
      "description": "Coffee",
      "transaction_date": "2024-01-15",
      "local_id": "local_uuid_1"
    }
  ]
}
```

**Response:**
```json
{
  "results": [
    {
      "local_id": "local_uuid_1",
      "server_id": 123,
      "success": true
    }
  ]
}
```

### Reports

#### Get Account Report
```http
GET /api/reports/{accountId}?startDate=2024-01-01&endDate=2024-01-31
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "type": "income",
    "total": "150000.00",
    "count": 5
  },
  {
    "type": "expense", 
    "total": "75000.00",
    "count": 12
  }
]
```

## Database Schema

### Tables Created:
- `users` - User accounts with Telegram integration
- `accounts` - Personal/Business account separation
- `categories` - Transaction categories per account
- `transactions` - Financial records with offline sync support
- `sync_logs` - Multi-device synchronization tracking
- `telegram_logs` - Bot activity logging

### Key Features:
- **Offline Sync**: `local_id` field for mapping offline transactions
- **Multi-Device**: `sync_logs` table tracks device synchronization
- **Security**: JWT authentication, bcrypt password hashing
- **Telegram Ready**: `telegram_chat_id` field for bot integration
- **Decimal Precision**: DECIMAL(15,2) for accurate money calculations