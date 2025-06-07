// Documentos requeridos para los egresados
const REQUIRED_DOCUMENTS = [
  'encuesta2',
  'bolsa_empleo',
  'momento_ole'
];

// Roles disponibles en el sistema
const ROLES = {
  ADMIN: 'admin',
  EGRESADO: 'egresado'
};

// Estados de habilitación
const ESTADOS = {
  HABILITADO: true,
  DESHABILITADO: false
};

// Tipos de destinatarios para notificaciones
const TIPOS_DESTINATARIO = {
  EGRESADO: 'egresado',
  ADMIN: 'admin'
};

module.exports = {
  REQUIRED_DOCUMENTS,
  ROLES,
  ESTADOS,
  TIPOS_DESTINATARIO
}; 