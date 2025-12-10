const express = require('express');
const { Pool } = require('pg');
const vaultIntegration = require('./vault-integration');

const app = express();
app.use(express.json());

// Инициализация подключения к базе данных с поддержкой Vault
let pool = null;

// Асинхронная инициализация подключения к БД
async function initDatabase() {
  try {
    // Получение конфигурации БД из Vault или переменных окружения
    const dbConfig = await vaultIntegration.getDatabaseConfig();
    
    // Использование connection string или отдельных параметров
    const connectionString = dbConfig.connectionString || 
      `postgres://${dbConfig.username}:${dbConfig.password}@${dbConfig.host}:${dbConfig.port}/${dbConfig.database}`;
    
    pool = new Pool({
      connectionString: connectionString,
      // Дополнительные параметры подключения
      max: 20, // Максимальное количество клиентов в пуле
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });

    // Проверка подключения
    const client = await pool.connect();
    console.log('✓ Подключение к базе данных установлено');
    client.release();
  } catch (error) {
    console.error('Ошибка подключения к базе данных:', error);
    // Fallback на переменную окружения напрямую
    const DATABASE_URL = process.env.DATABASE_URL || 'postgres://appuser:StrongPass123@localhost:5432/appdb';
    pool = new Pool({
      connectionString: DATABASE_URL,
    });
  }
}

// Инициализация при запуске приложения
initDatabase();

app.get('/health', async (req, res) => {
  // Проверка подключения к БД
  if (!pool) {
    return res.status(503).json({ status: 'initializing', message: 'Database connection is being initialized' });
  }
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', database: 'connected' });
  } catch (err) {
    res.status(503).json({ status: 'error', database: 'disconnected', error: err.message });
  }
});

app.get('/users', async (req, res) => {
  if (!pool) {
    return res.status(503).json({ error: 'Database connection not initialized' });
  }
  try {
    const { rows } = await pool.query('SELECT id, name, email FROM users ORDER BY id LIMIT 100');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db error', details: err.message });
  }
});

app.post('/users', async (req, res) => {
  if (!pool) {
    return res.status(503).json({ error: 'Database connection not initialized' });
  }
  const { name, email } = req.body;
  if (!name || !email) return res.status(400).json({ error: 'name & email required' });
  try {
    const { rows } = await pool.query('INSERT INTO users(name,email) VALUES($1,$2) RETURNING id, name, email', [name, email]);
    res.status(201).json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db error', details: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log('Backend listening on', PORT);
  console.log('Environment:', process.env.NODE_ENV || 'development');
});