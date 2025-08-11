import {
    Controller,
    Get,
    Post,
    Patch,
    Delete,
    Body,
    Param,
    Query,
    HttpCode,
    HttpStatus,
    UseGuards,
    Put,
    UsePipes
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dtos/create-task.dto';
import { UpdateTaskDto } from './dtos/update-task.dto';
import { Task, TaskStatus } from './tasks.entity';

import { GetUser } from '../common/decorators/get-user.decorator';
import { ParseIntPipe } from '@nestjs/common';
import { ParseBoolQueryPipe } from '../common/pipes/parse-bool.pipe';
import { AppValidationPipe } from '../common/pipes/app-validation.pipe';

@Controller('api/tasks')
@UsePipes(AppValidationPipe)
export class TasksController {
    // Inyectamos el servicio de tareas
    constructor(private readonly tasksService: TasksService) { }

    // GET /api/v1/tasks - Obtener todas las tareas con filtros
    @Get()
    async getTasks(
        @GetUser('sub') userId: number,
        @Query('done', ParseBoolQueryPipe) done?: boolean,
        @Query('status') status?: TaskStatus,
        @Query('search') search?: string,
    ): Promise<Task[]> {

        const query = {
            done,
            status,
            search,
        };

        return this.tasksService.getTasks(userId, query);
    }

    // GET /api/v1/tasks/:id - Obtener una tarea específica
    @Get(':id')
    async getTaskById(
        @Param('id', ParseIntPipe) id: number,
        @GetUser('sub') userId: number,
    ): Promise<Task> {
        return this.tasksService.getTaskById(id, userId);
    }

    // POST /api/v1/tasks - Crear nueva tarea
    @Post('create')
    @HttpCode(HttpStatus.CREATED)
    async createTask(
        @Body() createTaskDto: CreateTaskDto,
        @GetUser('sub') userId: number,
    ): Promise<Task> {
        return this.tasksService.createTask(createTaskDto, userId);
    }

    // PUT /api/v1/tasks/:id - Actualizar tarea completa
    @Put(':id')
    async updateTask(
        @Param('id', ParseIntPipe) id: number,
        @Body() updateTaskDto: UpdateTaskDto,
        @GetUser('sub') userId: number,
    ): Promise<Task> {
        return this.tasksService.updateTask(id, updateTaskDto, userId);
    }

    // PATCH /api/v1/tasks/:id/status - Cambiar estado de tarea
    @Patch(':id/status')
    async changeTaskStatus(
        @Param('id', ParseIntPipe) id: number,
        @Body('status') status: TaskStatus,
        @GetUser('sub') userId: number,
    ): Promise<Task> {
        return this.tasksService.changeTaskStatus(id, userId, status);
    }

    // PATCH /api/v1/tasks/:id/toggle - Toggle completado
    @Patch(':id/toggle')
    async toggleTaskCompletion(
        @Param('id', ParseIntPipe) id: number,
        @GetUser('sub') userId: number,
    ): Promise<Task> {
        return this.tasksService.toggleTaskCompletion(id, userId);
    }

    // DELETE /api/v1/tasks/:id - Eliminar tarea
    @Delete(':id/delete')
    @HttpCode(HttpStatus.NO_CONTENT)
    async deleteTask(
        @Param('id', ParseIntPipe) id: number,
        @GetUser('sub') userId: number,
    ): Promise<void> {
        return this.tasksService.deleteTask(id, userId);
    }
}
