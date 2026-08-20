require('dotenv').config();
const express = require('express');
const cors = require('cors');

if (!process.env.JWT_SECRET) {
  console.error('FATAL: JWT_SECRET is not set. Add it to your .env file before starting the server.');
  process.exit(1);
}

const app = express();

app.use(cors()); // Tighten this to your app's origin(s) in production if needed
app.use(express.json({ limit: '1mb' }));

// Basic request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.use('/api/auth', require('./routes/auth'));
app.use('/api/reminders', require('./routes/reminders'));
app.use('/api/favorites', require('./routes/favorites'));

// 404 handler
app.use((req, res) => res.status(404).json({ error: 'Not found' }));

// Global error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`SmartSpot API listening on port ${PORT}`));
