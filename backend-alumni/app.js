const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const egresadoRoutes = require('./routes/egresadoRoutes');
const administrativoRoutes = require('./routes/administrativoRoutes');

const app = express();

// Configuración de proxy
app.set('trust proxy', 'loopback');

// Configuración de CORS
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));

// Configuración de rate limit - Deshabilitado temporalmente
/*
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // límite de 100 peticiones por ventana
  standardHeaders: true,
  legacyHeaders: false,
  trustProxy: true,
  keyGenerator: (req) => {
    return req.headers['x-forwarded-for'] || req.ip;
  }
});

app.use(limiter);
*/

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(helmet());
app.use(compression());
app.use(morgan('dev'));

// Rutas
app.use('/api/egresados', egresadoRoutes);
app.use('/api/administrativos', administrativoRoutes);

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Error interno del servidor' });
});

module.exports = app; 