<h1 align="center">📌 Multi-Task - Gestor de Tareas</h1>

<p align="center">
  <strong>Aplicación completa de gestión de tareas</strong> compuesta por un backend desarrollado con <b>NestJS</b> y un frontend móvil en <b>Flutter</b>.
</p>

---

## 📖 Descripción del Proyecto

Este proyecto es una aplicación completa de gestión de tareas (Task Manager) que permite a un usuario autenticado **crear, consultar, actualizar y eliminar tareas** de manera sencilla, rápida y segura.  
Toda la información se almacena en una base de datos **PostgreSQL alojada en Neon**, y las operaciones están protegidas mediante **autenticación JWT**.

🔹 **Backend**  
- Implementado en **NestJS** con **TypeORM**.  
- CRUD completo de tareas con filtros, búsqueda, cambio de estado y marcado como completadas.  
- Sistema de autenticación y autorización para garantizar que solo usuarios registrados puedan acceder a las funcionalidades.  
- Desplegado en **Render**.

🔹 **Frontend móvil**  
- Desarrollado con **Flutter** (solo Android).  
- Permite iniciar sesión, gestionar tareas y ver cambios en tiempo real.  
- Funcionalidades de búsqueda, filtrado y marcado rápido de tareas.  
- Interfaz optimizada para una experiencia fluida.

---

## 🛠 Manual de Uso

Para ejecutar este proyecto localmente es necesario:

1. **Tener instalado Flutter** (versión 3.x o superior).
2. **Android Studio** para manejar el emulador.
3. Configurar un **AVD (Android Virtual Device)**, preferiblemente un Pixel con Android 13 o superior.
4. **Java 17** instalado y configurado como predeterminado.

💡 **Nota:** El backend ya está desplegado en Render, por lo que no es necesario ejecutarlo localmente.

---

### 🔗 Configuración del Frontend

En el código de Flutter, configurar la URL base de la API en un archivo como `constants.dart` o `app_config.dart`:

```dart
const String BASE_URL = "https://multi-task.onrender.com/api";
comandos:
flutter pub get
flutter run


## Endpoints del Backend
Método	Endpoint	Descripción
POST	/api/auth/register	Registrar un nuevo usuario
POST	/api/auth/login	Iniciar sesión y obtener JWT
GET	/api/users/me	Obtener perfil del usuario autenticado
GET	/api/tasks	Listar tareas con filtros y búsqueda
GET	/api/tasks/:id	Obtener una tarea por ID
POST	/api/tasks/create	Crear nueva tarea
PUT	/api/tasks/:id	Actualizar una tarea completa
PATCH	/api/tasks/:id/status	Cambiar estado de tarea
PATCH	/api/tasks/:id/toggle	Alternar completado
DELETE	/api/tasks/:id/delete	Eliminar una tarea
GET	/api/health	Estado general del backend
GET	/api/health/database	Estado de la base de datos
GET	/api/health/detailed	Estado detallado del sistema

📍 Base URL: https://multi-task.onrender.com/api

<h2> URL de despliegue del backend </h2>
🔗 https://multi-task.onrender.com

<h2>Evidencia Fotográfica</h2>
<p align="center"> <img src="image/image.png" width="250" /> <img src="image/image-1.png" width="250" /> <img src="image/image-2.png" width="250" /> <img src="image/image-3.png" width="250" /> <img src="image/image-4.png" width="250" /> <img src="image/image-5.png" width="250" /> <img src="image/image-6.png" width="250" /> <img src="image/image-7.png" width="250" /> <img src="image/image-8.png" width="250" /> <img src="image/image-9.png" width="250" /> </p>

<h2> Uso de Inteligencia Artificial en el Desarrollo </h2>
Durante el desarrollo del proyecto se utilizaron herramientas de inteligencia artificial como ChatGPT y Cursor AI con el objetivo de agilizar el flujo de trabajo y obtener orientación en la implementación de ciertas funcionalidades.
Estas herramientas sirvieron como apoyo para resolver dudas técnicas, proponer soluciones y optimizar el tiempo de desarrollo, sin sustituir el criterio y las decisiones técnicas tomadas por el equipo.