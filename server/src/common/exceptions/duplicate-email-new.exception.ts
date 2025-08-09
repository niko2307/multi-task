import { ConflictException } from '@nestjs/common';

export class DuplicateEmailAppException extends ConflictException {
    constructor() {
        super('Email already in use');
    }
}
