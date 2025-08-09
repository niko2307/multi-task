import {
    Entity, PrimaryGeneratedColumn, Column, OneToMany,
    Index, CreateDateColumn, UpdateDateColumn
} from 'typeorm';
import { Task } from '../tasks/tasks.entity';

@Entity({ name: 'users' })
export class User {
    @PrimaryGeneratedColumn()
    id: number;

    @Index({ unique: true })
    @Column({ length: 180 })
    email: string;

    @Column({ length: 255 })
    password: string; // hash (bcrypt)

    @Column({ length: 120, nullable: true })
    name?: string;

    @OneToMany(() => Task, (t) => t.user, { cascade: ['remove'] })
    tasks: Task[];

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
