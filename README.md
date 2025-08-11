# 📌 Multi-Task - Gestor de Tareas

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![NestJS](https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Aplicación completa de gestión de tareas** compuesta por un backend desarrollado con **NestJS** y un frontend móvil en **Flutter**.

[![Deploy on Render](https://img.shields.io/badge/Deploy%20on-Render-00ADD8?style=for-the-badge&logo=render&logoColor=white)](https://multi-task.onrender.com)

</div>

---

## 📖 Descripción del Proyecto

Este proyecto es una aplicación completa de gestión de tareas (**Task Manager**) que permite a usuarios autenticados **crear, consultar, actualizar y eliminar tareas** de manera sencilla, rápida y segura. Toda la información se almacena en una base de datos **PostgreSQL alojada en Neon**, y las operaciones están protegidas mediante **autenticación JWT**.

### 🏗️ Arquitectura del Sistema

#### Backend (NestJS)
- ✅ **Framework**: NestJS con TypeORM
- ✅ **Base de datos**: PostgreSQL (Neon)
- ✅ **Autenticación**: JWT
- ✅ **Despliegue**: Render
- ✅ **Funcionalidades**:
  - CRUD completo de tareas
  - Filtros y búsqueda avanzada
  - Cambio de estado y marcado como completadas
  - Sistema de autenticación y autorización
  - Endpoints de salud del sistema

#### Frontend Móvil (Flutter)
- ✅ **Framework**: Flutter (Android)
- ✅ **Estado**: Riverpod
- ✅ **HTTP Client**: Dio
- ✅ **Funcionalidades**:
  - Autenticación de usuarios
  - Gestión completa de tareas
  - Búsqueda y filtrado en tiempo real
  - Interfaz optimizada y responsive
  - Sincronización con backend

---

## 🚀 Inicio Rápido

### Prerrequisitos

- **Flutter** (versión 3.x o superior)
- **Android Studio** con emulador configurado
- **AVD (Android Virtual Device)** - Pixel con Android 13+
- **Java 17** instalado y configurado

### Configuración del Frontend

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd multitask/mobile
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar la URL de la API**
   
   En `lib/core/env.dart`, asegúrate de que la URL base esté configurada:
   ```dart
   const String BASE_URL = "https://multi-task.onrender.com/api";
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

> 💡 **Nota**: El backend ya está desplegado en Render, por lo que no es necesario ejecutarlo localmente.

---

## 📡 API Endpoints

### Autenticación
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/auth/register` | Registrar nuevo usuario |
| `POST` | `/api/auth/login` | Iniciar sesión y obtener JWT |
| `GET` | `/api/users/me` | Obtener perfil del usuario autenticado |

### Gestión de Tareas
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/tasks` | Listar tareas con filtros y búsqueda |
| `GET` | `/api/tasks/:id` | Obtener una tarea por ID |
| `POST` | `/api/tasks/create` | Crear nueva tarea |
| `PUT` | `/api/tasks/:id` | Actualizar una tarea completa |
| `PATCH` | `/api/tasks/:id/status` | Cambiar estado de tarea |
| `PATCH` | `/api/tasks/:id/toggle` | Alternar completado |
| `DELETE` | `/api/tasks/:id/delete` | Eliminar una tarea |

### Monitoreo
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/health` | Estado general del backend |
| `GET` | `/api/health/database` | Estado de la base de datos |
| `GET` | `/api/health/detailed` | Estado detallado del sistema |

**📍 Base URL**: `https://multi-task.onrender.com/api`

---

## 🌐 Despliegue

### Backend
- **Plataforma**: Render
- **URL**: [https://multi-task.onrender.com](https://multi-task.onrender.com)
- **Base de datos**: PostgreSQL en Neon

### Frontend
- **Plataforma**: Android
- **Distribución**: APK generado localmente

---

## 📸 Capturas de Pantalla

<div align="center">

### 🎨 Interfaz de Usuario - Multi-Task App

<table>
  <tr>
    <td align="center"><b>Login</b><br><img src="image/image.png" width="200" alt="Login Screen"></td>
    <td align="center"><b>Lista de Tareas</b><br><img src="image/image-1.png" width="200" alt="Task List"></td>
    <td align="center"><b>Crear Tarea</b><br><img src="image/image-2.png" width="200" alt="Task Creation"></td>
  </tr>
  <tr>
    <td align="center"><b>Detalles</b><br><img src="image/image-3.png" width="200" alt="Task Details"></td>
    <td align="center"><b>Gestión</b><br><img src="image/image-4.png" width="200" alt="Task Management"></td>
    <td align="center"><b>Búsqueda</b><br><img src="image/image-5.png" width="200" alt="Search Function"></td>
  </tr>
  <tr>
    <td align="center"><b>Filtros</b><br><img src="image/image-6.png" width="200" alt="Filter Options"></td>
    <td align="center"><b>Perfil</b><br><img src="image/image-7.png" width="200" alt="User Profile"></td>
    <td align="center"><b>Configuración</b><br><img src="image/image-8.png" width="200" alt="Settings"></td>
  </tr>
  <tr>
    <td align="center" colspan="3"><b>Navegación</b><br><img src="image/image-9.png" width="200" alt="Navigation"></td>
  </tr>
</table>

</div>

---

## 🛠️ Tecnologías Utilizadas

### Backend
- **NestJS** - Framework de Node.js
- **TypeScript** - Lenguaje de programación
- **TypeORM** - ORM para base de datos
- **PostgreSQL** - Base de datos relacional
- **JWT** - Autenticación
- **Class-validator** - Validación de datos
- **Jest** - Testing

### Frontend
- **Flutter** - Framework de desarrollo móvil
- **Dart** - Lenguaje de programación
- **Riverpod** - Gestión de estado
- **Dio** - Cliente HTTP
- **Shared Preferences** - Almacenamiento local

### DevOps & Herramientas
- **Render** - Plataforma de despliegue
- **Neon** - Base de datos PostgreSQL
- **Git** - Control de versiones
- **Docker** - Containerización

---

## 🤖 Desarrollo con IA

Durante el desarrollo del proyecto se utilizaron herramientas de inteligencia artificial como **ChatGPT** y **Cursor AI** con el objetivo de agilizar el flujo de trabajo y obtener orientación en la implementación de ciertas funcionalidades. Estas herramientas sirvieron como apoyo para resolver dudas técnicas, proponer soluciones y optimizar el tiempo de desarrollo, **sin sustituir el criterio y las decisiones técnicas tomadas por el equipo**.

---

## 📁 Estructura del Proyecto

```
multitask/
├── mobile/                 # Aplicación Flutter
│   ├── lib/
│   │   ├── core/          # Configuraciones y utilidades
│   │   ├── features/      # Módulos de funcionalidades
│   │   │   ├── auth/      # Autenticación
│   │   │   └── tasks/     # Gestión de tareas
│   │   └── main.dart
│   └── pubspec.yaml
├── server/                # Backend NestJS
│   ├── src/
│   │   ├── auth/          # Módulo de autenticación
│   │   ├── tasks/         # Módulo de tareas
│   │   ├── users/         # Módulo de usuarios
│   │   └── common/        # Utilidades comunes
│   └── package.json
└── README.md
```

---

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

<div align="center">

**Desarrollado con ❤️ para demostrar habilidades técnicas**

</div>