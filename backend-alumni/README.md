# Backend Alumni - Sistema de Gestión de Egresados

Sistema backend para la gestión de egresados universitarios, desarrollado con Node.js, Express y PostgreSQL.

## 🚀 Características

- Gestión de egresados y administrativos
- Sistema de autenticación y autorización
- Gestión de documentos y evaluaciones
- Generación de PDFs unificados
- Sistema de notificaciones
- Caché con Redis
- Colas de procesamiento
- Documentación con Swagger
- Logging avanzado
- Monitoreo y métricas

## 📋 Prerrequisitos

- Node.js (v14 o superior)
- PostgreSQL (v12 o superior)
- Redis (opcional, para producción)
- npm o yarn

## 🔧 Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/backend-alumni.git
cd backend-alumni
```

2. Instalar dependencias:
```bash
npm install
```

3. Configurar variables de entorno:
```bash
cp .env.example .env
```
Editar el archivo `.env` con tus configuraciones.

4. Inicializar la base de datos:
```bash
npm run db:setup
```

5. Crear usuario administrador:
```bash
npm run create-admin
```

6. Iniciar el servidor:
```bash
# Desarrollo
npm run dev

# Producción
npm start
```

## 📚 Documentación de la API

La documentación completa de la API está disponible en:
- Desarrollo: http://localhost:3000/api-docs
- Producción: https://tu-dominio.com/api-docs

### Endpoints Principales

#### Egresados
- `POST /api/egresados/registro` - Registro de egresados
- `POST /api/egresados/login` - Inicio de sesión
- `GET /api/egresados/perfil` - Obtener perfil
- `PUT /api/egresados/perfil` - Actualizar perfil
- `POST /api/egresados/documentos` - Subir documentos
- `GET /api/egresados/documentos` - Listar documentos

#### Administrativos
- `POST /api/administrativos/registro` - Registro de administrativos
- `POST /api/administrativos/login` - Inicio de sesión
- `GET /api/administrativos/egresados` - Listar egresados
- `PUT /api/administrativos/egresados/:id` - Actualizar estado de egresado

## 🔍 Ejemplos de Uso

### Registro de Egresado
```javascript
const response = await fetch('http://localhost:3000/api/egresados/registro', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    nombre: 'Juan Pérez',
    correo: 'juan@example.com',
    carrera: 'Ingeniería Informática',
    password: 'contraseña123'
  })
});
```

### Subir Documento
```javascript
const formData = new FormData();
formData.append('documento', fileInput.files[0]);
formData.append('tipo', 'diploma');

const response = await fetch('http://localhost:3000/api/egresados/documentos', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`
  },
  body: formData
});
```

## 🤝 Guía de Contribución

1. Fork el proyecto
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Estándares de Código

- Usar ESLint y Prettier
- Seguir las convenciones de nombrado
- Documentar funciones y clases
- Escribir tests para nuevas funcionalidades

## 📊 Monitoreo y Logs

- Logs: `/logs`
  - `combined.log` - Todos los logs
  - `error.log` - Errores
  - `http.log` - Peticiones HTTP
  - `exceptions.log` - Excepciones no manejadas

- Métricas: http://localhost:3000/metrics

## 🔐 Seguridad

- Autenticación JWT
- Protección CSRF
- Rate limiting
- Headers de seguridad con Helmet
- Validación de entrada
- Sanitización de datos

## 🛠️ Tecnologías

- Node.js
- Express
- PostgreSQL
- Sequelize
- Redis
- Bull
- JWT
- Winston
- Swagger
- Jest

## 📝 Licencia

Este proyecto está bajo la Licencia ISC.

## 📧 Contacto

Tu Nombre - [@tutwitter](https://twitter.com/tutwitter) - email@example.com

Link del Proyecto: [https://github.com/tu-usuario/backend-alumni](https://github.com/tu-usuario/backend-alumni) 