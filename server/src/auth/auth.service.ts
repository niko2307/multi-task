import { Injectable, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { DuplicateEmailAppException } from '../common/exceptions/duplicate-email.exception';

@Injectable()
export class AuthService {
    constructor(private users: UsersService, private jwt: JwtService) { }

    async register(dto: RegisterDto) {
        const exists = await this.users.findByEmail(dto.email);
        if (exists) throw new DuplicateEmailAppException();
        const password = await bcrypt.hash(dto.password, 10);
        const user = await this.users.create({ email: dto.email, password, name: dto.name });
        return this.sign(user.id, user.email);
    }

    async login({ email, password }: LoginDto) {
        const user = await this.users.findByEmail(email);
        const ok = user && (await bcrypt.compare(password, user.password));
        if (!ok) throw new UnauthorizedException('Invalid credentials');
        return this.sign(user.id, user.email);
    }

    private sign(sub: number, email: string) {
        return { access_token: this.jwt.sign({ sub, email }) };
    }
}
