# Dockerfile optimizado para NestJS con Alpine Linux
# Multi-stage build para reducir el tamaño final de la imagen

# ===== STAGE 1: Build Stage =====
FROM node:20-alpine AS builder

# Instalar dependencias del sistema necesarias para compilar módulos nativos
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    libc6-compat

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de dependencias
COPY package*.json ./
COPY tsconfig*.json ./
COPY nest-cli.json ./

# Instalar dependencias (incluyendo devDependencies para el build)
RUN npm ci --only=production=false

# Copiar código fuente
COPY src/ ./src/

# Compilar la aplicación
RUN npm run build

# Limpiar devDependencies
RUN npm prune --production

# ===== STAGE 2: Production Stage =====
FROM node:20-alpine AS production

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos necesarios desde el stage de build
COPY --from=builder --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nestjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nestjs:nodejs /app/package*.json ./

# Cambiar al usuario no-root
USER nestjs

# Exponer el puerto
EXPOSE 3000

# Configurar variables de entorno por defecto
ENV NODE_ENV=production
ENV PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Comando para iniciar la aplicación
CMD ["node", "dist/main"]
