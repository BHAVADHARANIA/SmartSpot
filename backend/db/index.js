const { Pool } = require('pg');

const connectionString = process.env.DATABASE_URL || process.env.SUPABASE_CONNECTION_STRING;

if (!connectionString) {
  console.error('FATAL: DATABASE_URL is not set in your .env file.');
  process.exit(1);
}

const pool = new Pool({
  connectionString,
  ssl: {
    rejectUnauthorized: false,
  },
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

pool.on('connect', () => {
  console.log('Connected to Supabase PostgreSQL Database');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle Supabase client', err);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};