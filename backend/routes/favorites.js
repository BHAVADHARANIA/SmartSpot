const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, validationResult } = require('express-validator');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

router.get('/', (req, res) => {
  const { updatedSince } = req.query;
  let query = 'SELECT * FROM favorite_locations WHERE user_id = ? AND deleted_at IS NULL';
  const params = [req.userId];
  if (updatedSince) {
    query += ' AND updated_at > ?';
    params.push(updatedSince);
  }
  const rows = db.prepare(query).all(...params);
  res.json({ favorites: rows });
});

router.post(
  '/',
  [body('label').notEmpty().trim(), body('latitude').isFloat(), body('longitude').isFloat()],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

    const { label, latitude, longitude, address } = req.body;
    const id = uuidv4();

    db.prepare(
      'INSERT INTO favorite_locations (id, user_id, label, latitude, longitude, address) VALUES (?, ?, ?, ?, ?, ?)'
    ).run(id, req.userId, label, latitude, longitude, address || null);

    const favorite = db.prepare('SELECT * FROM favorite_locations WHERE id = ?').get(id);
    res.status(201).json({ favorite });
  }
);

router.delete('/:id', (req, res) => {
  const result = db
    .prepare("UPDATE favorite_locations SET deleted_at = datetime('now') WHERE id = ? AND user_id = ?")
    .run(req.params.id, req.userId);

  if (result.changes === 0) return res.status(404).json({ error: 'Favorite not found' });
  res.status(204).send();
});

module.exports = router;
