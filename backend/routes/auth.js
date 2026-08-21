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

// Register
router.post(
  '/register',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
    body('name').optional().isString().trim(),
  ],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

      const { email, password, name } = req.body;

      const existing = await db.query('SELECT id FROM users WHERE email = $1', [email]);
      if (existing.rows.length > 0) {
        return res.status(409).json({ error: 'An account with this email already exists' });
      }

      const id = uuidv4();
      const passwordHash = bcrypt.hashSync(password, 10);

      await db.query(
        'INSERT INTO users (id, email, password_hash, name) VALUES ($1, $2, $3, $4)',
        [id, email, passwordHash, name || null]
      );

      const userRes = await db.query('SELECT * FROM users WHERE id = $1', [id]);
      const user = userRes.rows[0];
      const token = signToken(id);

      res.status(201).json({ token, user: publicUser(user) });
    } catch (err) {
      next(err);
    }
  }
);

// Login
router.post(
  '/login',
  [body('email').isEmail().normalizeEmail(), body('password').notEmpty()],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

      const { email, password } = req.body;
      const userRes = await db.query('SELECT * FROM users WHERE email = $1', [email]);
      const user = userRes.rows[0];

      if (!user || !bcrypt.compareSync(password, user.password_hash)) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      const token = signToken(user.id);
      res.json({ token, user: publicUser(user) });
    } catch (err) {
      next(err);
    }
  }
);

// Forgot password
router.post(
  '/forgot-password',
  [body('email').isEmail().normalizeEmail()],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

      const { email } = req.body;
      const userRes = await db.query('SELECT * FROM users WHERE email = $1', [email]);
      const user = userRes.rows[0];

      if (!user) return res.json({ message: 'If that email exists, a reset link has been sent.' });

      const resetToken = crypto.randomBytes(32).toString('hex');
      const resetTokenHash = crypto.createHash('sha256').update(resetToken).digest('hex');
      const expires = new Date(Date.now() + 60 * 60 * 1000).toISOString();

      await db.query('DELETE FROM password_resets WHERE user_id = $1', [user.id]);
      await db.query(
        'INSERT INTO password_resets (token_hash, user_id, expires_at) VALUES ($1, $2, $3)',
        [resetTokenHash, user.id, expires]
      );

      res.json({
        message: 'If that email exists, a reset link has been sent.',
        devResetToken: process.env.NODE_ENV === 'production' ? undefined : resetToken,
      });
    } catch (err) {
      next(err);
    }
  }
);

// Reset password
router.post(
  '/reset-password',
  [body('token').notEmpty(), body('password').isLength({ min: 8 })],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

      const { token, password } = req.body;
      const tokenHash = crypto.createHash('sha256').update(token).digest('hex');

      const resetRes = await db.query('SELECT * FROM password_resets WHERE token_hash = $1', [tokenHash]);
      const row = resetRes.rows[0];

      if (!row || new Date(row.expires_at) < new Date()) {
        return res.status(400).json({ error: 'Reset token is invalid or expired' });
      }

      const passwordHash = bcrypt.hashSync(password, 10);
      await db.query(
        'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
        [passwordHash, row.user_id]
      );
      await db.query('DELETE FROM password_resets WHERE token_hash = $1', [tokenHash]);

      res.json({ message: 'Password updated successfully' });
    } catch (err) {
      next(err);
    }
  }
);

module.exports = router;