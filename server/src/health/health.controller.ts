import { Controller, Get } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { Public } from '../common/guards/public.decorator';

@Controller('api/health')
export class HealthController {
    constructor(private readonly dataSource: DataSource) { }

    // GET /api/health - Verificar estado general de la aplicación
    @Public()
    @Get()
    async getHealth() {
        return {
            status: 'ok',
            timestamp: new Date().toISOString(),
            service: 'multitask-api'
        };
    }

    // GET /api/health/database - Verificar conexión a la base de datos
    @Public()
    @Get('database')
    async getDatabaseHealth() {
        try {
            // Verificar si la conexión está activa
            if (!this.dataSource.isInitialized) {
                return {
                    status: 'error',
                    message: 'Database connection not initialized',
                    timestamp: new Date().toISOString()
                };
            }

            // Ejecutar una query simple para probar la conexión
            await this.dataSource.query('SELECT 1 as test');

            return {
                status: 'ok',
                message: 'Database connection successful',
                database: 'PostgreSQL (Neon)',
                timestamp: new Date().toISOString()
            };
        } catch (error) {
            return {
                status: 'error',
                message: 'Database connection failed',
                error: error.message,
                timestamp: new Date().toISOString()
            };
        }
    }

    // GET /api/health/detailed - Información detallada de la conexión
    @Public()
    @Get('detailed')
    async getDetailedHealth() {
        try {
            const isConnected = this.dataSource.isInitialized;
            let dbInfo = null;

            if (isConnected) {
                // Obtener información de la base de datos
                const result = await this.dataSource.query(`
          SELECT 
            version() as version,
            current_database() as database_name,
            current_user as user_name,
            inet_server_addr() as server_ip
        `);
                dbInfo = result[0];
            }

            return {
                status: isConnected ? 'ok' : 'error',
                application: {
                    name: 'multitask-api',
                    version: '1.0.0',
                    environment: process.env.NODE_ENV || 'development'
                },
                database: {
                    connected: isConnected,
                    type: 'PostgreSQL',
                    provider: 'Neon',
                    info: dbInfo
                },
                timestamp: new Date().toISOString()
            };
        } catch (error) {
            return {
                status: 'error',
                message: 'Health check failed',
                error: error.message,
                timestamp: new Date().toISOString()
            };
        }
    }
}
