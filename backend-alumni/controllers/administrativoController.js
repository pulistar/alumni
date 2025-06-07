// Importaciones necesarias
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { Administrativo, Egresado, PDFFinal, Evaluacion, Documento, Notificacion } = require('../models');
const multer = require('multer');
const XLSX = require('xlsx');
const path = require('path');
const fs = require('fs');
const { PDFDocument } = require('pdf-lib');
const config = require('../config/config');

const { Op } = require('sequelize');

// ===== CONFIGURACIÓN DE MULTER PARA SUBIDA DE ARCHIVOS =====
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    cb(null, `archivo-${Date.now()}${path.extname(file.originalname)}`);
  }
});

const upload = multer({ 
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['application/pdf', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Tipo de archivo no permitido'));
    }
  }
});

// ===== CONTROLADOR LOGIN ADMINISTRATIVO =====
const loginAdmin = async (req, res) => {
  try {
    const { correo, password } = req.body;
    if (!correo || !password) {
      return res.status(400).json({ message: 'Correo y contraseña obligatorios.' });
    }
    const admin = await Administrativo.findOne({ where: { correo } });
    if (!admin) {
      return res.status(404).json({ message: 'Administrador no encontrado.' });
    }
    const valid = await bcrypt.compare(password, admin.hashed_password);
    if (!valid) {
      return res.status(401).json({ message: 'Contraseña incorrecta.' });
    }
    const token = jwt.sign(
      { id: admin.id, correo: admin.correo, rol: admin.rol },
      config.jwt.secret,
      { expiresIn: '12h' }
    );
    res.json({ token });
  } catch (error) {
    console.error('Login Admin Error:', error);
    res.status(500).json({ message: 'Error del servidor' });
  }
};

// ===== CONTROLADOR PARA HABILITAR EGRESADOS DESDE EXCEL =====
const habilitarEgresadosDesdeExcel = async (req, res) => {
  try {
    const archivo = req.file;
    if (!archivo) {
      return res.status(400).json({ message: 'No se subió archivo.' });
    }
    const workbook = XLSX.readFile(archivo.path);
    const sheet = workbook.Sheets[workbook.SheetNames[0]];
    const data = XLSX.utils.sheet_to_json(sheet);
    const noEncontrados = [];
    for (const fila of data) {
      if (!fila.correo) continue;
      const egresado = await Egresado.findOne({ where: { correo: fila.correo } });
      if (egresado) {
        egresado.habilitado = true;
        await egresado.save();
      } else {
        noEncontrados.push(fila.correo);
      }
    }
    fs.unlinkSync(archivo.path);
    res.json({ message: 'Proceso finalizado', noEncontrados });
  } catch (error) {
    console.error('Error en habilitarEgresadosDesdeExcel:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// ===== CONTROLADOR PARA LISTAR A EGRESADOS =====
const listarEgresados = async (req, res) => {
  try {
    let { nombre, carrera, habilitado, page = 1, limit = 10 } = req.query;
    const where = {};
    if (nombre) {
      nombre = nombre.trim();
      where.nombre = { [Op.iLike]: `%${nombre}%` };
    }
    if (carrera) {
      carrera = carrera.trim();
      where.carrera = { [Op.iLike]: `%${carrera}%` };
    }
    if (habilitado === 'true' || habilitado === 'false') {
      where.habilitado = habilitado === 'true';
    }
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const { count, rows } = await Egresado.findAndCountAll({
      where,
      offset,
      limit: parseInt(limit),
      order: [['fecha_registro', 'DESC']]
    });
    res.json({
      total: count,
      paginaActual: parseInt(page),
      totalPaginas: Math.ceil(count / limit),
      egresados: rows
    });
  } catch (error) {
    console.error('Error al listar egresados:', error);
    res.status(500).json({ message: 'Error al obtener egresados' });
  }
};

// ===== CONTROLADOR PARA LISTAR CARRERAS CON PDFs UNIFICADOS =====
const listarCarrerasConPDFs = async (req, res) => {
  try {
    const carreras = await Egresado.findAll({
      attributes: ['carrera'],
      include: [{
        model: PDFFinal,
        required: true
      }],
      group: ['Egresado.carrera']
    });
    res.json(carreras.map(c => c.carrera));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error al obtener carreras con PDFs' });
  }
};

// ===== CONTROLADOR PARA LISTAR PDFs POR CARRERA =====
const listarPDFsPorCarrera = async (req, res) => {
  try {
    let { carrera } = req.params;
    carrera = carrera.trim();

    const egresados = await Egresado.findAll({
      where: {
        carrera: {
          [Op.iLike]: `%${carrera}%`
        }
      },
      include: [{
        model: PDFFinal,
        required: true
      }],
      attributes: ['id', 'nombre', 'correo']
    });
    res.json(egresados);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error al listar PDFs por carrera' });
  }
};

// ===== CONTROLADOR PARA VER RESPUESTAS DE LA EVALUACIÓN PROFESIONAL =====
const listarEgresadosConEvaluacion = async (req, res) => {
  try {
    const egresados = await Egresado.findAll({
      include: [{
        model: Evaluacion,
        required: true,
        attributes: ['id', 'empleo_actual', 'relacionado_carrera', 'competencias_utiles', 'sugerencias', 'fecha']
      }],
      attributes: ['id', 'nombre', 'correo', 'carrera'],
      order: [['nombre', 'ASC']]
    });

    console.log('Egresados encontrados:', egresados.length); // Debug

    const evaluaciones = egresados.map(egresado => {
      console.log('Procesando egresado:', egresado.nombre); // Debug
      console.log('Evaluación:', egresado.Evaluacion); // Debug
      return {
        id: egresado.id,
        nombre: egresado.nombre,
        correo: egresado.correo,
        carrera: egresado.carrera,
        evaluacion: {
          id: egresado.Evaluacion.id,
          empleo_actual: egresado.Evaluacion.empleo_actual,
          relacionado_carrera: egresado.Evaluacion.relacionado_carrera,
          competencias_utiles: egresado.Evaluacion.competencias_utiles,
          sugerencias: egresado.Evaluacion.sugerencias,
          fecha: egresado.Evaluacion.fecha
        }
      };
    });

    console.log('Evaluaciones procesadas:', evaluaciones.length); // Debug
    res.json(evaluaciones);
  } catch (error) {
    console.error('Error al listar egresados con evaluación:', error);
    res.status(500).json({ message: 'Error al obtener evaluaciones' });
  }
};

// ===== CONTROLADOR PARA VER EVALUACIÓN DE UN EGRESADO POR ID =====
const verEvaluacionPorEgresado = async (req, res) => {
  try {
    const { egresadoId } = req.params;
    const evaluacion = await Evaluacion.findOne({
      where: { egresado_id: egresadoId },
      include: [{
        model: Egresado,
        attributes: ['nombre', 'correo', 'carrera']
      }]
    });
    if (!evaluacion) {
      return res.status(404).json({ message: 'Evaluación no encontrada para este egresado.' });
    }
    res.json({ evaluacion });
  } catch (error) {
    console.error('Error al obtener evaluación:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// ===== CONTROLADOR PARA ENVIAR NOTIFICACIONES MASIVAS =====
const enviarNotificacionesMasivas = async (req, res) => {
  try {
    const { titulo, mensaje, tipo_notificacion } = req.body;
    if (!titulo || !mensaje || !tipo_notificacion) {
      return res.status(400).json({ message: 'Faltan campos obligatorios' });
    }

    let destinatarios = [];
    
    // Filtrar egresados según el tipo de notificación
    if (tipo_notificacion === 'documentos_pendientes') {
      destinatarios = await Egresado.findAll({
        where: {
          documentos_subidos: false
        }
      });
    } else if (tipo_notificacion === 'evaluacion_pendiente') {
      destinatarios = await Egresado.findAll({
        where: {
          evaluacion_completada: false
        }
      });
    } else if (tipo_notificacion === 'proceso_incompleto') {
      destinatarios = await Egresado.findAll({
        where: {
          [Op.or]: [
            { documentos_subidos: false },
            { evaluacion_completada: false }
          ]
        }
      });
    }

    if (destinatarios.length === 0) {
      return res.json({ 
        message: 'No hay egresados pendientes para notificar',
        destinatarios: 0
      });
    }

    const notificaciones = destinatarios.map(destinatario => ({
      titulo,
      mensaje,
      tipo_destinatario: 'egresado',
      destinatario_id: destinatario.id,
      leida: false,
      fecha_envio: new Date()
    }));

    await Notificacion.bulkCreate(notificaciones);
    
    res.json({ 
      message: 'Notificaciones enviadas correctamente',
      destinatarios: destinatarios.length
    });
  } catch (error) {
    console.error('Error al enviar notificaciones:', error);
    res.status(500).json({ message: 'Error al enviar notificaciones' });
  }
};

// ===== CONTROLADOR PARA GENERAR PDF UNIFICADO =====
const generarPDFUnificado = async (req, res) => {
  let outputPath = null;
  try {
    const { egresadoId } = req.params;
    
    // Validar que el ID sea un número válido
    if (!egresadoId || isNaN(egresadoId)) {
      return res.status(400).json({ 
        success: false,
        message: 'ID de egresado inválido' 
      });
    }

    // Buscar el egresado con sus documentos
    const egresado = await Egresado.findByPk(egresadoId, {
      include: [{
        model: Documento,
        required: true,
        where: {
          estado: 'activo' // Solo documentos activos
        }
      }]
    });

    if (!egresado) {
      return res.status(404).json({ 
        success: false,
        message: 'Egresado no encontrado' 
      });
    }

    if (!egresado.Documentos || egresado.Documentos.length === 0) {
      return res.status(404).json({ 
        success: false,
        message: 'El egresado no tiene documentos para unificar' 
      });
    }

    // Crear el PDF unificado
    const pdfDoc = await PDFDocument.create();
    
    // Procesar cada documento
    for (const documento of egresado.Documentos) {
      try {
        // Verificar que el archivo existe
        if (!fs.existsSync(documento.ruta)) {
          console.warn(`Documento no encontrado: ${documento.ruta}`);
          continue;
        }

        const pdfBytes = fs.readFileSync(documento.ruta);
        const pdf = await PDFDocument.load(pdfBytes);
        const pages = await pdfDoc.copyPages(pdf, pdf.getPageIndices());
        pages.forEach(page => pdfDoc.addPage(page));
      } catch (error) {
        console.error(`Error al procesar documento ${documento.id}:`, error);
        // Continuar con el siguiente documento
        continue;
      }
    }

    // Verificar si se agregaron páginas
    if (pdfDoc.getPageCount() === 0) {
      return res.status(400).json({ 
        success: false,
        message: 'No se pudieron procesar los documentos' 
      });
    }

    // Guardar el PDF unificado
    const pdfBytes = await pdfDoc.save();
    outputPath = `uploads/pdf-unificado-${egresadoId}-${Date.now()}.pdf`;
    fs.writeFileSync(outputPath, pdfBytes);

    // Crear registro en la base de datos
    const pdfFinal = await PDFFinal.create({
      egresado_id: egresadoId,
      ruta: outputPath,
      fecha_generacion: new Date(),
      estado: 'activo'
    });

    // Enviar respuesta exitosa
    res.json({ 
      success: true,
      message: 'PDF unificado generado correctamente',
      data: {
        id: pdfFinal.id,
        ruta: pdfFinal.ruta,
        fecha_generacion: pdfFinal.fecha_generacion
      }
    });

  } catch (error) {
    console.error('Error al generar PDF unificado:', error);
    
    // Limpiar archivo temporal si se creó
    if (outputPath && fs.existsSync(outputPath)) {
      try {
        fs.unlinkSync(outputPath);
      } catch (cleanupError) {
        console.error('Error al limpiar archivo temporal:', cleanupError);
      }
    }

    res.status(500).json({ 
      success: false,
      message: 'Error al generar PDF unificado',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// ===== CONTROLADOR PARA OBTENER PDF UNIFICADO =====
const obtenerPDFUnificado = async (req, res) => {
  try {
    const { egresadoId } = req.params;

    // Buscar el PDF unificado más reciente del egresado
    const pdfFinal = await PDFFinal.findOne({
      where: {
        egresado_id: egresadoId,
        estado: 'activo'
      },
      order: [['fecha_generacion', 'DESC']],
      include: [{
        model: Egresado,
        attributes: ['nombre']
      }]
    });

    if (!pdfFinal) {
      return res.status(404).json({
        success: false,
        message: 'No se encontró un PDF unificado para este egresado'
      });
    }

    // Verificar que el archivo existe
    if (!fs.existsSync(pdfFinal.ruta)) {
      return res.status(404).json({
        success: false,
        message: 'El archivo PDF no se encuentra en el servidor'
      });
    }

    // Enviar el archivo
    res.download(pdfFinal.ruta, `documentos_${pdfFinal.Egresado.nombre}.pdf`);
  } catch (error) {
    console.error('Error al obtener PDF unificado:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener el PDF unificado'
    });
  }
};

module.exports = {
  loginAdmin,
  habilitarEgresadosDesdeExcel,
  listarEgresados,
  listarCarrerasConPDFs,
  listarPDFsPorCarrera,
  listarEgresadosConEvaluacion,
  verEvaluacionPorEgresado,
  enviarNotificacionesMasivas,
  generarPDFUnificado,
  obtenerPDFUnificado,
  upload
};
