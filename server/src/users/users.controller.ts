import { Controller, Get, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';

@UseGuards(JwtAuthGuard)
@Controller('api/users')
export class UsersController {
    constructor(private readonly users: UsersService) { }

    // GET /api/users/me -> perfil del usuario autenticado (sin password)
    @Get('me')
    async me(@GetUser('sub') userId: number) {
        const profile = await this.users.getSafeProfile(userId);
        return profile ?? { message: 'User not found' };
    }
}
