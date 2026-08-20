const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const { body, validationResult } = require('express-validator');
const db = require('../db');

const router = express.Router();

function signToken(userId) {
  return jwt.sign({ sub: userId }, process.env.JWT_SECRET, { expiresIn: '30d' });
}

function publicUser(u) {
  return { id: u.id, email: u.email, name: u.name, createdAt: u.created_at };
}

// ---------- Register ----------
router.post(
  '/register',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
    body('name').optional().isString().trim(),
  ],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

    const { email, password, name } = req.body;

    const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
    if (existing) return res.status(409).json({ error: 'An account with this email already exists' });

    const id = uuidv4();
    const passwordHash = bcrypt.hashSync(password, 10);

    db.prepare(
      'INSERT INTO users (id, email, password_hash, name) VALUES (?, ?, ?, ?)'
    ).run(id, email, passwordHash, name || null);

    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(id);
    const token = signToken(id);

    res.status(201).json({ token, user: publicUser(user) });
  }
);

// ---------- Login ----------
router.post(
  '/login',
  [body('email').isEmail().normalizeEmail(), body('password').notEmpty()],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

    const { email, password } = req.body;
    const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);

    if (!user || !bcrypt.compareSync(password, user.password_hash)) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const token = signToken(user.id);
    res.json({ token, user: publicUser(user) });
  }
);

// ---------- Forgot password (request reset) ----------
// NOTE: In production, wire this to an email provider (SendGrid, SES, Postmark, etc.)
// to actually deliver the reset link. This endpoint issues the token; email sending
// is left as a TODO since it needs your provider credentials.
router.post('/forgot-password', [body('email').isEmail().normalizeEmail()], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

  const { email } = req.body;
  const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);

  // Always respond 200 even if user doesn't exist, to avoid leaking which emails are registered.
  if (!user) return res.json({ message: 'If that email exists, a reset link has been sent.' });

  const resetToken = crypto.randomBytes(32).toString('hex');
  const resetTokenHash = crypto.createHash('sha256').update(resetToken).digest('hex');
  const expires = new Date(Date.now() + 60 * 60 * 1000).toISOString(); // 1 hour

  db.prepare(
    `CREATE TABLE IF NOT EXISTS password_resets (
      token_hash TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      expires_at TEXT NOT NULL
    )`
  ).run();
  db.prepare('DELETE FROM password_resets WHERE user_id = ?').run(user.id);
  db.prepare('INSERT INTO password_resets (token_hash, user_id, expires_at) VALUES (?, ?, ?)').run(
    resetTokenHash,
    user.id,
    expires
  );

  // TODO: send `resetToken` via email instead of returning it.
  res.json({
    message: 'If that email exists, a reset link has been sent.',
    devResetToken: process.env.NODE_ENV === 'production' ? undefined : resetToken,
  });
});

router.post(
  '/reset-password',
  [body('token').notEmpty(), body('password').isLength({ min: 8 })],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

    const { token, password } = req.body;
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

    const row = db
      .prepare('SELECT * FROM password_resets WHERE token_hash = ?')
      .get(tokenHash);

    if (!row || new Date(row.expires_at) < new Date()) {
      return res.status(400).json({ error: 'Reset token is invalid or expired' });
    }

    const passwordHash = bcrypt.hashSync(password, 10);
    db.prepare('UPDATE users SET password_hash = ?, updated_at = datetime(\'now\') WHERE id = ?').run(
      passwordHash,
      row.user_id
    );
    db.prepare('DELETE FROM password_resets WHERE token_hash = ?').run(tokenHash);

    res.json({ message: 'Password updated successfully' });
  }
);

module.exports = router;
