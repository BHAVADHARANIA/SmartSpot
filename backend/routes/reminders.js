const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, validationResult } = require('express-validator');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

// List reminders
router.get('/', async (req, res, next) => {
  try {
    const { status, updatedSince } = req.query;
    let query = 'SELECT * FROM reminders WHERE user_id = $1 AND deleted_at IS NULL';
    const params = [req.userId];
    let paramIndex = 2;

    if (status) {
      query += ` AND status = $${paramIndex++}`;
      params.push(status);
    }
    if (updatedSince) {
      query += ` AND updated_at > $${paramIndex++}`;
      params.push(updatedSince);
    }
    query += ' ORDER BY updated_at DESC';

    const result = await db.query(query, params);
    res.json({ reminders: result.rows });
  } catch (err) {
    next(err);
  }
});

// Create reminder
router.post(
  '/',
  [body('title').notEmpty().trim()],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

      const {
        title, notes, latitude, longitude, radiusMeters,
        category, conditionType, scheduledAt,
      } = req.body;

      const id = uuidv4();
      await db.query(
        `INSERT INTO reminders
          (id, user_id, title, notes, latitude, longitude, radius_meters, category, condition_type, scheduled_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [
          id, req.userId, title, notes || null, latitude ?? null, longitude ?? null,
          radiusMeters ?? 100, category || null, conditionType || 'arrive', scheduledAt || null,
        ]
      );

      const result = await db.query('SELECT * FROM reminders WHERE id = $1', [id]);
      res.status(201).json({ reminder: result.rows[0] });
    } catch (err) {
      next(err);
    }
  }
);

// Update reminder
router.put('/:id', async (req, res, next) => {
  try {
    const existing = await db.query('SELECT id FROM reminders WHERE id = $1 AND user_id = $2', [
      req.params.id,
      req.userId,
    ]);

    if (existing.rows.length === 0) return res.status(404).json({ error: 'Reminder not found' });

    const bodyKeyMap = {
      title: 'title', notes: 'notes', latitude: 'latitude', longitude: 'longitude',
      radiusMeters: 'radius_meters', category: 'category', conditionType: 'condition_type',
      scheduledAt: 'scheduled_at', status: 'status', isFavorite: 'is_favorite',
    };

    const updates = [];
    const params = [];
    let paramIndex = 1;

    for (const [bodyKey, column] of Object.entries(bodyKeyMap)) {
      if (req.body[bodyKey] !== undefined) {
        updates.push(`${column} = $${paramIndex++}`);
        params.push(req.body[bodyKey]);
      }
    }
    if (updates.length === 0) return res.status(400).json({ error: 'No fields to update' });

    updates.push('updated_at = NOW()');
    params.push(req.params.id, req.userId);

    await db.query(
      `UPDATE reminders SET ${updates.join(', ')} WHERE id = $${paramIndex++} AND user_id = $${paramIndex++}`,
      params
    );

    const result = await db.query('SELECT * FROM reminders WHERE id = $1', [req.params.id]);
    res.json({ reminder: result.rows[0] });
  } catch (err) {
    next(err);
  }
});

// Delete reminder
router.delete('/:id', async (req, res, next) => {
  try {
    const result = await db.query(
      'UPDATE reminders SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1 AND user_id = $2',
      [req.params.id, req.userId]
    );

    if (result.rowCount === 0) return res.status(404).json({ error: 'Reminder not found' });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
});

module.exports = router;