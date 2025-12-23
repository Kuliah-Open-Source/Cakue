# Cakue Backend Setup

## Quick Start

1. **Start all services:**
   ```bash
   docker-compose up -d
   ```

2. **Access services:**
   - Backend API: http://localhost:3000
   - phpMyAdmin: http://localhost:8080
   - MySQL: localhost:3306

3. **phpMyAdmin Login:**
   - Server: mysql
   - Username: root
   - Password: root123

## API Endpoints

- `GET /` - Health check
- `GET /api/users` - Get all users
- `POST /api/users` - Create user (body: {name, email})

## Database Credentials

- Database: cakue_db
- User: cakue_user
- Password: cakue123
- Root Password: root123