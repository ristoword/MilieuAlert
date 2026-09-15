require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');

const { runMigrations } = require('./db/migrate');
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const aiRoutes = require('./routes/ai');
const tripRoutes = require('./routes/trips');
const zoneRoutes = require('./routes/zones');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false,
}));
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// Serve Flutter web app static files
const webBuildPath = path.join(__dirname, '..', 'public');
app.use(express.static(webBuildPath));

app.get('/api/status', (req, res) => {
  res.json({
    name: 'MilieuAlert API',
    version: '1.0.0',
    status: 'running',
    endpoints: [
      'POST /api/auth/register',
      'POST /api/auth/login',
      'GET /api/users/profile',
      'PUT /api/users/profile',
      'POST /api/ai/chat',
      'POST /api/ai/zone-check',
      'POST /api/trips/log',
      'GET /api/trips/history',
      'GET /api/zones/sync',
    ],
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/api/db-check', async (req, res) => {
  const dbVars = Object.keys(process.env).filter(k => 
    k.includes('DATABASE') || k.includes('POSTGRES') || k.includes('PG') || k.includes('DB_')
  );
  try {
    const pool = require('./db/pool');
    const result = await pool.query('SELECT NOW() as time');
    res.json({ status: 'connected', time: result.rows[0].time, db_vars: dbVars });
  } catch (err) {
    const errInfo = {
      message: String(err.message || err),
      code: err.code,
      errors: err.errors ? err.errors.map(e => ({ message: e.message, code: e.code })) : undefined,
    };
    res.status(500).json({ status: 'error', ...errInfo, db_vars: dbVars, db_url_prefix: (process.env.DATABASE_URL || '').substring(0, 30) });
  }
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/zones', zoneRoutes);

// SPA fallback - serve index.html for non-API routes
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/api/')) return next();
  res.sendFile(path.join(webBuildPath, 'index.html'));
});

app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, '0.0.0.0', async () => {
  console.log(`MilieuAlert API running on port ${PORT}`);
  await runMigrations();
});
