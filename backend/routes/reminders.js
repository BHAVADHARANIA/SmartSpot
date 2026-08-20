const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, validationResult } = require('express-validator');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

// ---------- List reminders (with optional status filter + sync support) ----------
router.get('/', (req, res) => {
  const { status, updatedSince } = req.query;
  let query = 'SELECT * FROM reminders WHERE user_id = ? AND deleted_at IS NULL';
  const params = [req.userId];

  if (status) {
    query += ' AND status = ?';
    params.push(status);
  }
  if (updatedSince) {
    query += ' AND updated_at > ?';
    params.push(updatedSince);
  }
  query += ' ORDER BY updated_at DESC';

  const rows = db.prepare(query).all(...params);
  res.json({ reminders: rows });
});

// ---------- Create ----------
router.post(
  '/',
  [body('title').notEmpty().trim()],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

    const {
      title, notes, latitude, longitude, radiusMeters,
      category, conditionType, scheduledAt,
    } = req.body;

    const id = uuidv4();
    db.prepare(
      `INSERT INTO reminders
        (id, user_id, title, notes, latitude, longitude, radius_meters, category, condition_type, scheduled_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    ).run(
      id, req.userId, title, notes || null, latitude ?? null, longitude ?? null,
      radiusMeters ?? 100, category || null, conditionType || 'arrive', scheduledAt || null
    );

    const reminder = db.prepare('SELECT * FROM reminders WHERE id = ?').get(id);
    res.status(201).json({ reminder });
  }
);

// ---------- Update ----------
router.put('/:id', (req, res) => {
  const existing = db
    .prepare('SELECT * FROM reminders WHERE id = ? AND user_id = ?')
    .get(req.params.id, req.userId);

  if (!existing) return res.status(404).json({ error: 'Reminder not found' });

  const fields = ['title', 'notes', 'latitude', 'longitude', 'radius_meters', 'category',
    'condition_type', 'scheduled_at', 'status', 'is_favorite'];
  const bodyKeyMap = {
    title: 'title', notes: 'notes', latitude: 'latitude', longitude: 'longitude',
    radiusMeters: 'radius_meters', category: 'category', conditionType: 'condition_type',
    scheduledAt: 'scheduled_at', status: 'status', isFavorite: 'is_favorite',
  };

  const updates = [];
  const params = [];
  for (const [bodyKey, column] of Object.entries(bodyKeyMap)) {
    if (req.body[bodyKey] !== undefined) {
      updates.push(`${column} = ?`);
      params.push(req.body[bodyKey]);
    }
  }
  if (updates.length === 0) return res.status(400).json({ error: 'No fields to update' });

  updates.push("updated_at = datetime('now')");
  params.push(req.params.id, req.userId);

  db.prepare(`UPDATE reminders SET ${updates.join(', ')} WHERE id = ? AND user_id = ?`).run(...params);
  const reminder = db.prepare('SELECT * FROM reminders WHERE id = ?').get(req.params.id);
  res.json({ reminder });
});

// ---------- Soft delete ----------
router.delete('/:id', (req, res) => {
  const result = db
    .prepare("UPDATE reminders SET deleted_at = datetime('now'), updated_at = datetime('now') WHERE id = ? AND user_id = ?")
    .run(req.params.id, req.userId);

  if (result.changes === 0) return res.status(404).json({ error: 'Reminder not found' });
  res.status(204).send();
});

module.exports = router;
