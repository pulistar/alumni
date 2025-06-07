const winston = require('winston');
const path = require('path');
const config = require('../config/config');

// Definir niveles de log
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Definir colores para cada nivel
const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'white',
};

// Agregar colores a winston
winston.addColors(colors);

// Formato personalizado para los logs
const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`,
  ),
);

// Configurar los transportes según el entorno
const transports = [
  // Consola
  new winston.transports.Console(),
  // Archivo de errores
  new winston.transports.File({
    filename: path.join('logs', 'error.log'),
    level: 'error',
    maxsize: 5242880, // 5MB
    maxFiles: 5,
  }),
  // Archivo de todos los logs
  new winston.transports.File({
    filename: path.join('logs', 'all.log'),
    maxsize: 5242880, // 5MB
    maxFiles: 5,
  }),
];

// Crear el logger
const logger = winston.createLogger({
  level: config.env === 'development' ? 'debug' : 'info',
  levels,
  format,
  transports,
});

// Middleware de logging para Express
const loggingMiddleware = (req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.http(`${req.method} ${req.originalUrl} ${res.statusCode} ${duration}ms`);
  });
  next();
};

// Función para loggear errores
const logError = (error, req = null) => {
  const errorInfo = {
    message: error.message,
    stack: error.stack,
    ...(req && {
      method: req.method,
      url: req.originalUrl,
      body: req.body,
      params: req.params,
      query: req.query,
      headers: req.headers,
    }),
  };

  logger.error(JSON.stringify(errorInfo, null, 2));
};

module.exports = {
  logger,
  loggingMiddleware,
  logError,
}; 