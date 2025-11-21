require('dotenv').config();

const requiredEnvVars = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD'];

// Solo validar variables de entorno en producción
if (process.env.NODE_ENV === 'production') {
  requiredEnvVars.forEach(envVar => {
    if (!process.env[envVar]) {
      throw new Error(`La variable de entorno ${envVar} es obligatoria.`);
    }
  });
}

module.exports = {
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 3000,
  
  // Configuración de base de datos
  db: {
    host: process.env.DB_HOST || 'gondola.proxy.rlwy.net',
    port: process.env.DB_PORT || 34602,
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'UYTSBXKaiydOdcHNgnZWCKeqAyyngTGO',
    database: process.env.DB_NAME || 'railway',
    dialect: 'postgres',
    logging: process.env.NODE_ENV === 'development',
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false
      }
    }
  },

  // Configuración de JWT
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',
    expiresIn: '24h',
    algorithm: 'HS256'
  },

  // Configuración de archivos
  upload: {
    maxFileSize: 5 * 1024 * 1024, // 5MB
    allowedTypes: ['application/pdf', 'image/jpeg', 'image/png'],
    uploadDir: 'uploads/'
  },

  // Configuración de seguridad
  security: {
    saltRounds: 10,
    allowedEmailDomain: '@campusucc.edu.co',
    passwordMinLength: 8
  },

  // Configuración de CSRF
  csrf: {
    secret: process.env.CSRF_SECRET || 'test_csrf_secret'
  },

  // Lista de carreras disponibles
  carreras: [
    'Ingeniería de Sistemas',
    'Ingeniería Civil',
    'Ingeniería Industrial',
    'Ingeniería Electrónica',
    'Ingeniería Mecánica',
    'Medicina',
    'Odontología',
    'Arquitectura'
  ],

  //comentarios finales 
  

  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    credentials: true
  }
}; 