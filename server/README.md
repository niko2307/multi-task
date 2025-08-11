<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

# Multitask API

Una API RESTful moderna para gestión de tareas desarrollada con NestJS, TypeScript y PostgreSQL.

## 🚀 Descripción

Multitask API es una aplicación backend robusta que permite a los usuarios gestionar sus tareas de manera eficiente. La aplicación incluye autenticación JWT, gestión completa de tareas con diferentes estados, y una arquitectura escalable basada en microservicios.

## 🛠️ Tecnologías

- **Framework**: NestJS 11.x
- **Lenguaje**: TypeScript
- **Base de Datos**: PostgreSQL (Neon)
- **ORM**: TypeORM
- **Autenticación**: JWT + Passport
- **Validación**: class-validator + class-transformer
- **Encriptación**: bcrypt
- **Testing**: Jest

## 📋 Características Principales

- ✅ Autenticación JWT segura
- ✅ Gestión completa de tareas (CRUD)
- ✅ Estados de tareas (Pendiente, En Progreso, Completado)
- ✅ Filtros y búsqueda de tareas
- ✅ Validación de datos robusta
- ✅ Manejo de errores personalizado
- ✅ Health checks para monitoreo
- ✅ Documentación de API completa

## 🏗️ Estructura del Proyecto

```
src/
├── auth/           # Autenticación y autorización
├── users/          # Gestión de usuarios
├── tasks/          # Gestión de tareas
├── health/         # Health checks
├── common/         # Utilidades compartidas
│   ├── decorators/ # Decoradores personalizados
│   ├── guards/     # Guards de autenticación
│   ├── pipes/      # Pipes de validación
│   └── exceptions/ # Excepciones personalizadas
└── config/         # Configuración de la aplicación
```

## 🔐 Autenticación

La aplicación utiliza JWT (JSON Web Tokens) para la autenticación. Todos los endpoints están protegidos por defecto, excepto los marcados como públicos.

### Endpoints de Autenticación

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| `POST` | `/api/auth/register` | Registrar nuevo usuario | Público |
| `POST` | `/api/auth/login` | Iniciar sesión | Público |

## 👥 Gestión de Usuarios

### Endpoints de Usuarios

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| `GET` | `/api/users/me` | Obtener perfil del usuario autenticado | JWT |

## 📝 Gestión de Tareas

### Estados de Tareas
- `pending` - Pendiente
- `in_progress` - En Progreso
- `completed` - Completado

### Endpoints de Tareas

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| `GET` | `/api/tasks` | Obtener todas las tareas con filtros | JWT |
| `GET` | `/api/tasks/:id` | Obtener tarea específica | JWT |
| `POST` | `/api/tasks/create` | Crear nueva tarea | JWT |
| `PUT` | `/api/tasks/:id` | Actualizar tarea completa | JWT |
| `PATCH` | `/api/tasks/:id/status` | Cambiar estado de tarea | JWT |
| `PATCH` | `/api/tasks/:id/toggle` | Toggle completado | JWT |
| `DELETE` | `/api/tasks/:id/delete` | Eliminar tarea | JWT |

### Filtros Disponibles para GET /api/tasks

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `done` | boolean | Filtrar por tareas completadas |
| `status` | string | Filtrar por estado (pending, in_progress, completed) |
| `search` | string | Búsqueda por título o descripción |

## 🏥 Health Checks

### Endpoints de Monitoreo

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| `GET` | `/api/health` | Estado general de la aplicación | Público |
| `GET` | `/api/health/database` | Estado de la conexión a BD | Público |
| `GET` | `/api/health/detailed` | Información detallada del sistema | Público |

## 📊 Modelos de Datos

### Usuario (User)
```typescript
{
  id: number;
  email: string;        // Único
  password: string;     // Hash bcrypt
  name?: string;
  createdAt: Date;
  updatedAt: Date;
}
```

### Tarea (Task)
```typescript
{
  id: number;
  userId: number;
  title: string;        // Máximo 120 caracteres
  description?: string; // Opcional
  status: TaskStatus;   // pending, in_progress, completed
  done: boolean;        // Completado
  createdAt: Date;
  updatedAt: Date;
}
```

## 🔧 Configuración

### Variables de Entorno Requeridas

```env
DATABASE_URL=postgresql://user:password@host:port/database
JWT_SECRET=your-secret-key
NODE_ENV=development
```

## 🚀 Instalación y Uso

### Prerrequisitos
- Node.js 18+
- PostgreSQL (o Neon)
- npm o yarn

### Instalación

```bash
# Clonar el repositorio
git clone <repository-url>
cd server

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# Ejecutar migraciones (si es necesario)
npm run typeorm migration:run

# Iniciar en desarrollo
npm run start:dev

# Iniciar en producción
npm run build
npm run start:prod
```

### Scripts Disponibles

```bash
npm run start:dev      # Desarrollo con hot reload
npm run start:debug    # Desarrollo con debug
npm run start:prod     # Producción
npm run build          # Compilar
npm run test           # Ejecutar tests
npm run test:e2e       # Tests end-to-end
npm run lint           # Linting
npm run format         # Formatear código
```

## 🧪 Testing

La aplicación incluye tests unitarios y end-to-end:

```bash
# Tests unitarios
npm run test

# Tests con coverage
npm run test:cov

# Tests end-to-end
npm run test:e2e
```

## 📝 Ejemplos de Uso

### Registro de Usuario
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@ejemplo.com",
    "password": "password123",
    "name": "Usuario Ejemplo"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@ejemplo.com",
    "password": "password123"
  }'
```

### Crear Tarea
```bash
curl -X POST http://localhost:3000/api/tasks/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "Mi primera tarea",
    "description": "Descripción de la tarea",
    "status": "pending"
  }'
```

### Obtener Tareas con Filtros
```bash
curl -X GET "http://localhost:3000/api/tasks?done=false&status=pending&search=importante" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 🔒 Seguridad

- **Autenticación JWT**: Tokens seguros con expiración
- **Encriptación de contraseñas**: bcrypt con salt
- **Validación de datos**: class-validator para prevenir inyecciones
- **Guards**: Protección automática de rutas
- **Pipes**: Transformación y validación de entrada
- **CORS**: Configuración segura para cross-origin

## 📈 Monitoreo

- **Health Checks**: Endpoints para verificar el estado del sistema
- **Logging**: Interceptores para logging de requests
- **Error Handling**: Manejo centralizado de errores
- **Database Monitoring**: Verificación de conexión a BD

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia UNLICENSED. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Para soporte técnico o preguntas, por favor contacta al equipo de desarrollo o abre un issue en el repositorio.


