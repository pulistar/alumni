const multer = require('multer');
const path = require('path');
const fs = require('fs');
const config = require('../config/config');

// Asegurar que el directorio de uploads existe
if (!fs.existsSync(config.upload.uploadDir)) {
  fs.mkdirSync(config.upload.uploadDir, { recursive: true });
}

// Función para validar el tipo MIME
const fileFilter = (req, file, cb) => {
  if (!config.upload.allowedTypes.includes(file.mimetype)) {
    cb(new Error('Tipo de archivo no permitido'), false);
    return;
  }
  cb(null, true);
};

// Configuración de almacenamiento
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, config.upload.uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// Configuración de multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: config.upload.maxFileSize,
    files: 1
  }
});

// Middleware para manejar errores de multer
const handleMulterError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        message: `El archivo excede el tamaño máximo permitido de ${config.upload.maxFileSize / (1024 * 1024)}MB`
      });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        message: 'Solo se permite subir un archivo a la vez'
      });
    }
    return res.status(400).json({
      message: 'Error al subir el archivo'
    });
  }
  if (err) {
    return res.status(400).json({
      message: err.message
    });
  }
  next();
};

// Servicio de limpieza de archivos
const cleanupService = {
  async cleanupOldFiles() {
    try {
      const files = await fs.promises.readdir(config.upload.uploadDir);
      const now = Date.now();
      
      for (const file of files) {
        const filePath = path.join(config.upload.uploadDir, file);
        const stats = await fs.promises.stat(filePath);
        
        // Eliminar archivos más antiguos de 24 horas
        if (now - stats.mtime.getTime() > 24 * 60 * 60 * 1000) {
          await fs.promises.unlink(filePath);
        }
      }
    } catch (error) {
      console.error('Error en limpieza de archivos:', error);
    }
  }
};

// Programar limpieza diaria
setInterval(cleanupService.cleanupOldFiles, 24 * 60 * 60 * 1000);

module.exports = {
  upload,
  handleMulterError
}; 