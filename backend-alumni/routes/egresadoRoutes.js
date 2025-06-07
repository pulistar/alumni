const express = require('express');
const router = express.Router();
const {
  register,
  login,
  subirDocumento,
  listarMisDocumentos,
  eliminarDocumento,
  estadoProgresoDocumentos,
  crearOActualizarEvaluacion, 
  obtenerPerfilCompleto,
  verNotificaciones,
} = require('../controllers/egresadoController');

const authenticateToken = require('../middleware/auth');
const { Egresado } = require('../models');

// Registro (público)
router.post('/register', register);

// Login (público)
router.post('/login', login);

// Ruta protegida: obtener perfil del egresado
router.get('/perfil', authenticateToken, async (req, res) => {
  try {
    const egresado = await Egresado.findByPk(req.user.id, {
      attributes: { exclude: ['password'] }
    });

    if (!egresado) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    res.json(egresado);
  } catch (error) {
    console.error('Error al obtener perfil:', error);
    res.status(500).json({ message: 'Error del servidor' });
  }
});

// Subir documento (solo URL)
router.post(
  '/documentos',
  authenticateToken,
  subirDocumento
);

// Listar mis documentos
router.get(
  '/documentos',
  authenticateToken,
  listarMisDocumentos
);

// Eliminar documento por ID
router.delete(
  '/documentos/:documentoId',
  authenticateToken,
  eliminarDocumento
);

// Ver estado del progreso de carga de documentos
router.get(
  '/documentos/progreso',
  authenticateToken,
  estadoProgresoDocumentos
);

// Evaluación profesional (POST o PUT en una sola ruta)
router.post(
  '/evaluacion',
  authenticateToken,
  crearOActualizarEvaluacion
);

 // perfil completo
router.get(
  '/perfil-completo',
  authenticateToken,
  obtenerPerfilCompleto
);

// Ver notificaciones del egresado
router.get(
  '/notificaciones',
  authenticateToken,
  verNotificaciones
);

module.exports = router;
