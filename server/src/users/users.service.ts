import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './users.entity';

@Injectable()
export class UsersService {
    constructor(@InjectRepository(User) private readonly repo: Repository<User>) { }

    // Crear usuario (AuthService hashea el password ANTES de llamar a esto)
    create(data: Partial<User>) {
        const entity = this.repo.create(data);
        return this.repo.save(entity);
    }

    findByEmail(email: string) {
        return this.repo.findOne({ where: { email } });
    }

    findById(id: number) {
        return this.repo.findOne({ where: { id } });
    }

    // (opcional) devolver un perfil seguro sin password
    async getSafeProfile(id: number) {
        const user = await this.findById(id);
        if (!user) return null;
        const { password, ...safe } = user;
        return safe;
    }
}
