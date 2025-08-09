import { IsBoolean, IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { TaskStatus } from '../tasks.entity';

export class UpdateTaskDto {
    @IsString()
    @IsOptional()
    @MaxLength(120)
    title?: string;

    @IsString()
    @IsOptional()
    @MaxLength(3000)
    description?: string;

    @IsBoolean()
    @IsOptional()
    done?: boolean;

    @IsEnum(TaskStatus)
    @IsOptional()
    status?: TaskStatus;
}