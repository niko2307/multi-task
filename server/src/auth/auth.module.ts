import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt.strategy';
import { UsersModule } from '../users/users.module';


@Module({
    imports: [
        UsersModule,              // lo implementamos luego (findByEmail/create)
        PassportModule,
        JwtModule.registerAsync({
            inject: [ConfigService],
            useFactory: (cfg: ConfigService) => ({
                secret: cfg.get<string>('JWT_SECRET'),
                signOptions: { expiresIn: cfg.get<string>('JWT_EXPIRES_IN') || '7d' },
            }),
        }),
    ],
    controllers: [AuthController],
    providers: [AuthService, JwtStrategy],
    exports: [AuthService],
})
export class AuthModule { }
