import { Injectable, ValidationPipe } from '@nestjs/common';
@Injectable()
export class AppValidationPipe extends ValidationPipe {
    constructor() {
        super({
            whitelist: true,                // elimina props extra
            forbidNonWhitelisted: true,     // lanza 400 si vienen props desconocidas
            transform: true,                // castea tipos a los DTOs
            transformOptions: { enableImplicitConversion: true },
        });
    }
}