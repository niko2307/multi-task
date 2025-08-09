import { NotFoundException } from '@nestjs/common';

export class EntityNotFoundAppException extends NotFoundException {
    constructor(entity = 'Resource') {
        super(`${entity} not found`);
    }
}
