import {
    Entity, PrimaryGeneratedColumn, Column, ManyToOne,
    Index, CreateDateColumn, UpdateDateColumn
} from 'typeorm';
import { User } from '../users/users.entity';

export enum TaskStatus {
    PENDING = 'pending',
    IN_PROGRESS = 'in_progress',
    COMPLETED = 'completed',
}

@Entity({ name: 'tasks' })
@Index(['userId', 'done'])
export class Task {
    @PrimaryGeneratedColumn()
    id: number;

    @Column('int')
    userId: number;

    @ManyToOne(() => User, (u) => u.tasks, { onDelete: 'CASCADE' })
    user: User;

    @Column({ length: 120 })
    title: string;

    @Column({ type: 'text', nullable: true })
    description?: string;

    // Estado de la tarea: solo admite valores del enum
    @Column({
        type: 'enum',
        enum: TaskStatus,
        default: TaskStatus.PENDING,
    })
    status: TaskStatus;

    @Column({ default: false })
    done: boolean;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}