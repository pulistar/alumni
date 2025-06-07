require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { sequelize, testConnection } = require('./models');
const config = require('./config/config');
const { handleMulterError } = require('./middleware/fileUpload');
const { loginLimiter, generalLimiter, helmetConfig } = require('./middleware/security');
const { loggingMiddleware, logError } = require('./utils/logger');

const egresadoRoutes = require('./routes/egresadoRoutes');
const administrativoRoutes = require('./routes/administrativoRoutes');

const app = express();

// Configuración de seguridad
app.use(helmetConfig);

// Configurar Express para confiar en el proxy (necesario para ngrok)
app.set('trust proxy', 1);

// Configuración de CORS
app.use(cors({
  origin: config.cors.origin,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: config.cors.credentials
}));

// Middleware para parsear JSON con límite más seguro
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Middleware de logging
app.use(loggingMiddleware);

// Rate limiting general
app.use(generalLimiter);

// Middleware para manejar errores de multer
app.use(handleMulterError);

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({
    message: 'Backend Alumni funcionando',
    version: '1.0.0',
    environment: config.env
  });
});

// Rutas para egresados con rate limiting específico para login
app.use('/api/egresados/login', loginLimiter);
app.use('/api/egresados', egresadoRoutes);

// Rutas para administrativos con rate limiting específico para login
app.use('/api/administrativos/login', loginLimiter);
app.use('/api/administrativos', administrativoRoutes);

// Middleware de manejo de errores global
app.use((err, req, res, next) => {
  logError(err, req);
  
  const statusCode = err.status || 500;
  const errorResponse = {
    message: err.message || 'Error interno del servidor',
    ...(config.env === 'development' && {
      error: err.message,
      stack: err.stack
    })
  };

  res.status(statusCode).json(errorResponse);
});

// Manejo de errores no capturados
process.on('uncaughtException', (error) => {
  logError(error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logError(new Error(`Unhandled Rejection at: ${promise}, reason: ${reason}`));
});

// Conexión y sincronización con la base de datos
const startServer = async () => {
  try {
    const isConnected = await testConnection();
    if (!isConnected) {
      throw new Error('No se pudo conectar a la base de datos');
    }

    const syncOptions = config.env === 'test' ? { force: true } : { alter: true };
    await sequelize.sync(syncOptions);
    console.log('✅ Tablas sincronizadas con Sequelize');

    const port = config.port;
    app.listen(port, () => {
      console.log(`🚀 Servidor corriendo en http://localhost:${port}`);
    });
  } catch (err) {
    console.error('❌ Error iniciando el servidor:', err);
    process.exit(1);
  }
};

// Iniciar el servidor solo si no estamos en entorno de test
if (process.env.NODE_ENV !== 'test') {
  startServer();
}

module.exports = app;
