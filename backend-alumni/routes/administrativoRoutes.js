const express = require('express');
const router = express.Router();
const {
  upload,
  habilitarEgresadosDesdeExcel,
  loginAdmin,
  listarEgresados,
  listarCarrerasConPDFs,
  listarPDFsPorCarrera,
  listarEgresadosConEvaluacion,
  verEvaluacionPorEgresado,
  enviarNotificacionesMasivas,
  generarPDFUnificado
} = require('../controllers/administrativoController');

const authenticateToken = require('../middleware/auth');
const checkRole = require('../middleware/roleCheck');
const csrfProtection = require('../middleware/csrf');
const { loginLimiter } = require('../middleware/rateLimiter');

// Login administrativo (ruta pública)
router.post('/login', loginLimiter, csrfProtection, loginAdmin);

// Rutas protegidas
router.use(authenticateToken);

// Rutas que requieren rol de administrador
router.get('/egresados', csrfProtection, checkRole(['admin', 'coordinador']), listarEgresados);

// Ruta protegida para subir Excel y habilitar egresados
router.post(
  '/habilitar-egresados',
  csrfProtection,
  checkRole(['admin']),
  upload.single('archivo'),
  habilitarEgresadosDesdeExcel
);

// Ruta protegida para listar carreras con PDFs unificados
router.get(
  '/carreras-pdfs',
  csrfProtection,
  checkRole(['admin']),
  listarCarrerasConPDFs
);

// Ruta protegida para listar PDFs unificados por carrera
router.get(
  '/pdfs/:carrera',
  csrfProtection,
  checkRole(['admin']),
  listarPDFsPorCarrera
);

// Ruta protegida para listar egresados con evaluación
router.get(
  '/evaluaciones',
  csrfProtection,
  checkRole(['admin']),
  listarEgresadosConEvaluacion
);

router.get(
  '/evaluacion/:egresadoId',
  csrfProtection,
  checkRole(['admin']),
  verEvaluacionPorEgresado
);

router.post(
  '/notificaciones-masivas',
  csrfProtection,
  checkRole(['admin']),
  enviarNotificacionesMasivas
);

router.post(
  '/pdf-unificado/:egresadoId',
  csrfProtection,
  checkRole(['admin']),
  generarPDFUnificado
);

module.exports = router;
