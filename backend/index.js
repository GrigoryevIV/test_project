const express = require('express');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

const DATABASE_URL = process.env.DATABASE_URL || 'postgres://appuser:StrongPass123@localhost:5432/appdb';
const pool = new Pool({
  connectionString: DATABASE_URL,
});

app.get('/health', (req, res) => res.json({status: 'ok'}));

app.get('/users', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT id, name, email FROM users ORDER BY id LIMIT 100');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db error', details: err.message });
  }
});

app.post('/users', async (req, res) => {
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
app.listen(PORT, () => console.log('Backend listening on', PORT));