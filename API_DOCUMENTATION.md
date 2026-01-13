# 🔌 CAKUE API Documentation

## Base URL
```
Development: http://localhost:3000
Production: https://api.cakue.com (planned)
```

## Authentication
Most endpoints require JWT authentication via Bearer token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## 📋 API Endpoints

### 🔐 Authentication

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

**Response (201):**
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

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

### 💰 Transactions

#### Create Transaction (Test Endpoint)
```http
GET /api/transactions-simple?account_id=3&category_id=13&amount=50000&type=expense&description=Lunch&transaction_date=2026-01-12
```

**Response (200):**
```json
{
  "success": true,
  "id": 5,
  "message": "Transaction created"
}
```

#### Get Transaction Count
```http
GET /api/transactions-count
```

**Response (200):**
```json
{
  "count": 10
}
```

#### Get Transactions (Authenticated)
```http
GET /api/transactions/:accountId
Authorization: Bearer <token>
```

**Response (200):**
```json
[
  {
    "id": 1,
    "account_id": 3,
    "category_id": 13,
    "amount": "50000.00",
    "type": "expense",
    "description": "Lunch at restaurant",
    "transaction_date": "2026-01-12",
    "category_name": "Food",
    "created_at": "2026-01-12T10:30:00.000Z"
  }
]
```

#### Create Transaction (Authenticated)
```http
POST /api/transactions
Authorization: Bearer <token>
Content-Type: application/json

{
  "account_id": 3,
  "category_id": 13,
  "amount": 50000,
  "type": "expense",
  "description": "Lunch at restaurant",
  "transaction_date": "2026-01-12",
  "local_id": "local_123"
}
```

**Response (201):**
```json
{
  "id": 5,
  "local_id": "local_123",
  "server_id": 5
}
```

### 🏦 Accounts

#### Get User Accounts
```http
GET /api/accounts
Authorization: Bearer <token>
```

**Response (200):**
```json
[
  {
    "id": 3,
    "user_id": 1,
    "name": "Personal Account",
    "type": "personal",
    "created_at": "2026-01-12T08:00:00.000Z"
  }
]
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

**Response (201):**
```json
{
  "id": 4,
  "name": "Business Account",
  "type": "business"
}
```

### 🏷️ Categories

#### Get Account Categories
```http
GET /api/categories/:accountId
Authorization: Bearer <token>
```

**Response (200):**
```json
[
  {
    "id": 13,
    "account_id": 3,
    "name": "Food",
    "type": "expense",
    "created_at": "2026-01-12T08:00:00.000Z"
  },
  {
    "id": 17,
    "account_id": 3,
    "name": "Salary",
    "type": "income",
    "created_at": "2026-01-12T08:00:00.000Z"
  }
]
```

### 📊 Reports

#### Generate PDF Report
```http
GET /api/finance/pdf-test?startDate=2026-01-01&endDate=2026-12-31
```

**Response (200):**
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="financial-report-2026-01-01-to-2026-12-31.pdf"

[PDF Binary Data]
```

#### Get Reports Data
```http
GET /api/reports/:accountId?startDate=2026-01-01&endDate=2026-12-31
Authorization: Bearer <token>
```

**Response (200):**
```json
[
  {
    "type": "income",
    "total": "100000.00",
    "count": 5
  },
  {
    "type": "expense",
    "total": "75000.00",
    "count": 8
  }
]
```

### 🔄 Synchronization

#### Bulk Sync Transactions
```http
POST /api/sync/transactions
Authorization: Bearer <token>
Content-Type: application/json

{
  "device_id": "device_123",
  "transactions": [
    {
      "account_id": 3,
      "category_id": 13,
      "amount": 25000,
      "type": "expense",
      "description": "Coffee",
      "transaction_date": "2026-01-12",
      "local_id": "local_456"
    }
  ]
}
```

**Response (200):**
```json
{
  "results": [
    {
      "local_id": "local_456",
      "server_id": 6,
      "success": true
    }
  ]
}
```

### 🔍 Utility

#### Health Check
```http
GET /api/test
```

**Response (200):**
```json
{
  "message": "API is working",
  "timestamp": "2026-01-12T15:30:00.000Z"
}
```

#### API Status
```http
GET /
```

**Response (200):**
```json
{
  "message": "Cakue Backend API is running!"
}
```

## 📝 Data Models

### User
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2026-01-12T08:00:00.000Z",
  "updated_at": "2026-01-12T08:00:00.000Z"
}
```

### Account
```json
{
  "id": 3,
  "user_id": 1,
  "name": "Personal Account",
  "type": "personal",
  "created_at": "2026-01-12T08:00:00.000Z"
}
```

### Category
```json
{
  "id": 13,
  "account_id": 3,
  "name": "Food",
  "type": "expense",
  "created_at": "2026-01-12T08:00:00.000Z"
}
```

### Transaction
```json
{
  "id": 1,
  "account_id": 3,
  "category_id": 13,
  "amount": "50000.00",
  "type": "expense",
  "description": "Lunch at restaurant",
  "transaction_date": "2026-01-12",
  "local_id": "local_123",
  "is_synced": true,
  "created_at": "2026-01-12T10:30:00.000Z",
  "updated_at": "2026-01-12T10:30:00.000Z"
}
```

## ❌ Error Responses

### 400 Bad Request
```json
{
  "error": "Missing required fields"
}
```

### 401 Unauthorized
```json
{
  "error": "Access token required"
}
```

### 403 Forbidden
```json
{
  "error": "Invalid token"
}
```

### 404 Not Found
```json
{
  "error": "Route not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error"
}
```

## 🔧 Request/Response Headers

### Common Request Headers
```
Content-Type: application/json
Authorization: Bearer <jwt_token>
Accept: application/json
```

### Common Response Headers
```
Content-Type: application/json
Access-Control-Allow-Origin: *
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
```

## 📊 Rate Limiting

- **General Endpoints**: 100 requests per 15 minutes
- **Login Endpoint**: 5 requests per 15 minutes
- **PDF Generation**: 10 requests per hour

## 🔐 Security Headers

All responses include security headers via Helmet.js:
- Content Security Policy
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy
- Strict-Transport-Security

## 📱 Flutter Integration

### HTTP Client Setup
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  
  static Future<http.Response> get(String endpoint, {String? token}) {
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
```

### Error Handling
```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  return data;
} else {
  throw Exception('API Error: ${response.statusCode}');
}
```

## 🧪 Testing

### cURL Examples
```bash
# Health check
curl http://localhost:3000/api/test

# Create transaction
curl -X GET "http://localhost:3000/api/transactions-simple?amount=50000&type=expense&description=Test"

# Get transaction count
curl http://localhost:3000/api/transactions-count

# Download PDF
curl "http://localhost:3000/api/finance/pdf-test?startDate=2026-01-01&endDate=2026-12-31" -o report.pdf
```

### Postman Collection
Import the following endpoints into Postman for testing:
- Base URL: `http://localhost:3000`
- Environment variables: `{{baseUrl}}`

---

**API ini mendukung aplikasi CAKUE dengan fokus pada keamanan, performa, dan kemudahan integrasi.**