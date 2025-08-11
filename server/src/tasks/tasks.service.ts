import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Task, TaskStatus } from './tasks.entity';
import { CreateTaskDto } from './dtos/create-task.dto';
import { UpdateTaskDto } from './dtos/update-task.dto';
import { ILike, Repository } from 'typeorm';
import { EntityNotFoundAppException } from '../common/exceptions/entity-not-found.exception';
import { BadRequestAppException } from '../common/exceptions/bad-request.exception';
import { ForbiddenResourceAppException } from '../common/exceptions/forbiden-resource.exception';


type ListQuery = {
    done?: boolean;
    status?: TaskStatus;
    search?: string;

};

@Injectable()
export class TasksService {
    // Inyectamos el repositorio de tareas
    constructor(
        @InjectRepository(Task)
        private readonly taskRepository: Repository<Task>,
    ) { }

    // Método helper para validar IDs numéricos
    private validateNumericId(value: number, fieldName: string = 'ID'): void {
        if (!value || !Number.isInteger(value) || value <= 0) {
            throw new BadRequestAppException(`Invalid ${fieldName} format`);
        }
    }
    //metodo para obtner las tareas , filtrado por estado , si estan completadas o no ybusqueda por titulo o descripcion 
    async getTasks(userId: number, query: ListQuery): Promise<Task[]> {
        // Validar userId
        this.validateNumericId(userId, 'User ID');

        const { done, status, search } = query;
        const queryBuilder = this.taskRepository.createQueryBuilder('task')
            .where('task.userId = :userId', { userId });

        // Filtrar por estado de completado solo si se proporciona el parámetro
        if (done !== undefined) {
            queryBuilder.andWhere('task.done = :done', { done });
        }

        if (status) {
            queryBuilder.andWhere('task.status = :status', { status });
        }

        if (search) {
            queryBuilder.andWhere(
                '(task.title ILIKE :search OR task.description ILIKE :search)',
                { search: `%${search}%` }
            );
        }

        queryBuilder.orderBy('task.createdAt', 'DESC');

        const tasks = await queryBuilder.getMany();
        return tasks;
    }
    //metodo para crear una tarea del usuario , utilizando el dto de creacion de tarea 
    async createTask(createTaskDto: CreateTaskDto, userId: number): Promise<Task> {
        try {
            const task = this.taskRepository.create({
                ...createTaskDto,
                userId,
                status: createTaskDto.status || TaskStatus.PENDING,
                done: false,
            });

            const savedTask = await this.taskRepository.save(task);
            return savedTask;

        } catch (error) {
            if (error instanceof EntityNotFoundAppException) {
                throw error;
            }
            throw new BadRequestAppException(`Error creating task: ${error.message}`);
        }
    }

    //metodo para obtener una tarea por el id de la tarea 
    async getTaskById(id: number, userId: number): Promise<Task> {
        // Validaciones de entrada
        if (!id || !userId) {
            throw new BadRequestAppException('Task ID and User ID are required');
        }

        // Validar formato numérico
        this.validateNumericId(id, 'Task ID');
        this.validateNumericId(userId, 'User ID');

        try {
            // Una sola consulta: buscar la tarea que pertenece al usuario
            const task = await this.taskRepository.findOne({
                where: { id, userId },
                // relations: ['user'], // Descomenta si quieres incluir datos del usuario
            });

            if (!task) {
                // No distinguimos entre "no existe" y "no pertenece al usuario"
                // por seguridad - no revelamos información sobre recursos de otros usuarios
                throw new EntityNotFoundAppException('Task');
            }

            return task;
        } catch (error) {
            if (error instanceof EntityNotFoundAppException ||
                error instanceof BadRequestAppException) {
                throw error;
            }
            throw new BadRequestAppException(`Error retrieving task: ${error.message}`);
        }
    }

    //metodo para actualizar una tarea utilizando el dto de update task 
    async updateTask(id: number, updateTaskDto: UpdateTaskDto, userId: number): Promise<Task> {
        try {
            // Validaciones de entrada
            if (!id || !userId) {
                throw new BadRequestAppException('Task ID and User ID are required');
            }

            if (!updateTaskDto || Object.keys(updateTaskDto).length === 0) {
                throw new BadRequestAppException('Update data is required');
            }

            // Buscar la tarea existente
            const existingTask = await this.getTaskById(id, userId);

            // Validaciones específicas del negocio
            if (updateTaskDto.status && !Object.values(TaskStatus).includes(updateTaskDto.status)) {
                throw new BadRequestAppException('Invalid task status');
            }

            // Si se marca como completada, actualizar el campo done
            if (updateTaskDto.status !== undefined) {
                updateTaskDto.done = updateTaskDto.status === TaskStatus.COMPLETED;
            }
            // Aplicar actualizaciones usando merge (más eficiente)
            const taskToUpdate = this.taskRepository.merge(existingTask, updateTaskDto);

            // Guardar y retornar
            const savedTask = await this.taskRepository.save(taskToUpdate);
            return savedTask;

        } catch (error) {
            if (error instanceof EntityNotFoundAppException || error instanceof BadRequestAppException) {
                throw error;
            }
            throw new BadRequestAppException(`Error updating task: ${error.message}`);
        }
    }

    //metodo para eliminar una tarea 
    async deleteTask(id: number, userId: number): Promise<void> {
        const task = await this.getTaskById(id, userId);
        await this.taskRepository.remove(task);
    }

    //metodo para marcar una tarea como completada 
    async toggleTaskCompletion(id: number, userId: number): Promise<Task> {
        try {
            const task = await this.getTaskById(id, userId);

            // Toggle del estado
            const isCurrentlyCompleted = task.status === TaskStatus.COMPLETED;

            if (isCurrentlyCompleted) {
                // Desmarcar como completada
                task.status = TaskStatus.PENDING;
                task.done = false;
            } else {
                // Marcar como completada
                task.status = TaskStatus.COMPLETED;
                task.done = true;
            }

            return await this.taskRepository.save(task);

        } catch (error) {
            if (error instanceof EntityNotFoundAppException ||
                error instanceof ForbiddenResourceAppException) {
                throw error;
            }
            throw new BadRequestAppException(`Error toggling task completion: ${error.message}`);
        }
    }

    // Método para cambiar solo el estado de una tarea
    async changeTaskStatus(id: number, userId: number, newStatus: TaskStatus): Promise<Task> {
        try {
            // Validaciones de entrada
            if (!id || !userId) {
                throw new BadRequestAppException('Task ID and User ID are required');
            }

            if (!newStatus || !Object.values(TaskStatus).includes(newStatus)) {
                throw new BadRequestAppException('Valid task status is required');
            }

            // Obtener la tarea
            const task = await this.getTaskById(id, userId);

            // Actualizar status y sincronizar con done
            task.status = newStatus;
            task.done = newStatus === TaskStatus.COMPLETED;

            // Guardar y retornar
            const updatedTask = await this.taskRepository.save(task);
            return updatedTask;

        } catch (error) {
            if (error instanceof EntityNotFoundAppException ||
                error instanceof BadRequestAppException ||
                error instanceof ForbiddenResourceAppException) {
                throw error;
            }
            throw new BadRequestAppException(`Error changing task status: ${error.message}`);
        }
    }

}   
