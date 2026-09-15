const { Pool } = require('pg');

const connectionString = process.env.DATABASE_URL
  || process.env.DATABASE_PUBLIC_URL
  || process.env.DATABASE_PRIVATE_URL
  || process.env.POSTGRES_URL
  || process.env.POSTGRES_PUBLIC_URL
  || process.env.POSTGRES_PRIVATE_URL;

const pool = new Pool({
  connectionString,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

pool.on('error', (err) => {
  console.error('Unexpected database error:', err);
});

module.exports = pool;
