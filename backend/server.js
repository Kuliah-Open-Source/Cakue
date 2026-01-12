const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const PDFDocument = require('pdfkit');
require('dotenv').config();



const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET;

// Security check for JWT_SECRET
if (!JWT_SECRET || JWT_SECRET.length < 32) {
  console.error('ERROR: JWT_SECRET must be set and at least 32 characters long');
  process.exit(1);
}

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Simple test endpoint
app.get('/api/test', (req, res) => {
  res.json({ message: 'API is working', timestamp: new Date().toISOString() });
});

const dbConfig = {
  host: process.env.DB_HOST || 'mysql',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'cakue_user',
  password: process.env.DB_PASSWORD || 'cakue123',
  database: process.env.DB_NAME || 'cakue_db'
};

let db;

async function connectDB() {
  try {
    db = await mysql.createConnection(dbConfig);
    console.log('Connected to MySQL database');
    
    // Initialize database schema
    await initializeSchema();
  } catch (error) {
    console.error('Database connection failed:', error);
    setTimeout(connectDB, 5000);
  }
}

async function initializeSchema() {
  try {
    // Create users table
    await db.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        telegram_chat_id BIGINT UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);

    // Create accounts table
    await db.execute(`
      CREATE TABLE IF NOT EXISTS accounts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        type ENUM('personal', 'business') NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    // Create categories table
    await db.execute(`
      CREATE TABLE IF NOT EXISTS categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        account_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        type ENUM('income', 'expense') NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
      )
    `);

    // Create transactions table
    await db.execute(`
      CREATE TABLE IF NOT EXISTS transactions (
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
      )
    `);

    // Create sync_logs table
    await db.execute(`
      CREATE TABLE IF NOT EXISTS sync_logs (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        device_id VARCHAR(100) NOT NULL,
        last_sync TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id),
        UNIQUE KEY unique_user_device (user_id, device_id)
      )
    `);

    // Create telegram_logs table
    await db.execute(`
      CREATE TABLE IF NOT EXISTS telegram_logs (
        id BIGINT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        command VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    `);

    console.log('Database schema initialized');
  } catch (error) {
    console.error('Schema initialization failed:', error);
  }
}

// Middleware for JWT authentication
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
}

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Cakue Backend API is running!' });
});

// Auth Routes
app.post('/api/auth/register', async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    
    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);
    
    // Create user
    const [result] = await db.execute(
      'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)',
      [name, email, passwordHash]
    );
    
    // Create default personal account
    const [accountResult] = await db.execute(
      'INSERT INTO accounts (user_id, name, type) VALUES (?, ?, ?)',
      [result.insertId, 'Personal Account', 'personal']
    );
    
    // Create default categories
    const defaultCategories = [
      [accountResult.insertId, 'Food', 'expense'],
      [accountResult.insertId, 'Transportation', 'expense'],
      [accountResult.insertId, 'Education', 'expense'],
      [accountResult.insertId, 'Transfer', 'expense'],
      [accountResult.insertId, 'Salary', 'income'],
      [accountResult.insertId, 'Business', 'income']
    ];
    
    for (const category of defaultCategories) {
      await db.execute(
        'INSERT INTO categories (account_id, name, type) VALUES (?, ?, ?)',
        category
      );
    }
    
    res.status(201).json({ 
      message: 'User registered successfully',
      userId: result.insertId 
    });
  } catch (error) {
    next(error);
  }
});

app.post('/api/auth/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    const [rows] = await db.execute(
      'SELECT id, name, email, password_hash FROM users WHERE email = ?',
      [email]
    );
    
    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const user = rows[0];
    const validPassword = await bcrypt.compare(password, user.password_hash);
    
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    });
  } catch (error) {
    next(error);
  }
});

// Account Routes
app.get('/api/accounts', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM accounts WHERE user_id = ?',
      [req.user.userId]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/accounts', authenticateToken, async (req, res) => {
  try {
    const { name, type } = req.body;
    const [result] = await db.execute(
      'INSERT INTO accounts (user_id, name, type) VALUES (?, ?, ?)',
      [req.user.userId, name, type]
    );
    res.status(201).json({ id: result.insertId, name, type });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Category Routes
app.get('/api/categories/:accountId', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT c.* FROM categories c JOIN accounts a ON c.account_id = a.id WHERE c.account_id = ? AND a.user_id = ?',
      [req.params.accountId, req.user.userId]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get transaction count
app.get('/api/transactions-count', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT COUNT(*) as count FROM transactions');
    res.json({ count: rows[0].count });
  } catch (error) {
    console.error('Count error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Simple transaction endpoint for testing
app.get('/api/transactions-simple', async (req, res) => {
  try {
    const { account_id, category_id, amount, type, description, transaction_date } = req.query;
    
    console.log('Creating transaction:', { account_id, category_id, amount, type, description, transaction_date });
    
    const [result] = await db.execute(
      'INSERT INTO transactions (account_id, category_id, amount, type, description, transaction_date) VALUES (?, ?, ?, ?, ?, ?)',
      [account_id || 3, category_id || 13, amount || 10000, type || 'expense', description || 'Test', transaction_date || '2026-01-12']
    );
    
    res.json({ 
      success: true,
      id: result.insertId,
      message: 'Transaction created'
    });
  } catch (error) {
    console.error('Transaction error:', error);
    res.status(500).json({ error: error.message });
  }
});
app.post('/api/transactions-test', async (req, res) => {
  try {
    console.log('Received transaction data:', req.body);
    
    const { account_id, category_id, amount, type, description, transaction_date, local_id } = req.body;
    
    // Simple validation
    if (!account_id || !category_id || !amount || !type || !transaction_date) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    const [result] = await db.execute(
      'INSERT INTO transactions (account_id, category_id, amount, type, description, transaction_date, local_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [account_id, category_id, amount, type, description || '', transaction_date, local_id || null]
    );
    
    console.log('Transaction inserted with ID:', result.insertId);
    
    res.status(201).json({ 
      id: result.insertId,
      local_id,
      server_id: result.insertId,
      message: 'Transaction created successfully'
    });
  } catch (error) {
    console.error('Transaction creation error:', error);
    res.status(500).json({ error: 'Failed to create transaction' });
  }
});

// Transaction Routes
app.get('/api/transactions/:accountId', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT t.*, c.name as category_name 
       FROM transactions t 
       JOIN categories c ON t.category_id = c.id 
       JOIN accounts a ON t.account_id = a.id 
       WHERE t.account_id = ? AND a.user_id = ? 
       ORDER BY t.transaction_date DESC`,
      [req.params.accountId, req.user.userId]
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/transactions', authenticateToken, async (req, res, next) => {
  try {
    const { account_id, category_id, amount, type, description, transaction_date, local_id } = req.body;
    
    // Verify account belongs to user
    const [accountCheck] = await db.execute(
      'SELECT id FROM accounts WHERE id = ? AND user_id = ?',
      [account_id, req.user.userId]
    );
    
    if (accountCheck.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }
    
    const [result] = await db.execute(
      'INSERT INTO transactions (account_id, category_id, amount, type, description, transaction_date, local_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [account_id, category_id, amount, type, description, transaction_date, local_id]
    );
    
    res.status(201).json({ 
      id: result.insertId,
      local_id,
      server_id: result.insertId
    });
  } catch (error) {
    next(error);
  }
});

// Sync Routes
app.post('/api/sync/transactions', authenticateToken, async (req, res) => {
  try {
    const { transactions, device_id } = req.body;
    const results = [];
    
    for (const transaction of transactions) {
      try {
        const [result] = await db.execute(
          'INSERT INTO transactions (account_id, category_id, amount, type, description, transaction_date, local_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [transaction.account_id, transaction.category_id, transaction.amount, transaction.type, transaction.description, transaction.transaction_date, transaction.local_id]
        );
        
        results.push({
          local_id: transaction.local_id,
          server_id: result.insertId,
          success: true
        });
      } catch (error) {
        results.push({
          local_id: transaction.local_id,
          success: false,
          error: error.message
        });
      }
    }
    
    // Update sync log
    await db.execute(
      'INSERT INTO sync_logs (user_id, device_id, last_sync) VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE last_sync = NOW()',
      [req.user.userId, device_id]
    );
    
    res.json({ results });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PDF Export Route (Real data from database)
app.get('/api/finance/pdf-test', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }
    
    // Get all transactions from all users (for testing)
    const [transactions] = await db.execute(
      `SELECT t.*, c.name as category_name, u.name as user_name
       FROM transactions t 
       JOIN categories c ON t.category_id = c.id 
       JOIN accounts a ON t.account_id = a.id
       JOIN users u ON a.user_id = u.id
       WHERE t.transaction_date BETWEEN ? AND ?
       ORDER BY t.transaction_date DESC`,
      [startDate, endDate]
    );
    
    // Create PDF
    const doc = new PDFDocument();
    
    // Set response headers
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="financial-report-${startDate}-to-${endDate}.pdf"`);
    
    // Pipe PDF to response
    doc.pipe(res);
    
    // Add content to PDF
    doc.fontSize(20).text('CAKUE Financial Report', 50, 50);
    doc.fontSize(12).text(`Period: ${startDate} to ${endDate}`, 50, 80);
    doc.text(`Generated: ${new Date().toLocaleDateString()}`, 50, 100);
    doc.text(`Total Transactions: ${transactions.length}`, 50, 120);
    
    // Add line
    doc.moveTo(50, 140).lineTo(550, 140).stroke();
    
    let yPosition = 160;
    let totalIncome = 0;
    let totalExpense = 0;
    
    // Table headers
    doc.fontSize(10)
       .text('Date', 50, yPosition)
       .text('Category', 120, yPosition)
       .text('Description', 200, yPosition)
       .text('Type', 320, yPosition)
       .text('Amount', 420, yPosition)
       .text('User', 480, yPosition);
    
    yPosition += 20;
    doc.moveTo(50, yPosition).lineTo(550, yPosition).stroke();
    yPosition += 10;
    
    // Add transactions
    if (transactions.length === 0) {
      doc.fontSize(12).text('No transactions found for this period', 50, yPosition + 20);
    } else {
      transactions.forEach(transaction => {
        if (yPosition > 700) {
          doc.addPage();
          yPosition = 50;
        }
        
        const amount = parseFloat(transaction.amount);
        if (transaction.type === 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
        
        // Format date properly
        const transactionDate = new Date(transaction.transaction_date);
        const formattedDate = transactionDate.toISOString().split('T')[0];
        
        doc.fontSize(8)
           .text(formattedDate, 50, yPosition)
           .text(transaction.category_name || 'N/A', 120, yPosition)
           .text((transaction.description || 'No description').substring(0, 20), 200, yPosition)
           .text(transaction.type, 320, yPosition)
           .text(amount.toLocaleString(), 420, yPosition)
           .text((transaction.user_name || 'Unknown').substring(0, 10), 480, yPosition);
        
        yPosition += 15;
      });
    }
    
    // Add summary
    yPosition += 20;
    doc.moveTo(50, yPosition).lineTo(550, yPosition).stroke();
    yPosition += 20;
    
    doc.fontSize(12)
       .text(`Total Income: ${totalIncome.toLocaleString()}`, 50, yPosition)
       .text(`Total Expense: ${totalExpense.toLocaleString()}`, 200, yPosition)
       .text(`Balance: ${(totalIncome - totalExpense).toLocaleString()}`, 350, yPosition);
    
    // Finalize PDF
    doc.end();
    
  } catch (error) {
    console.error('PDF generation error:', error);
    res.status(500).json({ error: 'Failed to generate PDF' });
  }
});

// PDF Export Route
app.get('/api/finance/pdf', authenticateToken, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Start date and end date are required' });
    }
    
    // Get user's account
    const [accounts] = await db.execute(
      'SELECT id FROM accounts WHERE user_id = ? LIMIT 1',
      [req.user.userId]
    );
    
    if (accounts.length === 0) {
      return res.status(404).json({ error: 'No account found' });
    }
    
    const accountId = accounts[0].id;
    
    // Get transactions
    const [transactions] = await db.execute(
      `SELECT t.*, c.name as category_name 
       FROM transactions t 
       JOIN categories c ON t.category_id = c.id 
       WHERE t.account_id = ? AND t.transaction_date BETWEEN ? AND ?
       ORDER BY t.transaction_date DESC`,
      [accountId, startDate, endDate]
    );
    
    // Create PDF
    const doc = new PDFDocument();
    
    // Set response headers
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="financial-report-${startDate}-to-${endDate}.pdf"`);
    
    // Pipe PDF to response
    doc.pipe(res);
    
    // Add content to PDF
    doc.fontSize(20).text('CAKUE Financial Report', 50, 50);
    doc.fontSize(12).text(`Period: ${startDate} to ${endDate}`, 50, 80);
    doc.text(`Generated: ${new Date().toLocaleDateString()}`, 50, 100);
    
    // Add line
    doc.moveTo(50, 120).lineTo(550, 120).stroke();
    
    let yPosition = 140;
    let totalIncome = 0;
    let totalExpense = 0;
    
    // Table headers
    doc.fontSize(10)
       .text('Date', 50, yPosition)
       .text('Category', 120, yPosition)
       .text('Description', 200, yPosition)
       .text('Type', 350, yPosition)
       .text('Amount', 450, yPosition);
    
    yPosition += 20;
    doc.moveTo(50, yPosition).lineTo(550, yPosition).stroke();
    yPosition += 10;
    
    // Add transactions
    transactions.forEach(transaction => {
      if (yPosition > 700) {
        doc.addPage();
        yPosition = 50;
      }
      
      const amount = parseFloat(transaction.amount);
      if (transaction.type === 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
      
      doc.fontSize(9)
         .text(transaction.transaction_date, 50, yPosition)
         .text(transaction.category_name, 120, yPosition)
         .text(transaction.description || '-', 200, yPosition)
         .text(transaction.type, 350, yPosition)
         .text(amount.toLocaleString(), 450, yPosition);
      
      yPosition += 15;
    });
    
    // Add summary
    yPosition += 20;
    doc.moveTo(50, yPosition).lineTo(550, yPosition).stroke();
    yPosition += 20;
    
    doc.fontSize(12)
       .text(`Total Income: ${totalIncome.toLocaleString()}`, 50, yPosition)
       .text(`Total Expense: ${totalExpense.toLocaleString()}`, 250, yPosition)
       .text(`Balance: ${(totalIncome - totalExpense).toLocaleString()}`, 450, yPosition);
    
    // Finalize PDF
    doc.end();
    
  } catch (error) {
    console.error('PDF generation error:', error);
    res.status(500).json({ error: 'Failed to generate PDF' });
  }
});

// Reports Routes
app.get('/api/reports/:accountId', authenticateToken, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    const [rows] = await db.execute(
      `SELECT 
         type,
         SUM(amount) as total,
         COUNT(*) as count
       FROM transactions t
       JOIN accounts a ON t.account_id = a.id
       WHERE t.account_id = ? AND a.user_id = ?
       AND t.transaction_date BETWEEN ? AND ?
       GROUP BY type`,
      [req.params.accountId, req.user.userId, startDate, endDate]
    );
    
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  connectDB();
});

// Basic error handling
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});