import { IsEmail, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateUserDto {
    @IsEmail()
    email: string;

    @IsString()
    @MinLength(6)
    @MaxLength(255)
    password: string; // llegará en texto plano; se encripta en AuthService

    @IsOptional()
    @IsString()
    @MaxLength(120)
    name?: string;
}
