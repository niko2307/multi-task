import { IsEnum, IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';
import { TaskStatus } from '../tasks.entity';

export class CreateTaskDto {
    @IsString()
    @IsNotEmpty()
    @MaxLength(120)
    title: string;

    @IsString()
    @IsOptional()
    @MaxLength(3000)
    description?: string;

    @IsEnum(TaskStatus)
    @IsOptional()
    status?: TaskStatus;
}