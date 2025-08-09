import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { Public } from '../common/guards/public.decorator'; // para rutas sin token

@Controller('api/auth')
export class AuthController {
    constructor(private readonly auth: AuthService) { }

    // POST /api/v1/auth/register - Registro de usuario
    @Public()
    @Post('register')
    register(@Body() dto: RegisterDto) {
        return this.auth.register(dto);
    }

    // POST /api/v1/auth/login - Inicio de sesión
    @Public()
    @Post('login')
    login(@Body() dto: LoginDto) {
        return this.auth.login(dto);
    }
}
