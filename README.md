# Sistema de Gestión de Egresados UCC

Sistema completo para la gestión de egresados de la Universidad Cooperativa de Colombia, que incluye una aplicación móvil para egresados, una aplicación de escritorio para administradores y un backend en Node.js.

## Características

### Aplicación Móvil (Egresados)
- Registro e inicio de sesión de egresados
- Subida de documentos requeridos
- Completar evaluación de egresados
- Ver notificaciones
- Ver estado de habilitación

### Aplicación de Escritorio (Administrativos)
- Gestión de egresados
- Carga masiva de egresados mediante Excel
- Gestión de evaluaciones
- Generación de PDFs unificados
- Envío de notificaciones masivas

### Backend
- API REST con Node.js y Express
- Base de datos PostgreSQL
- Autenticación JWT
- Manejo de archivos
- Generación de PDFs

## Tecnologías Utilizadas

### Backend
- Node.js
- Express
- PostgreSQL
- Sequelize
- JWT
- Multer
- PDF-Lib

### Aplicación Móvil
- Flutter
- Provider
- HTTP
- Shared Preferences
- PDF Viewer

### Aplicación de Escritorio
- Flutter Desktop
- Provider
- HTTP
- File Picker
- PDF Viewer

## Requisitos Previos

- Node.js 16+
- Flutter 3.0+
- PostgreSQL 13+
- Git

## Instalación

1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/proyectoFinalDeGrado.git
cd proyectoFinalDeGrado
```

2. Configurar el Backend
```bash
cd backend-alumni
npm install
cp .env.example .env
# Editar .env con tus credenciales
npm start
```

3. Configurar la Aplicación de Escritorio
```bash
cd front_administrativo_desktop_app
flutter pub get
flutter run -d windows  # o macos/linux según tu sistema
```

4. Configurar la Aplicación Móvil
```bash
cd egresados_front_movil_app
flutter pub get
flutter run
```

## Estructura del Proyecto

```
proyectoFinalDeGrado/
├── backend-alumni/           # Backend en Node.js
│   ├── controllers/         # Controladores de la API
│   │   ├── models/             # Modelos de la base de datos
│   │   ├── routes/             # Rutas de la API
│   │   ├── middleware/         # Middleware de autenticación y validación
│   │   └── config/             # Configuración de la aplicación
│   └── pubspec.yaml        # Dependencias de Flutter
├── front_administrativo_desktop_app/  # Aplicación de escritorio
│   ├── lib/
│   │   ├── screens/        # Pantallas de la aplicación
│   │   ├── services/       # Servicios y llamadas a la API
│   │   ├── widgets/        # Widgets reutilizables
│   │   └── models/         # Modelos de datos
│   └── pubspec.yaml        # Dependencias de Flutter
└── egresados_front_movil_app/        # Aplicación móvil
    ├── lib/
    │   ├── screens/        # Pantallas de la aplicación
    │   ├── services/       # Servicios y llamadas a la API
    │   ├── widgets/        # Widgets reutilizables
    │   └── models/         # Modelos de datos
    └── pubspec.yaml        # Dependencias de Flutter
```

## Variables de Entorno

Crear un archivo `.env` en la carpeta `backend-alumni` con las siguientes variables:

```env
# Base de datos
DB_HOST=localhost
DB_PORT=5432
DB_NAME=railway
DB_USER=postgres
DB_PASSWORD=tu_password

# JWT
JWT_SECRET=tu_secreto_jwt

# Servidor
PORT=3000
NODE_ENV=development
```

## Uso

### Backend
```bash
cd backend-alumni
npm start
```

### Aplicación de Escritorio
```bash
cd front_administrativo_desktop_app
flutter run -d windows  # o macos/linux según tu sistema
```

### Aplicación Móvil
```bash
cd egresados_front_movil_app
flutter run
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.

## ✨ Créditos

Desarrollado por [Tu Nombre] para la Universidad Cooperativa de Colombia.

## 📞 Soporte

Para soporte, envía un email a [tu-email@ejemplo.com] o crea un issue en el repositorio. 