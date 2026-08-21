const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { body, validationResult } = require('express-validator');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();
router.use(requireAuth);

router.get('/', async (req, res, next) => {
  try {
    const { updatedSince } = req.query;
    let query = 'SELECT * FROM favorite_locations WHERE user_id = $1 AND deleted_at IS NULL';
    const params = [req.userId];
    let paramIndex = 2;

    if (updatedSince) {
      query += ` AND updated_at > $${paramIndex++}`;
      params.push(updatedSince);
    }

    const result = await db.query(query, params);
    res.json({ favorites: result.rows });
  } catch (err) {
    next(err);
  }
});

router.post(
  '/',
  [body('label').notEmpty().trim(), body('latitude').isFloat(), body('longitude').isFloat()],
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) return res.status(400).json({ error: errors.array()[0].msg });

      const { label, latitude, longitude, address } = req.body;
      const id = uuidv4();

      await db.query(
        'INSERT INTO favorite_locations (id, user_id, label, latitude, longitude, address) VALUES ($1, $2, $3, $4, $5, $6)',
        [id, req.userId, label, latitude, longitude, address || null]
      );

      const result = await db.query('SELECT * FROM favorite_locations WHERE id = $1', [id]);
      res.status(201).json({ favorite: result.rows[0] });
    } catch (err) {
      next(err);
    }
  }
);

router.delete('/:id', async (req, res, next) => {
  try {
    const result = await db.query(
      'UPDATE favorite_locations SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1 AND user_id = $2',
      [req.params.id, req.userId]
    );

    if (result.rowCount === 0) return res.status(404).json({ error: 'Favorite not found' });
    res.status(204).send();
  } catch (err) {
    next(err);
  }
});

module.exports = router;