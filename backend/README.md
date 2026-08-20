# SmartSpot Backend API

Node.js + Express + SQLite REST API for the SmartSpot app: user accounts (JWT auth),
reminders, and favorite locations, with sync support for the offline-first Flutter app.

## Run locally

```bash
npm install
npm start        # or: node server.js
```

Server starts on `http://localhost:3000` (or `PORT` from `.env`).

A `.env` file is already included with a generated `JWT_SECRET` for local dev.
**Generate a new secret before deploying to production:**

```bash
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```

## Endpoints

| Method | Path                        | Auth | Description               |
|--------|-----------------------------|------|----------------------------|
| GET    | /health                     | No   | Health check               |
| POST   | /api/auth/register          | No   | Create account             |
| POST   | /api/auth/login             | No   | Login, returns JWT         |
| POST   | /api/auth/forgot-password   | No   | Request password reset     |
| POST   | /api/auth/reset-password    | No   | Reset password with token  |
| GET    | /api/reminders               | Yes  | List reminders (`?status=`, `?updatedSince=`) |
| POST   | /api/reminders               | Yes  | Create reminder            |
| PUT    | /api/reminders/:id           | Yes  | Update reminder            |
| DELETE | /api/reminders/:id           | Yes  | Soft-delete reminder       |
| GET    | /api/favorites                | Yes  | List favorite locations    |
| POST   | /api/favorites                | Yes  | Create favorite location   |
| DELETE | /api/favorites/:id            | Yes  | Soft-delete favorite       |

Authenticated requests need: `Authorization: Bearer <token>`

## Before going to production

1. **Email delivery for password reset.** `forgot-password` currently generates a
   reset token but does not send it anywhere. Wire it to SendGrid, AWS SES, Postmark,
   or similar, and remove the `devResetToken` field from the response.
2. **Move off local SQLite file storage** if you expect concurrent write load beyond a
   small/medium app — Postgres (Railway, Render, Supabase, Neon) is a drop-in swap
   using the same query shapes; only `db/index.js` needs to change.
3. **Rate limiting** on `/api/auth/*` (e.g. `express-rate-limit`) to slow down credential
   stuffing / brute force attempts.
4. **HTTPS only** — deploy behind a platform that terminates TLS (Render, Railway, Fly.io
   all do this for you).
5. **Restrict CORS** in `server.js` to your actual app's origin if you also ship a web client.
6. **Backups** — schedule regular backups of the SQLite file (or your Postgres DB).

## Deploying

Any Node host works (Railway, Render, Fly.io, a VPS). Typical steps:
1. Push this folder to a git repo.
2. Set environment variables `JWT_SECRET`, `PORT` (most platforms set `PORT` automatically).
3. Set the start command to `node server.js`.
4. Point your Flutter app's `apiBaseUrl` at the deployed URL (see frontend README).
