import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const getTypeOrmConfig = (cfg: ConfigService): TypeOrmModuleOptions => {
    const url = cfg.get<string>('database.url');

    const base: TypeOrmModuleOptions = url
        ? { type: 'postgres', url }
        : {
            type: 'postgres',
            host: cfg.get<string>('database.host'),
            port: cfg.get<number>('database.port') ?? 5432,
            username: cfg.get<string>('database.user'),
            password: cfg.get<string>('database.pass'),
            database: cfg.get<string>('database.name'),
        };

    const useSsl = cfg.get<boolean>('database.ssl');
    const ssl = useSsl ? { rejectUnauthorized: false } : undefined;

    return {
        ...base,
        ssl,                   // Neon necesita SSL
        autoLoadEntities: true,
        synchronize: true,     // crea/actualiza tablas automáticamente (para la prueba)
        logging: true,      // si quieres ver los SQL en consola
    };
};
