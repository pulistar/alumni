// ===== IMPORTACIONES =====
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const { Op } = require('sequelize');
const { Egresado, Documento, Evaluacion, Notificacion, PDFFinal } = require('../models');
const config = require('../config/config');
const validation = require('../middleware/validation');
const { handleError } = require('../utils/errorHandler');
const { REQUIRED_DOCUMENTS } = require('../config/constants');

const SALT_ROUNDS = 10;
const DOMINIO_PERMITIDO = '@campusucc.edu.co';

// ===== CONFIGURACIÓN DE MULTER PARA DOCUMENTOS =====
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/documentos/';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, `doc-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

const uploadDocumento = multer({ 
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Tipo de archivo no permitido. Solo se permiten PDF, JPEG y PNG'));
    }
  }
});

// ===== REGISTRO DE EGRESADO =====
const register = async (req, res) => {
  try {
    const { nombre, correo, carrera, password } = req.body;

    if (!nombre || !correo || !carrera || !password) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
    }

    if (!correo.endsWith(DOMINIO_PERMITIDO)) {
      return res.status(403).json({ message: `El correo debe terminar en ${DOMINIO_PERMITIDO}` });
    }

    const existing = await Egresado.findOne({ where: { correo } });
    if (existing) {
      return res.status(409).json({ message: 'Correo ya registrado.' });
    }

    const hashedPassword = await bcrypt.hash(password, config.security.saltRounds);

    await Egresado.create({
      nombre,
      correo,
      carrera,
      password: hashedPassword,
      habilitado: false,
      documentos_subidos: false,
      evaluacion_completada: false
    });

    res.status(201).json({ message: 'Egresado registrado correctamente.' });
  } catch (error) {
    handleError(error, res);
  }
};

// ===== LOGIN DE EGRESADO =====
const login = async (req, res) => {
  try {
    const { correo, password } = req.body;

    if (!correo || !password) {
      return res.status(400).json({ message: 'Correo y contraseña son obligatorios.' });
    }

    if (!correo.endsWith(DOMINIO_PERMITIDO)) {
      return res.status(403).json({ message: `Solo se permiten correos ${DOMINIO_PERMITIDO}` });
    }

    const egresado = await Egresado.findOne({ where: { correo } });
    if (!egresado) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }

    const match = await bcrypt.compare(password, egresado.password);
    if (!match) {
      return res.status(401).json({ message: 'Contraseña incorrecta.' });
    }

    const token = jwt.sign(
      { 
        id: egresado.id, 
        correo: egresado.correo, 
        rol: 'egresado' 
      },
      config.jwt.secret,
      {
        expiresIn: config.jwt.expiresIn,
        algorithm: config.jwt.algorithm
      }
    );

    res.json({ 
      token,
      user: {
        id: egresado.id,
        nombre: egresado.nombre,
        correo: egresado.correo,
        carrera: egresado.carrera
      }
    });
  } catch (error) {
    handleError(error, res);
  }
};

// ===== SUBIR DOCUMENTOS (múltiples URLs) =====
const subirDocumento = async (req, res) => {
  try {
    const egresadoId = req.user.id;
    const { documentos } = req.body;

    if (!documentos || !Array.isArray(documentos) || documentos.length === 0) {
      return res.status(400).json({ message: 'Se requieren los documentos.' });
    }

    // Crear todos los documentos en la base de datos
    const documentosCreados = await Promise.all(
      documentos.map(async (doc) => {
        const documento = await Documento.create({
      egresado_id: egresadoId,
          tipo: doc.tipo,
          url: doc.url,
          fecha_subida: new Date()
    });
        return documento;
      })
    );

    // Verificar si todos los documentos requeridos están subidos
    const documentosSubidos = await Documento.findAll({ 
      where: { egresado_id: egresadoId },
      attributes: ['tipo']
    });
    
    const tiposSubidos = documentosSubidos.map(d => d.tipo);
    const completos = REQUIRED_DOCUMENTS.every(doc => tiposSubidos.includes(doc));

    if (completos) {
      await Egresado.update(
        { documentos_subidos: true },
        { where: { id: egresadoId } }
      );
    }

    res.status(201).json({ 
      message: 'Documentos registrados exitosamente.',
      documentos: documentosCreados.map(doc => ({
        id: doc.id,
        tipo: doc.tipo,
        url: doc.url,
        fecha_subida: doc.fecha_subida
      }))
    });
  } catch (error) {
    console.error('Error al subir documentos:', error);
    handleError(error, res);
  }
};

// ===== LISTAR MIS DOCUMENTOS =====
const listarMisDocumentos = async (req, res) => {
  try {
    const documentos = await Documento.findAll({
      where: { egresado_id: req.user.id },
      attributes: ['id', 'tipo', 'url', 'fecha_subida'],
      order: [['fecha_subida', 'DESC']]
    });

    res.json(documentos);
  } catch (error) {
    handleError(error, res);
  }
};

// ===== ELIMINAR DOCUMENTO (solo desde base de datos) =====
const eliminarDocumento = async (req, res) => {
  try {
    const egresadoId = req.user.id;
    const { documentoId } = req.params;

    const documento = await Documento.findOne({
      where: { id: documentoId, egresado_id: egresadoId }
    });

    if (!documento) {
      return res.status(404).json({ message: 'Documento no encontrado.' });
    }

    // Nota: Si quieres eliminar también en Cloudinary, debes integrar su API aquí

    await documento.destroy();

    const documentos = await Documento.findAll({ where: { egresado_id: egresadoId } });
    const tiposSubidos = documentos.map(d => d.tipo);
    const completos = REQUIRED_DOCUMENTS.every(doc => tiposSubidos.includes(doc));

    if (!completos) {
      await Egresado.update(
        { documentos_subidos: false },
        { where: { id: egresadoId } }
      );
    }

    res.json({ message: 'Documento eliminado correctamente.' });
  } catch (error) {
    handleError(error, res);
  }
};

// ===== VER ESTADO DE PROGRESO DE DOCUMENTOS =====
const estadoProgresoDocumentos = async (req, res) => {
  try {
    const egresadoId = req.user.id;

    const documentos = await Documento.findAll({ where: { egresado_id: egresadoId } });
    const tiposSubidos = documentos.map(d => d.tipo);

    const faltantes = REQUIRED_DOCUMENTS.filter(doc => !tiposSubidos.includes(doc));

    res.json({
      totalRequeridos: REQUIRED_DOCUMENTS.length,
      subidos: tiposSubidos.length,
      completado: faltantes.length === 0,
      faltantes
    });
  } catch (error) {
    handleError(error, res);
  }
};

// ===== CONTROLADOR: CREAR O ACTUALIZAR EVALUACIÓN PROFESIONAL =====
const crearOActualizarEvaluacion = async (req, res) => {
  try {
    const egresadoId = req.user.id;
    const {
      empleo_actual,
      relacionado_carrera,
      competencias_utiles,
      sugerencias
    } = req.body;

    if (!empleo_actual || typeof relacionado_carrera !== 'boolean' || !Array.isArray(competencias_utiles)) {
      return res.status(400).json({ message: 'Datos incompletos o inválidos.' });
    }

    const [evaluacion, created] = await Evaluacion.findOrCreate({
      where: { egresado_id: egresadoId },
      defaults: {
        empleo_actual,
        relacionado_carrera,
        competencias_utiles,
        sugerencias,
        fecha: new Date()
      }
    });

    if (!created) {
      await evaluacion.update({
        empleo_actual,
        relacionado_carrera,
        competencias_utiles,
        sugerencias,
        fecha: new Date()
      });
    }

    await Egresado.update(
      { evaluacion_completada: true },
      { where: { id: egresadoId } }
    );

    res.status(200).json({
      message: created ? 'Evaluación registrada exitosamente.' : 'Evaluación actualizada.'
    });
  } catch (error) {
    handleError(error, res);
  }
};

// ===== CONTROLADOR: PERFIL COMPLETO DEL EGRESADO =====
const obtenerPerfilCompleto = async (req, res) => {
  try {
    const egresadoId = req.user.id;

    const egresado = await Egresado.findByPk(egresadoId, {
      attributes: { exclude: ['password'] },
      include: [
        {
          model: Documento,
          attributes: ['id', 'tipo', 'url']
        },
        {
          model: Evaluacion,
          attributes: ['empleo_actual', 'relacionado_carrera', 'competencias_utiles', 'sugerencias', 'fecha']
        }
      ]
    });

    if (!egresado) {
      return res.status(404).json({ message: 'Egresado no encontrado' });
    }

    res.json({ perfil: egresado });
  } catch (error) {
    handleError(error, res);
  }
};

// ===== CONTROLADOR: VER NOTIFICACIONES DE UN EGRESADO =====
const verNotificaciones = async (req, res) => {
  try {
    const egresadoId = req.user.id;

    const notificaciones = await Notificacion.findAll({
      where: {
        destinatario_id: egresadoId,
        tipo_destinatario: 'egresado'
      },
      order: [['fecha_envio', 'DESC']]
    });

    res.json({ notificaciones });
  } catch (error) {
    handleError(error, res);
  }
};

// ===== CONTROLADOR: OBTENER ESTADO DE HABILITACIÓN =====
const obtenerEstadoHabilitacion = async (req, res) => {
  try {
    const egresadoId = req.user.id;

    const egresado = await Egresado.findByPk(egresadoId, {
      attributes: ['habilitado']
    });

    if (!egresado) {
      return res.status(404).json({ message: 'Egresado no encontrado' });
    }

    res.json({ habilitado: egresado.habilitado });
  } catch (error) {
    handleError(error, res);
  }
};

// ===== EXPORTACIONES =====
module.exports = {
  register,
  login,
  subirDocumento,
  uploadDocumento,
  listarMisDocumentos,
  eliminarDocumento,
  estadoProgresoDocumentos,
  crearOActualizarEvaluacion, 
  obtenerPerfilCompleto, 
  obtenerEstadoHabilitacion,
  verNotificaciones
};


